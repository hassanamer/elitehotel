import 'package:elitehotel/generated/l10n.dart';
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

  Stream<List<Map<String, dynamic>>> _fetchRates() {
    return FirebaseFirestore.instance
        .collection('rates')
        .snapshots()
        .asyncMap((ratesSnapshot) async {
      final List<Map<String, dynamic>> updatedRatesData = [];

      QuerySnapshot roomSnapshot = await _firestore.collection('rooms').get();

      for (var rateDoc in ratesSnapshot.docs) {
        Map<String, dynamic> rate = rateDoc.data() as Map<String, dynamic>;
        String roomType = rate['roomType'];

        int availableRooms = roomSnapshot.docs
            .where((doc) => doc['roomType'] == roomType && doc['status'] == 'Available')
            .length;

        rate['availability'] = availableRooms;
        updatedRatesData.add(rate);
      }

      return updatedRatesData;
    });
  }

  Future<void> _deleteRate(String docId) async {
    await _firestore.collection('rates').doc(docId).delete();
    setState(() {
      ratesData.removeWhere((rate) => rate['roomType'] == docId);
    });
  }

  void _showRateDialog({Map<String, dynamic>? rate, String? docId}) {
    final packageController = TextEditingController(text: rate?['roomType'] ?? '');
    final rateController = TextEditingController(text: rate?['rate']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? S.current.addNewRate : S.current.editRate),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: packageController,
                  decoration: InputDecoration(labelText: S.current.package),
                  readOnly: docId != null,
                ),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: S.current.rate),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String documentId = packageController.text;

                if (docId == null) {
                  await _firestore.collection('rates').doc(documentId).set({
                    'roomType': documentId,
                    'rate': rateController.text,
                  });
                } else {
                  await _firestore.collection('rates').doc(docId).update({
                    'rate': rateController.text,
                  });
                }

                Navigator.of(context).pop();
              },
              child: Text(docId == null ? S.current.add : S.current.update),
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
    if (rate.isEmpty) {
      print("Rate data not found for docId: $docId"); // Debug log
    }
    _showRateDialog(rate: rate.isNotEmpty ? rate : null, docId: docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(S.current.ratesManagement,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFDBB017),
        actions: [
          if (userAccountType == 'Admin' || userAccountType == 'Manager')
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDBB017),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text(
                  S.current.addRate,
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  _showRateDialog();
                },
              ),
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
                      labelText: S.current.searchByPackage,
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
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fetchRates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('${S.current.errorMessage}: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    ratesData = snapshot.data!;
                  } else {
                    ratesData = [];
                  }

                  final filteredRatesData = ratesData.where((rate) {
                    return rate['roomType'] != null &&
                        rate['roomType']!.toString().toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  return SingleChildScrollView(
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
                          DataColumn(label: Text(S.current.package, style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text(S.current.rate, style: TextStyle(fontWeight: FontWeight.bold))),
                          if (userAccountType == 'Admin' || userAccountType == 'Manager')
                            DataColumn(label: Text(S.current.actions, style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredRatesData.map((rate) {
                          String docId = rate['roomType'];
                          return DataRow(cells: [
                            DataCell(Text(rate['roomType'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(rate['rate'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold))),
                            if (userAccountType == 'Admin' || userAccountType == 'Manager')
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editRate(docId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _deleteRate(docId); // Delete the rate
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
