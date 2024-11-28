import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/widgets/rooms_widgets/add_room_dialouge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String getLocalizedText(String text) {
    if (Intl.getCurrentLocale() == 'ar') {
      const textDictionary = {
        'Single': 'فردي',
        'Double': 'مزدوج',
        'Suite': 'جناح',
        'Mini Suite': 'ميني جناح',
        'Room': 'غرفة',
        'Available': 'متاح',
        'Occupied': 'مشغول',
        'Dirty': 'متسخ',
        'Clean': 'نظيف',
        // Add more translations as needed
      };
      return textDictionary[text] ?? text;
    }
    return text;
  }


class RoomsScreen extends StatefulWidget {
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String selectedStatus = 'All';
  TextEditingController searchController = TextEditingController();
  String? userAccountType;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final statusOptions = {
    'All': S.current.all,
    'Available': S.current.available,
    'Occupied': S.current.occupied,
    'Dirty': S.current.dirty,
    'Clean': S.current.clean,
  };

  String getLocalizedFacility(String facility) {
    if (Intl.getCurrentLocale() == 'ar') {
      const facilityDictionary = {
        'WiFi': 'واي فاي',
        'TV': 'تلفاز',
        'Mini-bar': 'ميني بار',
        'AC': 'مكيف',
        'Fridge': 'ثلاجة',
      };
      return facilityDictionary[facility] ?? facility;
    }
    return facility;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getUserAccountType();
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
          userAccountType = userDoc['accountType'];
        });
      }
    }
  }

  Future<void> _getUserAccountType() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      final userDoc = await _firestore
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
        title: Text(
          S.current.roomManagement,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Amiri',),
        ),
        backgroundColor: const Color(0xFFDBB017),
        actions: [
          if (userAccountType == 'Admin' || userAccountType == 'Manager')
            Card(
              elevation: 2,
              // Optional: Adjust the elevation for a shadow effect
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Optional: Add rounded corners
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDBB017),
                  // Set the background color of the button
                  padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12), // Optional: Add padding for a better look
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text(
                  S.current.addNewRoom,
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddRoomDialog(
                      onRoomAdded: (room) async {
                        await FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(room['roomNumber'])
                            .set(room);
                      },
                    ),
                  );
                },
              ),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchAndFilter(),
              const SizedBox(height: 20),
              _buildRoomDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  // Build the search and filter row
  Row _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: S.current.searchBy,
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
            items: statusOptions.keys.map((key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(statusOptions[key]!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
            decoration: InputDecoration(
              labelText: S.current.filterByStatus,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
        ),
      ],
    );
  }


  // Build the room data table with scrollable functionality
  Widget _buildRoomDataTable() {
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final roomsData = roomSnapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('reservations').snapshots(),
          builder: (context, reservationSnapshot) {
            if (!reservationSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reservationData = reservationSnapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            final filteredData = _filterRooms(roomsData, reservationData);

            // Check screen width to determine layout
            if (screenWidth > 600) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: screenWidth,
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
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => const Color(0xFFDBB017)),
                    columnSpacing: 20.0,
                    horizontalMargin: 12.0,
                    columns: _buildTableColumns(),
                    rows: filteredData.map((room) {
                      String facilities =
                          (room['roomFacility'] is Map<String, dynamic>)
                              ? (room['roomFacility'] as Map<String, dynamic>)
                                  .entries
                                  .where((entry) => entry.value == true)
                                  .map((entry) => entry.key)
                                  .join(', ')
                              : 'None';

                      return DataRow(cells: _buildTableCells(room, facilities));
                    }).toList(),
                  ),
                ),
              );
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => const Color(0xFFDBB017)),
                    columnSpacing: 20.0,
                    horizontalMargin: 12.0,
                    columns: _buildTableColumns(),
                    rows: filteredData.map((room) {
                      String facilities =
                          (room['roomFacility'] is Map<String, dynamic>)
                              ? (room['roomFacility'] as Map<String, dynamic>)
                                  .entries
                                  .where((entry) => entry.value == true)
                                  .map((entry) => entry.key)
                                  .join(', ')
                              : 'None';

                      return DataRow(cells: _buildTableCells(room, facilities));
                    }).toList(),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  // Table column headers
  List<DataColumn> _buildTableColumns() {
    return [
      DataColumn(
          label: Text(S.current.roomNumber,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.bedType,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.roomType,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.roomFloor,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.facilities,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.status,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.cleaningStatus,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
      DataColumn(
          label: Text(S.current.currentGuest,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 20),)),
    ];
  }

  // Table row data based on room and facilities
  List<DataCell> _buildTableCells(
      Map<String, dynamic> room, String facilities) {
    String localizedFacilities = facilities.split(', ').map((facility) {
      return getLocalizedFacility(facility);
    }).join(', ');
    String noGuestText = Intl.getCurrentLocale() == 'ar' ? 'لا يوجد' : 'None';

    return [
      DataCell(Text(getLocalizedNumber(room['roomNumber']),style: TextStyle(fontSize: 16,),)),
      DataCell(Text(getLocalizedText(room['bedType']),style: TextStyle(fontSize: 16,),)),
      DataCell(Text(getLocalizedText(room['roomType']),style: TextStyle(fontSize: 16,),)),
      DataCell(Text(getLocalizedNumber(room['roomFloor'].toString()),style: TextStyle(fontSize: 16,),)),
      DataCell(Text(localizedFacilities.isNotEmpty ? localizedFacilities : noGuestText,style: TextStyle(fontSize: 16,),)),
      DataCell(
        Text(
          getLocalizedText(room['status']),
          style: TextStyle(
            color: room['status'] == 'Available' ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      DataCell(Text(getLocalizedText(room['cleaningStatus'] ?? 'N/A'),style: TextStyle(fontSize: 16,),)),
      DataCell(Text(room['currentGuest'] ?? 'None',style: TextStyle(fontSize: 16,),),),
    ];
  }

  List<Map<String, dynamic>> _filterRooms(List<Map<String, dynamic>> rooms,
      List<Map<String, dynamic>> reservations) {
    DateTime now = DateTime.now();
    // Mark each room based on active reservations
    for (var room in rooms) {
      bool isOccupied = false;
      DateTime? lastCheckOutAt1PM;
      for (var reservation in reservations) {
        DateTime checkInDate =
        (reservation['checkInDate'] as Timestamp).toDate();
        DateTime checkOutDate =
        (reservation['checkOutDate'] as Timestamp).toDate();
        DateTime checkOutAt1PM = DateTime(
          checkOutDate.year,
          checkOutDate.month,
          checkOutDate.day,
          13,
          0,
          0,
        );
        if (reservation['roomNumber'] == room['roomNumber'] &&
            now.isAfter(checkInDate) &&
            now.isBefore(checkOutAt1PM)) {
          room['status'] = 'Occupied';
          isOccupied = true;
          break;
        }
        lastCheckOutAt1PM = checkOutAt1PM;
      }
      if (!isOccupied) {
        room['status'] = 'Available';
        room['currentGuest'] = 'None';
        if (lastCheckOutAt1PM != null && now.isAfter(lastCheckOutAt1PM)) {
          room['cleaningStatus'] = 'Dirty';
        }
      }
    }
    return rooms.where((room) {
      // Filter rooms by status or cleaning status if not 'All'
      if (selectedStatus != 'All' &&
          room['status'] != selectedStatus &&
          room['cleaningStatus'] != selectedStatus) {
        return false;
      }
      // Filter rooms by search keyword (room number, bed type, or floor)
      String searchText = searchController.text.toLowerCase();
      return room['roomNumber'].toString().toLowerCase().contains(searchText) ||
          room['bedType'].toString().toLowerCase().contains(searchText) ||
          room['roomFloor'].toString().toLowerCase().contains(searchText);
    }).toList();
  }
}
