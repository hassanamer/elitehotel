// ... existing imports ...
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HKAttendanceHistoryPage extends StatefulWidget {
  @override
  _HKAttendanceHistoryPageState createState() =>
      _HKAttendanceHistoryPageState();
}

class _HKAttendanceHistoryPageState extends State<HKAttendanceHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedHKUserId;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> hkStaffList = [];
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchHKStaff();
  }

  Future<void> _fetchHKStaff() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('accountType', isEqualTo: 'HK Staff')
        .get();

    setState(() {
      hkStaffList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    });
  }

  Future<void> _fetchAttendanceRecords() async {
    if (selectedHKUserId == null) {
      print("No HK User selected.");
      return;
    }

    final startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    print("Fetching attendance records for user: $selectedHKUserId");
    print(
        "Date range: ${startOfDay.toIso8601String()} to ${endOfDay.toIso8601String()}");

    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('hkUserId', isEqualTo: selectedHKUserId)
          .get();

      print("Total records for user: ${querySnapshot.docs.length}");

      for (var doc in querySnapshot.docs) {
        final checkInTime = (doc['checkInTime'] as Timestamp).toDate();
        print("Document ID: ${doc.id}");
        print("Check-In Time: ${checkInTime.toIso8601String()}");
        print("Data: ${doc.data()}");
      }

      // Filter records by date range
      setState(() {
        attendanceRecords = querySnapshot.docs
            .where((doc) {
              final checkInTime = (doc['checkInTime'] as Timestamp).toDate();
              return checkInTime.isAfter(startOfDay) &&
                  checkInTime.isBefore(endOfDay);
            })
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      print("Filtered records count: ${attendanceRecords.length}");
    } catch (e) {
      print("Error fetching attendance records: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchAttendanceRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBB017),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              'HK Attendance History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDBB017),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: DropdownButton<String>(
                      hint: Text('Select HK Staff',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                      value: selectedHKUserId,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedHKUserId = newValue;
                        });
                        _fetchAttendanceRecords();
                      },
                      items: hkStaffList.map((staff) {
                        return DropdownMenuItem<String>(
                          value: staff['id'],
                          child: Text(staff['name']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                        icon: Icon(Icons.calendar_today,size: 20,),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Name: ${record['hkName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Check-In: ${DateFormat('hh:mm a').format((record['checkInTime'] as Timestamp).toDate())}'),
                        Text(
                            'Check-Out: ${record['checkOutTime'] != null ? DateFormat('hh:mm a').format((record['checkOutTime'] as Timestamp).toDate()) : 'N/A'}'),
                        Text('Location: ${record['checkInLocation']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
