import 'package:elitehotel/widgets/rooms_widgets/add_room_dialouge.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomsScreen extends StatefulWidget {
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String selectedStatus = 'All';
  TextEditingController searchController = TextEditingController();
  String? userAccountType;

  @override
  void initState() {
    super.initState();
    _getUserAccountType();
  }

  Future<void> _getUserAccountType() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          userAccountType = userDoc.docs.first['accountType'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Room Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFDBB017),
        actions: [
          if (userAccountType == 'Admin' || userAccountType == 'Manager')
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Room', style: TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddRoomDialog(onRoomAdded: (room) async {
                    await FirebaseFirestore.instance.collection('rooms').doc(room['roomNumber']).set(room);
                  }),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            _buildRoomDataTable(),
          ],
        ),
      ),
    );
  }

  Row _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search by room number, bed type, or floor',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild to update the filter
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: ['All', 'Available', 'Occupied', 'Maintenance', 'Dirty', 'Clean']
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDataTable() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, roomSnapshot) {
          if (!roomSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomsData = roomSnapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
            builder: (context, reservationSnapshot) {
              if (!reservationSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final reservationData = reservationSnapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
              final filteredData = _filterRooms(roomsData, reservationData);

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFFDBB017)),
                    columnSpacing: 20.0,
                    horizontalMargin: 12.0,
                    columns: const [
                      DataColumn(label: Text('Room Number', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Bed Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Room Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Room Floor', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Cleaning Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Current Guest', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredData.map((room) {
                      String facilities = (room['roomFacility'] is Map<String, dynamic>)
                          ? (room['roomFacility'] as Map<String, dynamic>)
                          .entries
                          .where((entry) => entry.value == true)
                          .map((entry) => entry.key)
                          .join(', ')
                          : 'None';

                      return DataRow(cells: [
                        DataCell(Text(room['roomNumber'])),
                        DataCell(Text(room['bedType'])),
                        DataCell(Text(room['roomType'])),
                        DataCell(Text(room['roomFloor'].toString())),
                        DataCell(Text(facilities.isNotEmpty ? facilities : 'None')),
                        DataCell(
                          Text(
                            room['status'],
                            style: TextStyle(
                              color: room['status'] == 'Available' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(Text(room['cleaningStatus'] ?? 'N/A')),
                        DataCell(Text(room['currentGuest'] ?? 'None')),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterRooms(List<Map<String, dynamic>> rooms, List<Map<String, dynamic>> reservations) {
    DateTime now = DateTime.now();

    for (var room in rooms) {
      bool isOccupied = reservations.any((reservation) {
        return reservation['roomNumber'] == room['roomNumber'] &&
            now.isAfter((reservation['checkInDate'] as Timestamp).toDate()) &&
            now.isBefore((reservation['checkOutDate'] as Timestamp).toDate());
      });
      room['status'] = isOccupied ? 'Occupied' : 'Available';
    }

    return rooms.where((room) {
      bool matchesStatus = selectedStatus == 'All' || room['status'] == selectedStatus ||
          (selectedStatus == 'Clean' && room['cleaningStatus'] == 'Clean') ||
          (selectedStatus == 'Dirty' && room['cleaningStatus'] == 'Dirty');

      String searchQuery = searchController.text.toLowerCase();
      bool matchesSearch = room['roomNumber'].toLowerCase().contains(searchQuery) ||
          room['bedType'].toLowerCase().contains(searchQuery) ||
          room['roomFloor'].toString().toLowerCase().contains(searchQuery);

      return matchesStatus && matchesSearch;
    }).toList();
  }
}