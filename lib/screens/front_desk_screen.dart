import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/screens/rooms_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class FrontDeskScreen extends StatefulWidget {
  @override
  _FrontDeskScreenState createState() => _FrontDeskScreenState();
}

class _FrontDeskScreenState extends State<FrontDeskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CalendarController _calendarController = CalendarController();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> allRooms = [];
  List<Map<String, dynamic>> dailyReminders = [];
  List<Appointment> roomReservations =
      []; // List to store room reservation events
  String selectedRoomNumber = ''; // Track selected room number
  String selectedFloor = 'All Floors';
  String selectedRoomType = 'All Types';
  DateTimeRange? selectedRange;
  DateTime selectedReminderDate = DateTime.now(); // Track the selected date for reminders


  @override
  void initState() {
    super.initState();
    _fetchAllRooms();
    _fetchDailyReminders(DateTime.now());
  }

  Future<void> _addRequest(String requestDetail) async {
    await _firestore.collection('frontdeskRequest').add({
      'requestDetail': requestDetail,
      'date': DateTime.now(),
      'status': 'Pending',
    });
  }

  Future<void> _fetchAllRooms() async {
    QuerySnapshot snapshot = await _firestore.collection('rooms').get();
    setState(() {
      allRooms = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    _updateRoomStatuses();
  }

  void _showAddRequestDialog() {
    TextEditingController requestController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.current.addRequest),
          content: TextField(
            controller: requestController,
            decoration: InputDecoration(
              hintText: S.current.enterRequestDetails,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (requestController.text.isNotEmpty) {
                  _addRequest(requestController.text);
                  Navigator.pop(context);
                }
              },
              child: Text(S.current.add),
            ),
          ],
        );
      },
    );
  }



  var statusOptions = {
    'pending': S.current.pending,
    'inProgress': S.current.inProgress,
    'completed': S.current.completed,
  };

  Future<void> _fetchDailyReminders(DateTime date) async {
    try {
      // Normalize the selected day to midnight
      DateTime selectedDay = DateTime(date.year, date.month, date.day);
      print("Fetching reminders for date: $selectedDay");

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('checkInDate', isLessThanOrEqualTo: selectedDay)
          .where('checkOutDate', isGreaterThanOrEqualTo: selectedDay)
          .get();

      print("Number of documents fetched: ${snapshot.docs.length}");

      setState(() {
        dailyReminders = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          print("Document data: $data");

          // Parse Firestore timestamps
          DateTime checkInDate =
              (data['checkInDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          DateTime checkOutDate =
              (data['checkOutDate'] as Timestamp?)?.toDate() ?? DateTime.now();

          // Normalize dates to midnight for comparison
          checkInDate =
              DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
          checkOutDate =
              DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

          return {
            'reservationId': data['reservationId']?.toString() ?? 'Unknown',
            'room': data['room']?.toString() ?? 'Unknown Room',
            'guestRequest': data['text'] ?? 'No requests',
            'frequency': data['frequency'] ?? 'justOnce',
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
            'status': data['status'] ?? 'Pending',
            'assignedToHK': data['assignedToHK'] ?? false,
          };
        }).where((reminder) {
          // Retrieve values
          DateTime checkIn = reminder['checkInDate'];
          DateTime checkOut = reminder['checkOutDate'];
          String frequency = reminder['frequency'];

          // Evaluate conditions
          bool isWithinDateRange =
              !checkIn.isAfter(selectedDay) && !checkOut.isBefore(selectedDay);
          bool isDailyReminder = frequency == 'Daily';

          // Update condition for justOnce
          bool isJustOnceReminder = frequency == 'justOnce' &&
              (selectedDay.isAfter(checkIn.subtract(Duration(days: 1))) &&
                  selectedDay.isBefore(checkOut.add(Duration(days: 1))));

          // Debug output
          print("Reminder: $reminder");
          print("Selected day: $selectedDay");
          print("Check-in: $checkIn, Check-out: $checkOut");
          print("Within range: $isWithinDateRange");
          print("Daily: $isDailyReminder, Just once: $isJustOnceReminder");

          // Final filtering condition
          return isWithinDateRange && (isDailyReminder || isJustOnceReminder);
        }).toList();

        print("Filtered reminders: $dailyReminders");
      });
    } catch (e) {
      print("Error fetching daily reminders: $e");
    }
  }


  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedReminderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedReminderDate) {
      setState(() {
        selectedReminderDate = picked;
      });
      _fetchDailyReminders(picked);
    }
  }


// ... existing code ...
  void _updateRoomStatuses() async {
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('checkInDate', isLessThanOrEqualTo: selectedDate)
        .where('checkOutDate',
            isGreaterThan:
                selectedDate) // Change to > to exclude check-outs today
        .get();

    List<String> occupiedRooms =
        snapshot.docs.map((doc) => doc['roomNumber'] as String).toList();

    setState(() {
      allRooms = allRooms.map((room) {
        return {
          ...room,
          'status': occupiedRooms.contains(room['roomNumber'])
              ? 'Occupied'
              : 'Available',
        };
      }).toList();
    });
  }

