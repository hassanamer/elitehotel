import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  String selectedFloor = 'All Floors';
  String selectedRoomType = 'All Types';

  @override
  void initState() {
    super.initState();
    _fetchAllRooms();
    _fetchDailyReminders();
  }

  Future<void> _fetchAllRooms() async {
    QuerySnapshot snapshot = await _firestore.collection('rooms').get();
    setState(() {
      allRooms = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
    _updateRoomStatuses();
  }

  var statusOptions = {
    'pending': S.current.pending,
    'inProgress': S.current.inProgress,
    'completed': S.current.completed,
  };

  Future<void> _fetchDailyReminders() async {
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('checkInDate', isLessThanOrEqualTo: DateTime.now())
        .where('checkOutDate', isGreaterThanOrEqualTo: DateTime.now())
        .get();

    setState(() {
      dailyReminders = snapshot.docs.map((doc) {
        final notes = doc['notes'] as Map<String, dynamic>? ?? {};
        return {
          'reservationId': doc.id,
          'room': doc['roomNumber'],
          'guestRequest': notes['text'] ?? 'No requests',
          'frequency': notes['frequency'] ?? 'Just Once',
          'checkInDate': (doc['checkInDate'] as Timestamp).toDate(),
          'status': notes['status'] ?? 'Pending',
          'assignedToHK': notes['assignedToHK'] ?? false,
        };
      }).where((reminder) {
        DateTime checkInDate = reminder['checkInDate'];
        bool isSameDayAsToday = checkInDate.year == DateTime.now().year &&
            checkInDate.month == DateTime.now().month &&
            checkInDate.day == DateTime.now().day;

        return reminder['frequency'] == 'Daily' || (reminder['frequency'] == 'Just Once' && isSameDayAsToday);
      }).toList();
    });
  }

  void _updateRoomStatuses() async {
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('checkInDate', isLessThanOrEqualTo: selectedDate)
        .where('checkOutDate', isGreaterThanOrEqualTo: selectedDate)
        .get();

    List<String> occupiedRooms = snapshot.docs.map((doc) => doc['roomNumber'] as String).toList();

    setState(() {
      allRooms = allRooms.map((room) {
        return {
          ...room,
          'status': occupiedRooms.contains(room['roomNumber']) ? 'Occupied' : 'Available',
        };
      }).toList();
    });
  }

  void _assignToHK(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'notes.assignedToHK': true,
    });
    _fetchDailyReminders();
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
                    color: Colors.blueAccent,
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
                          backgroundColor: reminder['assignedToHK'] ? Colors.green : const Color(0xFFDBB017),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          reminder['assignedToHK'] ? S.current.assigned : S.current.assignedToHk,
                          style: TextStyle(fontSize: 18,color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 20,),
                      DropdownButton<String>(
                        value: statusOptions.keys.contains(reminder['status']) ? reminder['status'] : 'pending', // Fallback to 'pending' if unmatched
                        items: statusOptions.keys.map((key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(statusOptions[key]!),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            _updateRequestStatus(reminder['reservationId'], newStatus);
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
  void _fetchRoomStatusForDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _updateRoomStatuses();
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
      ),
    );
  }

  Widget _buildCalendarAndRoomStatus() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {
                      _calendarController.backward!();
                    },
                  ),
                  Text(
                    '${selectedDate.year} - ${selectedDate.month}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () {
                      _calendarController.forward!();
                    },
                  ),
                ],
              ),
              Expanded(
                child: SfCalendar(
                  controller: _calendarController,
                  view: CalendarView.month,
                  onTap: (calendarTapDetails) {
                    if (calendarTapDetails.date != null) {
                      _fetchRoomStatusForDate(calendarTapDetails.date!);
                    }
                  },
                  dataSource: RoomStatusDataSource(_buildRoomStatusEvents()),
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
              );
            },
          ),
        ),
      ],
    );
  }

  List<Appointment> _buildRoomStatusEvents() {
    return allRooms.map((room) {
      return Appointment(
        startTime: selectedDate,
        endTime: selectedDate.add(Duration(hours: 1)),
        subject: '${S.current.room} ${room['roomNumber']} - ${room['status']}',
        color: room['status'] == 'Occupied' ? Colors.red : Colors.green,
      );
    }).toList();
  }
}

class RoomStatusDataSource extends CalendarDataSource {
  RoomStatusDataSource(List<Appointment> source) {
    appointments = source;
  }
}
