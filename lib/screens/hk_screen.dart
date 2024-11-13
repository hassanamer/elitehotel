import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        _showMessage(S.current.locationServicesDisabled);
      }
    } catch (e) {
      _showMessage("Location services are not available on this platform.");
    }
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

  Future<void> _checkForTodayAttendance() async {
    final today = DateTime.now();
    final attendanceSnapshot = await _firestore
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
    final attendanceSnapshot = await _firestore
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

      await _firestore.collection('attendance').add({
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
      _showMessage(S.current.youHaveAlreadyCheckedIn);
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

      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('hkUserId', isEqualTo: hkUserId)
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
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
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

  Future<void> _updateRoomStatus(String roomId, bool isClean) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'cleaningStatus': isClean ? 'Clean' : 'Dirty',
    });
  }

  Future<void> _addRequest(String requestDescription) async {
    await _firestore.collection('requests').add({
      'hkUserId': hkUserId,
      'hkName': hkName,
      'description': requestDescription,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({'status': status});
  }



  Widget buildCheckInOutButton() {
    return SizedBox(
      width: 140,
      height: 140,
      child: ElevatedButton(
        onPressed: _isCheckedIn ? _checkOut : _checkIn,
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

  Widget buildRoomsPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('rooms')
          .where('cleaningStatus', isEqualTo: 'Dirty') // Fetch only dirty rooms
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
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

  Widget buildRequestsPage() {
    TextEditingController requestController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('requests')
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
                      subtitle: Text('${S.current.status}: $status'),
                      trailing: DropdownButton<String>(
                        value: status,
                        items: [
                          DropdownMenuItem(
                            value: 'Pending',
                            child: Text(S.current.pending, style: TextStyle(color: Colors.orange)),
                          ),
                          DropdownMenuItem(
                            value: 'In Progress',
                            child: Text(S.current.inProgress, style: TextStyle(color: Colors.blue)),
                          ),
                          DropdownMenuItem(
                            value: 'Completed',
                            child: Text(S.current.completed, style: TextStyle(color: Colors.green)),
                          ),
                        ],
                        onChanged: (String? newStatus) async {
                          if (newStatus != null) {
                            await _updateRequestStatus(requestId, newStatus);
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
  Future<void> _updateNoteStatus(String reservationId, String newStatus) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'notes.status': newStatus,
    });
  }

  Widget buildAssignedNotesPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAssignedNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(S.current.noassignednotes));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var note = snapshot.data![index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  '${note['text']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Frequency: ${note['frequency']}'),
                    Text('Guest: ${note['guestName']}'),
                    Text('Room: ${note['roomNumber']}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (userAccountType == 'HK Staff')
                        Text('${S.current.status}:'),
                        if (userAccountType == 'HK Staff')
                          DropdownButton<String>(
                          value: note['status'] ?? 'Pending', // Provide a default value
                          items: [S.current.pending, S.current.inProgress, S.current.completed]
                              .map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (newStatus) async {
                            if (newStatus != null) {
                              await _updateNoteStatus(note['reservationId'], newStatus);
                              setState(() {}); // Refresh the UI after updating
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
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAssignedNotes() async {
    final notesSnapshot = await _firestore
        .collection('reservations')
        .where('notes.assignedToHK', isEqualTo: true)
        .get();

    return notesSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'reservationId': doc.id,
        'frequency': data['frequency'] ?? 'Once',
        'text': data['notes']['text'] ?? '',
        'status': data['notes']['status'],
        'guestName': data['guestName'],
        'roomNumber': data['roomNumber'],
      };
    }).toList();
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
          buildAssignedNotesPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFFDBB017),
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: TextStyle(color: Colors.black),
        items: [
          if (userAccountType != 'Front Desk')
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
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}