import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HKScreen extends StatefulWidget {
  @override
  _HKScreenState createState() => _HKScreenState();
}

class _HKScreenState extends State<HKScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Duration? _workingHours;

  String hkUserId = "";
  String hkName = "";
  String _location = "Unknown";
  String? userAccountType;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkForTodayAttendance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationServices();
    });
  }

  Future<void> _initializeLocationServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage("Location services are disabled.");
      }
    } catch (e) {
      _showMessage("Location services are not available on this platform.");
    }
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final email = currentUser.email;

      final userQuery = await FirebaseFirestore.instance
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

  Future<void> _checkForTodayAttendance() async {
    final today = DateTime.now();
    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('hkUserId', isEqualTo: hkUserId)
        .where('checkInTime', isGreaterThan: DateTime(today.year, today.month, today.day))
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      final doc = attendanceSnapshot.docs.first;
      setState(() {
        _isCheckedIn = doc['checkOutTime'] == null;
        _checkInTime = (doc['checkInTime'] as Timestamp).toDate();
        _checkOutTime = doc['checkOutTime'] != null ? (doc['checkOutTime'] as Timestamp).toDate() : null;
        _workingHours = _checkOutTime != null ? _checkOutTime!.difference(_checkInTime!) : null;
        _location = doc['checkInLocation'] ?? "Unknown";
      });
    }
  }

  Future<void> _checkIn() async {
    final today = DateTime.now();
    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('hkUserId', isEqualTo: hkUserId)
        .where('checkInTime', isGreaterThan: DateTime(today.year, today.month, today.day))
        .get();

    if (attendanceSnapshot.docs.isEmpty) {
      _checkInTime = DateTime.now();
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String placeName = placemarks.first.locality ?? "Unknown";

      setState(() {
        _isCheckedIn = true;
        _location = placeName;
      });

      await FirebaseFirestore.instance.collection('attendance').add({
        'hkUserId': hkUserId,
        'hkName': hkName,
        'checkInTime': _checkInTime,
        'checkOutTime': null,
        'workingHours': 0,
        'checkInLocation': _location,
        'checkInCoordinates': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });
    } else {
      _showMessage('You have already checked in today.');
    }
  }

  Future<void> _checkOut() async {
    if (_isCheckedIn) {
      _checkOutTime = DateTime.now();
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String placeName = placemarks.first.locality ?? "Unknown";

      if (_checkInTime != null) {
        _workingHours = _checkOutTime!.difference(_checkInTime!);
      }

      setState(() {
        _isCheckedIn = false;
        _location = placeName;
      });

      final attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('hkUserId', isEqualTo: hkUserId)
          .where('checkOutTime', isNull: true)
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
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
      _showMessage('You must check in before checking out.');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              'Location: $_location',
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
            buildClockCard('Check In', _checkInTime),
            buildClockCard('Check Out', _checkOutTime),
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
        Text('Working Hrs', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _updateRoomStatus(String roomId, bool isClean) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'cleaningStatus': isClean ? 'Clean' : 'Dirty',
    });
  }

  Future<void> _addRequest(String requestDescription) async {
    await FirebaseFirestore.instance.collection('requests').add({
      'hkUserId': hkUserId,
      'hkName': hkName,
      'description': requestDescription,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({'status': status});
  }

  Widget buildRequestsPage() {
    TextEditingController requestController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: requestController,
            decoration: InputDecoration(
              labelText: 'Add Request',
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('hkUserId', isEqualTo: hkUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  String requestId = doc.id;
                  String description = doc['description'];
                  String status = doc['status'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(description),
                      subtitle: Text('Status: $status'),
                      trailing: DropdownButton<String>(
                        value: status,
                        items: [
                          DropdownMenuItem(
                            value: 'Pending',
                            child: Text('Pending', style: TextStyle(color: Colors.orange)),
                          ),
                          DropdownMenuItem(
                            value: 'In Progress',
                            child: Text('In Progress', style: TextStyle(color: Colors.blue)),
                          ),
                          DropdownMenuItem(
                            value: 'Completed',
                            child: Text('Completed', style: TextStyle(color: Colors.green)),
                          ),
                        ],
                        onChanged: (String? newStatus) {
                          if (newStatus != null) {
                            _updateRequestStatus(requestId, newStatus);
                          }
                        },
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

  Widget buildCheckInOutButton() {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: _isCheckedIn ? _checkOut : _checkIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
          shape: CircleBorder(),
        ),
        child: Text(
          _isCheckedIn ? 'Punch Out' : 'Punch In',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildRoomsPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .where('cleaningStatus', isEqualTo: 'Dirty')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No rooms need cleaning!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView(
          children: snapshot.data!.docs.map((roomDoc) {
            String roomId = roomDoc.id;
            String roomNumber = roomDoc['roomNumber'];
            String cleaningStatus = roomDoc['cleaningStatus'];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room: $roomNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      cleaningStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: cleaningStatus == 'Dirty' ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
                trailing: userAccountType == 'HK Staff'
                    ? CircleAvatar(
                  backgroundColor: cleaningStatus == 'Clean' ? Colors.green : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBB017),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFDBB017),
        elevation: 0,
        title: Text(
          'Hello, $hkName! 👋',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (userAccountType == 'Admin' || userAccountType == 'Manager' || userAccountType == 'HK Staff')
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
          if (userAccountType != 'Front Desk')
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildAttendanceInfo(),
                  buildCheckInOutInfo(),
                  const SizedBox(height: 20),
                  if (userAccountType == 'Admin' || userAccountType == 'Manager' || userAccountType == 'HK Staff')
                    buildCheckInOutButton(),
                ],
              ),
            ),
          buildRoomsPage(),
          buildRequestsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          if (userAccountType != 'Front Desk')
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: 'Rooms',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Requests',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}