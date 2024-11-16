import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchAllRooms();
    _fetchDailyReminders();
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

// Add this method to fetch daily reminders
  Future<void> _fetchDailyReminders() async {
    try {
      // Fetch all notes that should be shown today based on the check-in and check-out date
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('checkInDate', isLessThanOrEqualTo: DateTime.now().toUtc())
          .where('checkOutDate', isGreaterThanOrEqualTo: DateTime.now().toUtc())
          .get();

      print(
          "Number of documents fetched: ${snapshot.docs.length}"); // Debugging line

      setState(() {
        dailyReminders = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};

          // Ensure checkInDate and checkOutDate are properly converted to DateTime
          DateTime checkInDate =
              (data['checkInDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          DateTime checkOutDate =
              (data['checkOutDate'] as Timestamp?)?.toDate() ?? DateTime.now();

          // Normalize dates to ignore time
          checkInDate =
              DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
          checkOutDate =
              DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

          return {
            'reservationId': doc.id,
            'room': data['room'] ?? 'Unknown Room',
            'guestRequest': data['text'] ?? 'No requests',
            'frequency': data['frequency']?.toLowerCase() ?? 'just once',
            // Ensure frequency is in lowercase
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
            'status': data['status'] ?? 'Pending',
            'assignedToHK': data['assignedToHK'] ?? false,
          };
        }).where((reminder) {
          DateTime today = DateTime.now();
          today = DateTime(
              today.year, today.month, today.day); // Normalize today's date

          // Debugging: Log each reminder's details
          print(
              "Checking reminder: ${reminder['reservationId']}, CheckIn: ${reminder['checkInDate']}, CheckOut: ${reminder['checkOutDate']}, Frequency: ${reminder['frequency']}");

          // Check if the reminder's frequency is "Daily" or if it is "Just Once" and matches today's date
          bool isSameDayAsToday =
              reminder['checkInDate'].isAtSameMomentAs(today);
          bool isDailyReminder =
              reminder['frequency'] == 'daily'; // Ensure to check for lowercase
          bool isJustOnceReminder = reminder['frequency'] == 'justonce' &&
              isSameDayAsToday; // Check for 'justonce' without space

          // Return true if the reminder should be shown today
          return isDailyReminder || isJustOnceReminder;
        }).toList();

        // Debugging: Log the final list of daily reminders
        print("Daily reminders fetched: $dailyReminders");
      });
    } catch (e) {
      print("Error fetching daily reminders: $e");
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

// ... existing code ...
// Add this method to assign the note to housekeeping
  void _assignToHK(String reservationId) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(reservationId)
        .update({
      'assignedToHK': true,
    });
    _fetchDailyReminders(); // Refresh the reminders after assignment
  }

  void _updateRequestStatus(String reservationId, String newStatus) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'notes.status': newStatus,
    });
    _fetchDailyReminders();
  }

  Widget _buildDailyReminders() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.dailyGuestRequests,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
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
                            // Replace IconButton with TextButton
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
                                  : 'pending', // Fallback to 'pending' if unmatched
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
          title: Text(S.current.frontDesk),
          backgroundColor: const Color(0xFFDBB017),
          bottom: TabBar(
            tabs: [
              Tab(text: S.current.calendar),
              Tab(text: S.current.dailyGuestRequests),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCalendarAndRoomStatus(),
            _buildDailyReminders(),
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
                  if (selectedRange == null) return false;
                  return day.isAtSameMomentAs(selectedRange!.start) ||
                      (day.isAfter(selectedRange!.start) &&
                          day.isBefore(selectedRange!.end.add(Duration(days: 1))));
                },
                onDaySelected: (selectedDay, focusedDay) {
                  _fetchRoomStatusForDate(selectedDay);
                },
                calendarStyle: CalendarStyle(
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
    return Column(
      children: [
        Text(
          S.current.roomStatus,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allRooms.length,
            itemBuilder: (context, index) {
              final room = allRooms[index];
              return ListTile(
                title: Text('${S.current.room} ${room['roomNumber']}'),
                subtitle: Text(room['status']),
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
  Future<void> _fetchRoomReservationsForRange(DateTime start, DateTime end) async {
    // Fetch reservations overlapping the selected date range
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('checkOutDate', isGreaterThanOrEqualTo: start)
        .where('checkInDate', isLessThanOrEqualTo: end)
        .get();

    setState(() {
      roomReservations = []; // Clear previous reservations

      for (var doc in snapshot.docs) {
        DateTime checkInDate = (doc['checkInDate'] as Timestamp).toDate();
        DateTime checkOutDate = (doc['checkOutDate'] as Timestamp).toDate();

        // Mark dates between check-in and check-out
        DateTime currentDay = checkInDate;
        while (currentDay.isBefore(checkOutDate)) {
          if (currentDay.isAfter(start.subtract(Duration(days: 1))) &&
              currentDay.isBefore(end.add(Duration(days: 1)))) {
            roomReservations.add(
              Appointment(
                startTime: currentDay,
                endTime: currentDay.add(const Duration(days: 1)),
                subject: '${S.current.room} ${doc['roomNumber']} - ${S.current.occupied}',
                color: Colors.red, // Highlight for reserved days
              ),
            );
          }
          currentDay = currentDay.add(const Duration(days: 1));
        }
      }
    });
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