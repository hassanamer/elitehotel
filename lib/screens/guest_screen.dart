import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuestScreen extends StatefulWidget {
  @override
  _GuestScreenState createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  String selectedStatus = 'All';
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> guestData = [];
  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    fetchGuestData();
  }

  Future<void> fetchGuestData() async {
    try {
      QuerySnapshot reservationSnapshot =
          await FirebaseFirestore.instance.collection('reservations').get();
      QuerySnapshot roomSnapshot =
          await FirebaseFirestore.instance.collection('rooms').get();

      List<Map<String, dynamic>> roomsData = roomSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      DateTime today = DateTime.now();

      setState(() {
        guestData = reservationSnapshot.docs.map((doc) {
          Map<String, dynamic> reservationData =
              doc.data() as Map<String, dynamic>;
          Map<String, dynamic>? roomInfo = roomsData.firstWhere(
            (room) => room['roomNumber'] == reservationData['roomNumber'],
            orElse: () => {},
          );

          DateTime? checkInDate =
              (reservationData['checkInDate'] as Timestamp).toDate();
          DateTime? checkOutDate =
              (reservationData['checkOutDate'] as Timestamp).toDate();

          String checkInOutStatus;
          if (today.isBefore(checkInDate)) {
            checkInOutStatus = 'Upcoming';
          } else if (today.isAfter(checkOutDate)) {
            checkInOutStatus = 'Checked Out';
          } else if (today.isAtSameMomentAs(checkInDate) ||
              (today.isAfter(checkInDate) && today.isBefore(checkOutDate))) {
            checkInOutStatus = 'Checked In';
          } else {
            checkInOutStatus = 'Unknown';
          }

          return {
            'reservationId': reservationData['reservationId'] ?? 'Unknown',
            'name': reservationData['guestName'] ?? 'Unknown',
            'roomNumber': reservationData['roomNumber'] ?? 'Unknown',
            'totalAmount': reservationData['totalCost']?.toString() ?? '0',
            'amountPaid': reservationData['amountPaid']?.toString() ?? '0',
            'status': roomInfo['status'] ?? 'Unknown',
            'checkInOut': checkInOutStatus,
          };
        }).toList();

        filteredData = guestData;
      });
    } catch (e) {
      print("Error fetching guest data: $e");
    }
  }

  void filterData() {
    String searchQuery = searchController.text.toLowerCase();
    setState(() {
      filteredData = guestData.where((guest) {
        bool matchesStatus =
            selectedStatus == 'All' || guest['checkInOut'] == selectedStatus;
        bool matchesSearch =
            (guest['name']?.toString().toLowerCase().contains(searchQuery) ??
                    false) ||
                (guest['reservationId']
                        ?.toString()
                        .toLowerCase()
                        .contains(searchQuery) ??
                    false) ||
                (guest['roomNumber']
                        ?.toString()
                        .toLowerCase()
                        .contains(searchQuery) ??
                    false);
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Occupied':
        return Colors.red;
      case 'Checked In':
        return Colors.green;
      case 'Checked Out':
        return Colors.red;
      case 'Upcoming':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Guest Management',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFDBB017),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by name, ID, or room',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => filterData(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['All', 'Checked In', 'Checked Out', 'Upcoming']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          filterData();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
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
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => const Color(0xFFDBB017)),
                      columnSpacing: 20.0,
                      horizontalMargin: 12.0,
                      columns: const [
                        DataColumn(
                            label: Text('Reservation ID',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Name',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Room Number',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Total Amount',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Amount Paid',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Status',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Check-In/Out',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: filteredData.map((guest) {
                        return DataRow(cells: [
                          DataCell(Text(guest['reservationId'].toString())),
                          DataCell(Text(guest['name']!)),
                          DataCell(Text(guest['roomNumber']!)),
                          DataCell(Text('\$${guest['totalAmount']}')),
                          DataCell(Text('\$${guest['amountPaid']}')),
                          DataCell(
                            Text(
                              guest['status']!,
                              style: TextStyle(
                                color: getStatusColor(guest['status']!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              guest['checkInOut']!,
                              style: TextStyle(
                                color: getStatusColor(guest['checkInOut']!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }  else {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Guest Management',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFDBB017),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex:1, // Search field takes 3 parts
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by name, ID, or room',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => filterData(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1, // Filter dropdown takes 1 part
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['All', 'Checked In', 'Checked Out', 'Upcoming']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status ,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          filterData();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFFDBB017)),
                      columnSpacing: 12.0, // Adjust column spacing
                      horizontalMargin: 12.0,
                      columns: const [
                        DataColumn(
                            label: Text('Reservation ID',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Name',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Room Number',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Total Amount',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Amount Paid',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Status',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Check-In/Out',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: filteredData.map((guest) {
                        return DataRow(cells: [
                          DataCell(Text(guest['reservationId'].toString())),
                          DataCell(Text(guest['name']!)),
                          DataCell(Text(guest['roomNumber']!)),
                          DataCell(Text('\$${guest['totalAmount']}')),
                          DataCell(Text('\$${guest['amountPaid']}')),
                          DataCell(
                            Text(
                              guest['status']!,
                              style: TextStyle(
                                color: getStatusColor(guest['status']!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              guest['checkInOut']!,
                              style: TextStyle(
                                color: getStatusColor(guest['checkInOut']!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