// Add this method to assign the note to housekeeping
  void _assignToHK(String reservationId) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(reservationId)
        .update({
      'assignedToHK': true,
    });
    _fetchDailyReminders(selectedReminderDate); // Refresh the reminders after assignment
  }

  void _updateRequestStatus(String reservationId, String newStatus) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'notes.status': newStatus,
    });
    _fetchDailyReminders(selectedReminderDate);

  }

  Widget _buildDailyReminders() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.current.dailyGuestRequests,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            dailyReminders.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dailyReminders.length,
              itemBuilder: (context, index) {
                final reminder = dailyReminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.room_service_outlined,
                              color: const Color(0xFFDBB017),
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${S.current.room} ${reminder['room']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${reminder['guestRequest']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: reminder['assignedToHK']
                                    ? Colors.green
                                    : const Color(0xFFDBB017),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (!reminder['assignedToHK']) {
                                  _assignToHK(reminder['reservationId']);
                                }
                              },
                              child: Text(
                                reminder['assignedToHK']
                                    ? S.current.assigned
                                    : S.current.assignedToHk,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white, fontFamily: 'Amiri',),
                              ),
                            ),
                            DropdownButton<String>(
                              value: reminder['status'], // Directly bind to reminder['status']

                              items: [
                                DropdownMenuItem(
                                  value: 'Pending',
                                  child: Text(S.current.pending,
                                      style: TextStyle(color: Colors.orange, fontFamily: 'Amiri',)),
                                ),
                                DropdownMenuItem(
                                  value: 'In Progress',
                                  child: Text(S.current.inProgress,
                                      style: TextStyle(color: Colors.blue, fontFamily: 'Amiri',)),
                                ),
                                DropdownMenuItem(
                                  value: 'Completed',
                                  child: Text(S.current.completed,
                                      style: TextStyle(color: Colors.green, fontFamily: 'Amiri',)),
                                ),
                              ],
                                onChanged: (newStatus) async {
                                  if (newStatus != null) {
                                    setState(() {
                                      reminder['status'] = newStatus; // Update UI state immediately
                                    });

                                    try {
                                      // Update Firestore or backend
                                      await FirebaseFirestore.instance
                                          .collection('notes')
                                          .doc(reminder['reservationId'])
                                          .update({'status': newStatus});
                                    } catch (e) {
                                      print('Error updating status: $e');
                                      // Optionally revert the state if the update fails
                                      setState(() {
                                        reminder['status'] = 'Pending';
                                      });
                                    }
                                  }
                                }

                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  S.current.noRequestsForToday,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

Widget _buildDailyRemindersForMob() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.current.dailyGuestRequests,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          dailyReminders.isNotEmpty
              ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: dailyReminders.length,
            itemBuilder: (context, index) {
              final reminder = dailyReminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: Icon(
                    Icons.room_service_outlined,
                    color: const Color(0xFFDBB017),
                    size: 30,
                  ),
                  title: Text(
                    '${S.current.room} ${reminder['room']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${reminder['guestRequest']}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: reminder['assignedToHK']
                              ? Colors.green
                              : const Color(0xFFDBB017),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (!reminder['assignedToHK']) {
                            _assignToHK(reminder['reservationId']);
                          }
                        },
                        child: Text(
                          reminder['assignedToHK']
                              ? S.current.assigned
                              : S.current.assignedToHk,
                          style: TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      DropdownButton<String>(
                        value: statusOptions.keys
                            .contains(reminder['status'])
                            ? reminder['status']
                            : 'pending',
                        items: statusOptions.keys.map((key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(statusOptions[key]!),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            _updateRequestStatus(
                                reminder['reservationId'], newStatus);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
              : Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                S.current.noRequestsForToday,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }








  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(S.current.frontDesk,style: TextStyle(fontSize: 26, fontFamily: 'Amiri',fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xFFDBB017),
          bottom: TabBar(
            tabs: [
              Tab(text: S.current.calendar),
              Tab(text: S.current.dailyGuestRequests),
            ],
            labelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'Amiri', // Apply Amiri font family
              fontSize: 22, // Optional: Adjust the font size if needed
              fontWeight: FontWeight.bold, // Optional: Set bold weight for the text
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCalendarAndRoomStatus(),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 300) {
                  // For web, desktop, and large screens
                  return _buildDailyReminders();
                } else {
                  // For mobile and smaller screens
                  return _buildDailyRemindersForMob();
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddRequestDialog,
          child: Icon(Icons.add),
          backgroundColor: const Color(0xFFDBB017),
        ),
      ),
    );
  }
// ... existing code ...

  Widget _buildCalendarAndRoomStatus() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDate,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) {
                  return day.isAtSameMomentAs(selectedDate);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                    selectedRange = null; // Clear the range when a new date is selected
                  });
                  _fetchRoomStatusForDate(selectedDay);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue, // Color for the selected day
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orange, // Color for today's date
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor: Colors.transparent, // Disable default blue highlight
                ),
                calendarBuilders: CalendarBuilders(
                  // Fully customize range days
                  rangeHighlightBuilder: (context, day, isWithinRange) {
                    if (isWithinRange) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.red, // Completely red background
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white), // White text for contrast
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                rangeStartDay: selectedRange?.start,
                rangeEndDay: selectedRange?.end,
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // Hide the format button
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildRoomList(),
        ),
      ],
    );
  }

  Future<void> _fetchRoomStatusForDate(DateTime date) async {
    setState(() {
      selectedDate = date; // Update the selected date
      selectedRange = null; // Clear the range when a new date is selected

    });

    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('checkInDate', isLessThanOrEqualTo: date)
        .where('checkOutDate', isGreaterThan: date) // Exclude check-out day
        .get();

    List<String> occupiedRooms =
    snapshot.docs.map((doc) => doc['roomNumber'] as String).toList();

    setState(() {
      allRooms = allRooms.map((room) {
        return {
          ...room,
          'status': occupiedRooms.contains(room['roomNumber'])
              ? 'Occupied'
              : 'Available',
        };
      }).toList();
    });
  }

  Future<void> _fetchRoomReservations(String roomNumber) async {
    // Fetch reservations for the selected room overlapping the selected date
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('roomNumber', isEqualTo: roomNumber)
        .where('checkInDate', isLessThanOrEqualTo: selectedDate)
        .where('checkOutDate', isGreaterThan: selectedDate)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      DateTime checkInDate = (doc['checkInDate'] as Timestamp).toDate();
      DateTime checkOutDate = (doc['checkOutDate'] as Timestamp).toDate();

      setState(() {
        selectedRange = DateTimeRange(
          start: checkInDate,
          end: checkOutDate.subtract(Duration(days: 1)), // End day before checkout
        );
      });
    }
  }

  Widget _buildRoomList() {
    String _translateRoomTypeToArabic(String roomType) {
      // Add translations for room types here
      switch (roomType) {
        case 'Suite':
          return 'سويت';
        case 'Mini Suite':
          return 'ميني سويت';
        case 'Room':
          return 'غرفة';
      // Add more cases as needed
        default:
          return roomType; // Return the original if no translation is found
      }
    }
    String _translateRoomStatusToArabic(String status) {
      // Add translations for room statuses here
      switch (status) {
        case 'Occupied':
          return 'مشغول';
        case 'Available':
          return 'متاح';
      // Add more cases as needed
        default:
          return status; // Return the original if no translation is found
      }
    }
    return Column(
      children: [
        SizedBox(height: 5,),
        Text(
          S.current.roomStatus,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Amiri',),
        ),
        SizedBox(height: 5,),

        Expanded(
          child: ListView.builder(
            itemCount: allRooms.length,
            itemBuilder: (context, index) {
              final room = allRooms[index];
              String roomNumber = room['roomNumber'];
              String roomType = room['roomType'];
              String roomStatus = room['status'];


              // Check if the current locale is Arabic
              if (Localizations.localeOf(context).languageCode == 'ar') {
                // Format the room number in Arabic
                roomNumber = NumberFormat.decimalPattern('ar').format(int.parse(roomNumber));
                // Translate the room type to Arabic
                roomType = _translateRoomTypeToArabic(roomType);
                roomStatus = _translateRoomStatusToArabic(roomStatus);

              }

              String roomDisplay = '$roomType ${getLocalizedNumber(roomNumber)}'; // Dynamic room type

              return ListTile(
                title: Text(roomDisplay,style: TextStyle(fontSize: 18,),),
                subtitle: Text(roomStatus,style: TextStyle(fontSize: 16,),),
                tileColor: room['status'] == 'Available'
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.redAccent.withOpacity(0.2),
                onTap: () async {
                  if (room['status'] == 'Occupied') {
                    await _fetchRoomReservations(room['roomNumber']);
                  } else {
                    setState(() {
                      selectedRange = null; // Clear the range for available rooms
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }


}

class RoomStatusDataSource extends CalendarDataSource {
  RoomStatusDataSource(List<Appointment> appointments) {
    for (var appointment in appointments) {
      DateTime checkoutDate = appointment.endTime;

      appointment.endTime = checkoutDate.subtract(Duration(days: 2));
    }
    this.appointments = appointments;
  }
}

class RoomCalendarDataSource extends CalendarDataSource {
  RoomCalendarDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }

  @override
  List<dynamic> get appointments => super.appointments!;
}