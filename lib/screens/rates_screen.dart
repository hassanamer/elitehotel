import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatesScreen extends StatefulWidget {
  @override
  _RatesScreenState createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ratesData = [];
  String searchQuery = '';
  String? userAccountType;

  @override
  void initState() {
    super.initState();
    _getUserAccountType();
    _fetchRates();
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

  Future<void> _fetchRates() async {
    QuerySnapshot ratesSnapshot = await _firestore.collection('rates').get();

    ratesData = ratesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    for (var rate in ratesData) {
      String roomType = rate['roomType'];
      QuerySnapshot roomSnapshot = await _firestore.collection('rooms')
          .where('roomType', isEqualTo: roomType)
          .get();

      int availableRooms = roomSnapshot.docs.where((doc) => doc['status'] == 'Available').length;

      rate['availability'] = availableRooms;
    }

    setState(() {});
  }

  void _showRateDialog({Map<String, dynamic>? rate, String? docId}) {
    final packageController = TextEditingController(text: rate?['roomType'] ?? '');
    final rateController = TextEditingController(text: rate?['rate'] ?? '');
    final availabilityController = TextEditingController(text: (rate?['availability'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add New Rate' : 'Edit Rate'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: packageController,
                  decoration: const InputDecoration(labelText: 'Package'),
                ),
                TextField(
                  controller: rateController,
                  decoration: const InputDecoration(labelText: 'Rate'),
                ),
                TextField(
                  controller: availabilityController,
                  decoration: const InputDecoration(labelText: 'Availability'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String documentId = packageController.text;

                DocumentSnapshot docSnapshot = await _firestore.collection('rates').doc(documentId).get();
                if (docSnapshot.exists) {
                  await _firestore.collection('rates').doc(documentId).update({
                    'roomType': documentId,
                    'rate': rateController.text,
                    'availability': int.tryParse(availabilityController.text) ?? 0,
                  });
                } else {
                  await _firestore.collection('rates').doc(documentId).set({
                    'roomType': documentId,
                    'rate': rateController.text,
                    'availability': int.tryParse(availabilityController.text) ?? 0,
                  });
                }

                _fetchRates();
                Navigator.of(context).pop();
              },
              child: Text(docId == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editRate(String docId) {
    final rate = ratesData.firstWhere((rate) => rate['roomType'] == docId, orElse: () => {});
    _showRateDialog(rate: rate.isNotEmpty ? rate : null, docId: docId);
  }

  @override
  Widget build(BuildContext context) {
    final filteredRatesData = ratesData.where((rate) {
      return rate['roomType'] != null &&
          rate['roomType']!.toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Rates Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFDBB017),
        actions: [
          if (userAccountType == 'Admin' || userAccountType == 'Manager')
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Rate', style: TextStyle(color: Colors.white)),
              onPressed: () {
                _showRateDialog();
              },
            ),
        ],
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
                    decoration: InputDecoration(
                      labelText: 'Search by Package',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Expanded(
                //   flex: 1,
                //   child: DropdownButtonFormField<String>(
                //     value: 'All',
                //     items: ['All', 'Available', 'Booked', 'Reserved', 'Waiting']
                //         .map((status) => DropdownMenuItem(
                //       value: status,
                //       child: Text(status),
                //     ))
                //         .toList(),
                //     onChanged: (value) {
                //       // Implement filter functionality
                //     },
                //     decoration: InputDecoration(
                //       labelText: 'Filter by Status',
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12.0),
                //       ),
                //     ),
                //   ),
                // ),
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
                    headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFFDBB017)),
                    columnSpacing: 20.0,
                    horizontalMargin: 12.0,
                    columns: [
                      const DataColumn(label: Text('Package', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Availability', style: TextStyle(fontWeight: FontWeight.bold))),
                      if (userAccountType == 'Admin' || userAccountType == 'Manager')
                        const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredRatesData.map((rate) {
                      String docId = rate['roomType'];
                      return DataRow(cells: [
                        DataCell(Text(rate['roomType'] ?? 'N/A')),
                        DataCell(Text(rate['rate'] ?? 'N/A')),
                        DataCell(Text((rate['availability'] ?? 0).toString())),
                        if (userAccountType == 'Admin' || userAccountType == 'Manager')
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editRate(docId),
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