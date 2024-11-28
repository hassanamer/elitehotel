import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class HKScreen extends StatefulWidget {
  @override
  _HKScreenState createState() => _HKScreenState();
}

class _HKScreenState extends State<HKScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  String hkUserId = "";
  String hkName = "";
  String? userAccountType;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final email = currentUser.email;
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        setState(() {
          hkUserId = userDoc.id;
          hkName = userDoc['name'];
          userAccountType = userDoc['accountType'];
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBB017),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFDBB017),
        elevation: 0,
        title: Text(
          'HELLO, $hkName! 👋',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (userAccountType == 'Admin' ||
              userAccountType == 'Manager' ||
              userAccountType == 'HK Staff')
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Handle notifications
              },
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          if (userAccountType == 'HK Staff') AttendancePage(hkUserId: hkUserId),
          RoomsPage(userAccountType: userAccountType),
          RequestsPage(userAccountType: userAccountType),
          AssignedNotesPage(),
          FrontDeskRequestsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFFDBB017),selectedFontSize: 16,selectedLabelStyle:TextStyle(fontSize: 16,) ,
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: TextStyle(color: Colors.black,fontSize: 16,),
        items: [
          if (userAccountType == 'HK Staff')
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Color(0xFFDBB017)),
              label: S.current.homeTitle,
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service, color: Color(0xFFDBB017)),
            label: S.current.rooms,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Color(0xFFDBB017)),
            label: S.current.requests,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_sharp, color: Color(0xFFDBB017)),
            label: S.current.assignedNotes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined, color: Color(0xFFDBB017)),
            label: S.current.frontDeskRequests,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final String hkUserId;

  AttendancePage({required this.hkUserId});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Duration? _workingHours;
  String _location = "Unknown";
  bool _isPunchInButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkForTodayAttendance();
  }

  Future<void> _checkForTodayAttendance() async {
    final today = DateTime.now();
    final startOfDay = DateTime.utc(today.year, today.month, today.day);
    final endOfDay =
        DateTime.utc(today.year, today.month, today.day, 23, 59, 59);

    final attendanceSnapshot = await _firestore
        .collection('attendance')
        .where('hkUserId', isEqualTo: widget.hkUserId)
        .where('checkInTime', isGreaterThanOrEqualTo: startOfDay)
        .where('checkInTime', isLessThanOrEqualTo: endOfDay)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      final doc = attendanceSnapshot.docs.first;
      setState(() {
        _isCheckedIn = doc['checkOutTime'] == null;
        _checkInTime = (doc['checkInTime'] as Timestamp).toDate();
        _checkOutTime = doc['checkOutTime'] != null
            ? (doc['checkOutTime'] as Timestamp).toDate()
            : null;
        _workingHours = _checkOutTime != null
            ? _checkOutTime!.difference(_checkInTime!)
            : null;
        _location = doc['checkInLocation'] ?? "Unknown";
      });
    } else {
      setState(() {
        _isCheckedIn = false;
        _checkInTime = null;
        _checkOutTime = null;
        _workingHours = null;
        _location = "Unknown";
      });
    }
  }

  Future<void> _checkIn() async {
    final today = DateTime.now();
    final attendanceSnapshot = await _firestore
        .collection('attendance')
        .where('hkUserId', isEqualTo: widget.hkUserId)
        .where('checkInTime',
            isGreaterThan: DateTime(today.year, today.month, today.day))
        .get();

    if (attendanceSnapshot.docs.isEmpty) {
      _checkInTime = DateTime.now();
      Position position = await _determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String placeName = placemarks.first.locality ?? "Unknown";

      setState(() {
        _isCheckedIn = true;
        _location = placeName;
        _isPunchInButtonEnabled = false;
      });

      await _firestore.collection('attendance').add({
        'hkUserId': widget.hkUserId,
        'checkInTime': _checkInTime,
        'checkOutTime': null,
        'workingHours': 0,
        'checkInLocation': _location,
        'checkInCoordinates': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });

      Future.delayed(Duration(minutes: 1), () {
        setState(() {
          _isPunchInButtonEnabled = true;
        });
      });
    } else {
      _showMessage(S.current.youHaveAlreadyCheckedIn);
    }
  }

  Future<void> _checkOut() async {
    if (_isCheckedIn) {
      _checkOutTime = DateTime.now();
      Position position = await _determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String placeName = placemarks.first.locality ?? "Unknown";

      if (_checkInTime != null) {
        _workingHours = _checkOutTime!.difference(_checkInTime!);
      }

      setState(() {
        _isCheckedIn = false;
        _location = placeName;
      });

      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('hkUserId', isEqualTo: widget.hkUserId)
          .where('checkOutTime', isNull: true)
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        await _firestore
            .collection('attendance')
            .doc(attendanceSnapshot.docs[0].id)
            .update({
          'checkOutTime': _checkOutTime,
          'workingHours': _workingHours?.inMinutes,
          'checkOutLocation': _location,
          'checkOutCoordinates': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        });
      }
    } else {
      _showMessage(S.current.youMustCheckInBeforeCheckingOut);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(
          'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      _showMessage('Failed to get current location: $e');
      return Future.error('Failed to get current location: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget buildCheckInOutButton() {
    return SizedBox(
      width: 140,
      height: 140,
      child: ElevatedButton(
        onPressed: _isPunchInButtonEnabled
            ? (_isCheckedIn ? _checkOut : _checkIn)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
          shape: CircleBorder(),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            _isCheckedIn ? S.current.punchOut : S.current.punchIn,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildAttendanceInfo() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('hh:mm a').format(DateTime.now()),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '${S.current.location} $_location',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCheckInOutInfo() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildClockCard(S.current.checkIn, _checkInTime),
            buildClockCard(S.current.checkOut, _checkOutTime),
            buildWorkingHoursCard(),
          ],
        ),
      ),
    );
  }

  Widget buildClockCard(String label, DateTime? time) {
    return Column(
      children: [
        Icon(Icons.access_time, color: Colors.grey),
        Text(
          time != null ? DateFormat('hh:mm a').format(time) : 'N/A',
          style: TextStyle(fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget buildWorkingHoursCard() {
    return Column(
      children: [
        Icon(Icons.timer, color: Colors.grey),
        Text(
          _workingHours != null
              ? "${_workingHours!.inHours}h ${_workingHours!.inMinutes % 60}m"
              : 'N/A',
          style: TextStyle(fontSize: 16),
        ),
        Text(S.current.workingHours, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildAttendanceInfo(),
          buildCheckInOutInfo(),
          const SizedBox(height: 20),
          buildCheckInOutButton(),
        ],
      ),
    );
  }
}

class RoomsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userAccountType; // Add this line to pass the userAccountType
  String _localizeRoomType(String roomType, Locale locale) {
    if (locale.languageCode == 'ar') {
      switch (roomType) {
        case 'Room':
          return 'غرفة';
        case 'Suite':
          return 'جناح';
        case 'Mini Suite':
          return 'ميني جناح';
        default:
          return roomType;
      }
    }
    return roomType;
  }

  String convertNumberToArabic(String number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.replaceAllMapped(RegExp(r'\d'), (match) {
      return arabicDigits[int.parse(match.group(0)!)];
    });
  }
  // Method to localize cleaning status
  String _localizeCleaningStatus(String status, Locale locale) {
    if (locale.languageCode == 'ar') {
      switch (status) {
        case 'Dirty':
          return 'متسخ';
        case 'Clean':
          return 'نظيف';
        default:
          return status;
      }
    }
    return status;
  }

  String getLocalizedNumber(String number) {
    if (Intl.getCurrentLocale() == 'ar') {
      return convertNumberToArabic(number);
    }
    return number;
  }



  RoomsPage(
      {this.userAccountType}); // Modify the constructor to accept userAccountType

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('rooms')
          .where('cleaningStatus', isEqualTo: 'Dirty')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              S.current.noRoomsNeedCleaning,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          );
        }
        return ListView(
          children: snapshot.data!.docs.map((roomDoc) {
            String roomId = roomDoc.id;
            String roomNumber = roomDoc['roomNumber'];
            String roomType = roomDoc['roomType'];
            String cleaningStatus = roomDoc['cleaningStatus'];
            String localizedRoomType = _localizeRoomType(roomType, locale);
            // Use the new method to localize the room number
            String localizedRoomNumber = getLocalizedNumber(roomNumber);
            String localizedCleaningStatus = _localizeCleaningStatus(cleaningStatus, locale);

            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$localizedRoomType:  $localizedRoomNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      localizedCleaningStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: cleaningStatus == 'Dirty'
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                trailing: userAccountType == 'HK Staff'
                    ? CircleAvatar(
                        backgroundColor: cleaningStatus == 'Clean'
                            ? Colors.green
                            : Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.check, color: Colors.white),
                          onPressed: () {
                            bool isClean = cleaningStatus == 'Dirty';
                            _updateRoomStatus(roomId, isClean);
                          },
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _updateRoomStatus(String roomId, bool isClean) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'cleaningStatus': isClean ? 'Clean' : 'Dirty',
    });
  }
}

class RequestsPage extends StatefulWidget {
  final String? userAccountType;

  RequestsPage({this.userAccountType});

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  TextEditingController requestController = TextEditingController();
  String? userAccountType;

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _addRequest(String description) {
    _firestore.collection('requests').add({
      'description': description,
      'status': 'Pending',
      'date': _selectedDate,
    });
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _firestore
        .collection('requests')
        .doc(requestId)
        .update({'status': status});
  }

  Timestamp getStartOfDay(DateTime date) {
    return Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 0, 0, 0));
  }

  Timestamp getEndOfDay(DateTime date) {
    return Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.userAccountType == 'HK Staff') // Display only for HK Staff
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: requestController,
                    decoration: InputDecoration(
                      labelText: S.current.addRequest,
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (requestController.text.isNotEmpty) {
                            _addRequest(requestController.text);
                            requestController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.userAccountType != 'HK Staff') Spacer(),
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              onPressed: _pickDate,
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('requests')
                .where('timestamp',
                    isGreaterThanOrEqualTo: getStartOfDay(_selectedDate))
                .where('timestamp',
                    isLessThanOrEqualTo: getEndOfDay(_selectedDate))
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  String requestId = doc.id;
                  String description = doc['description'];
                  String status = doc['status'];

                  String localizedStatus;
                  switch (status) {
                    case 'Pending':
                      localizedStatus = S.current.pending;
                      break;
                    case 'In Progress':
                      localizedStatus = S.current.inProgress;
                      break;
                    case 'Completed':
                      localizedStatus = S.current.completed;
                      break;
                    default:
                      localizedStatus = status;
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(description),
                      subtitle: Text('${S.current.status}: $localizedStatus'),
                      // ... existing code ...
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.userAccountType == 'HK Staff' ||
                              widget.userAccountType == 'Front Desk')
                            DropdownButton<String>(
                              value: status,
                              items: [
                                DropdownMenuItem(
                                  value: 'Pending',
                                  child: Text(S.current.pending,
                                      style: TextStyle(color: Colors.orange)),
                                ),
                                DropdownMenuItem(
                                  value: 'In Progress',
                                  child: Text(S.current.inProgress,
                                      style: TextStyle(color: Colors.blue)),
                                ),
                                DropdownMenuItem(
                                  value: 'Completed',
                                  child: Text(S.current.completed,
                                      style: TextStyle(color: Colors.green)),
                                ),
                              ],
                              onChanged: (String? newStatus) async {
                                if (newStatus != null) {
                                  await _updateRequestStatus(
                                      requestId, newStatus);
                                }
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _firestore
                                  .collection('requests')
                                  .doc(requestId)
                                  .delete();
                              setState(() {
                                snapshot.data!.docs
                                    .removeWhere((doc) => doc.id == requestId);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AssignedNotesPage extends StatefulWidget {
  @override
  _AssignedNotesPageState createState() => _AssignedNotesPageState();
}

class _AssignedNotesPageState extends State<AssignedNotesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  String? userAccountType;

  String convertNumberToArabic(String number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.replaceAllMapped(RegExp(r'\d'), (match) {
      return arabicDigits[int.parse(match.group(0)!)];
    });
  }

  String getLocalizedNumber(String number) {
    if (Intl.getCurrentLocale() == 'ar') {
      return convertNumberToArabic(number);
    }
    return number;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAssignedNotes(DateTime date) async {
    try {
      DateTime selectedDay = DateTime(date.year, date.month, date.day);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('assignedToHK', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> notes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        DateTime checkInDate =
            (data['checkInDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        DateTime checkOutDate =
            (data['checkOutDate'] as Timestamp?)?.toDate() ?? DateTime.now();

        checkInDate =
            DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
        checkOutDate =
            DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

        return {
          'docId': doc.id, // Include the document ID
          'reservationId': data['reservationId']?.toString() ?? 'Unknown',
          'room': data['room']?.toString() ?? 'Unknown Room',
          'text': data['text'] ?? 'No requests',
          'frequency': data['frequency'] ?? 'justOnce',
          'checkInDate': checkInDate,
          'guestName': data['guestName'] ?? 'Unknown Guest',
          'checkOutDate': checkOutDate,
          'status': data['status'] ?? 'Pending',
          'assignedToHK': data['assignedToHK'] ?? false,
        };
      }).where((note) {
        DateTime checkIn = note['checkInDate'];
        DateTime checkOut = note['checkOutDate'];
        String frequency = note['frequency'];

        bool isWithinDateRange =
            !checkIn.isAfter(selectedDay) && !checkOut.isBefore(selectedDay);
        bool isDailyNote = frequency == 'Daily';
        bool isJustOnceNote = frequency == 'Just Once' &&
            (selectedDay.isAtSameMomentAs(checkIn) ||
                selectedDay.isAtSameMomentAs(checkOut));

        return isWithinDateRange && (isJustOnceNote || isDailyNote);
      }).toList();

      return notes;
    } catch (e) {
      print("Error fetching notes: $e");
      return [];
    }
  }

  Future<void> _updateNoteStatus(String reservationId, String newStatus) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'notes.status': newStatus,
    });
  }

  String _validateStatus(String? status) {
    if (status != 'Pending' &&
        status != 'In Progress' &&
        status != 'Completed') {
      return 'Pending';
    }
    return status ?? 'Pending';
  }

  String _mapStatusToLocalizedText(String status) {
    switch (status) {
      case 'Pending':
        return S.current.pending;
      case 'In Progress':
        return S.current.inProgress;
      case 'Completed':
        return S.current.completed;
      default:
        return S.current.pending;
    }
  }

  String _mapFrequencyToLocalizedText(String frequency) {
    switch (frequency) {
      case 'Daily':
        return S.current.daily;
      case 'Once':
        return S.current.justOnce;
      default:
        return S.current.justOnce;
    }
  }

  List<DropdownMenuItem<String>> _buildStatusDropdownItems() {
    return [
      DropdownMenuItem(value: 'Pending', child: Text(S.current.pending)),
      DropdownMenuItem(value: 'In Progress', child: Text(S.current.inProgress)),
      DropdownMenuItem(value: 'Completed', child: Text(S.current.completed)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFDBB017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // Make AppBar background transparent
        elevation: 0,
        // Remove default AppBar shadow
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: const Color(0xFFDBB017)),
                    SizedBox(width: 5),
                    Text(
                      '${DateFormat('yyyy - MM - dd').format(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDBB017),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(6),
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
                  child: Icon(Icons.calendar_today,
                      color: const Color(0xFFDBB017)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAssignedNotes(_selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                S.current.noassignednotes,
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var note = snapshot.data![index];
                String? status = note['status'];
                String docId = note['docId'] ?? '';

                status = _validateStatus(status);
                String localizedStatus = _mapStatusToLocalizedText(status);
                String frequency = note['frequency'] ?? '';
                String localizedFrequency =
                    _mapFrequencyToLocalizedText(frequency);

                String roomNumber = note['room'];
                // Use the new method to localize the room number
                String localizedRoomNumber = getLocalizedNumber(roomNumber);
                return Card(
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      '${note['text']}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${S.current.frequency}: $localizedFrequency',style: TextStyle(fontSize: 18,),),
                        SizedBox(height: 4),
                        Text(
                            '${S.current.guestNameLabel}: ${note['guestName']}',style: TextStyle(fontSize: 18,),),
                        SizedBox(height: 4),
                        Text('${S.current.room}:$localizedRoomNumber',style: TextStyle(fontSize: 18,),),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${S.current.status}: $localizedStatus',style: TextStyle(fontSize: 18,),),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await _firestore
                                      .collection('notes')
                                      .doc(docId)
                                      .delete();
                                  setState(() {
                                    snapshot.data!.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Note Deleted')),
                                  );
                                } catch (e) {
                                  print("Error deleting note: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(S.current.errorMessage)),
                                  );
                                }
                              },
                            ),
                            if (userAccountType == 'HK Staff')
                              DropdownButton<String>(
                                value: status,
                                items: _buildStatusDropdownItems(),
                                onChanged: (String? newStatus) async {
                                  if (newStatus != null &&
                                      newStatus != status) {
                                    await _updateNoteStatus(docId, newStatus);
                                    setState(() {});
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FrontDeskRequestsPage extends StatefulWidget {
  @override
  _FrontDeskRequestsPageState createState() => _FrontDeskRequestsPageState();
}

class _FrontDeskRequestsPageState extends State<FrontDeskRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  String? userAccountType;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFrontDeskRequestsForDate(
      DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final querySnapshot = await _firestore
          .collection('frontdeskRequest')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'docId': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print("Error fetching front desk requests: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBB017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // Make AppBar background transparent
        elevation: 0,
        // Remove default AppBar shadow
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: const Color(0xFFDBB017)),
                    SizedBox(width: 5),
                    Text(
                      '${DateFormat('yyyy - MM - dd').format(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDBB017),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(6),
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
                  child: Icon(Icons.calendar_today,
                      color: const Color(0xFFDBB017)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFrontDeskRequestsForDate(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      S.current.nofrontdeskrequests,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data![index];
                    String status = request['status'] ?? 'Pending';
                    String docId = request['docId'] ?? '';

                    String localizedStatus;
                    switch (status) {
                      case 'Pending':
                        localizedStatus = S.current.pending;
                        break;
                      case 'In Progress':
                        localizedStatus = S.current.inProgress;
                        break;
                      case 'Completed':
                        localizedStatus = S.current.completed;
                        break;
                      default:
                        localizedStatus = status;
                    }

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          '${request['requestDetail']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${S.current.status}: $localizedStatus',style: TextStyle(fontSize: 18,),),
                                if (userAccountType == 'HK Staff')
                                  DropdownButton<String>(
                                    value: status,
                                    items: [
                                      DropdownMenuItem(
                                        value: 'Pending',
                                        child: Text(S.current.pending,
                                            style: TextStyle(
                                                color: Colors.orange)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'In Progress',
                                        child: Text(S.current.inProgress,
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Completed',
                                        child: Text(S.current.completed,
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ),
                                    ],
                                    onChanged: (String? newStatus) async {
                                      if (newStatus != null &&
                                          newStatus != status &&
                                          docId.isNotEmpty) {
                                        await _firestore
                                            .collection('frontdeskRequest')
                                            .doc(docId)
                                            .update({'status': newStatus});
                                        setState(() {});
                                      }
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    if (docId.isNotEmpty) {
                                      await _firestore
                                          .collection('frontdeskRequest')
                                          .doc(docId)
                                          .delete();
                                      setState(() {
                                        snapshot.data!.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
