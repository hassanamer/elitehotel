import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/screens/reservationslist.dart';
import 'package:elitehotel/widgets/dashboard_widgets/reservations_amount_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatesScreen extends StatefulWidget {
  @override
  _RatesScreenState createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ratesData = [];
  String searchQuery = '';
  String? userAccountType;
  List<Map<String, dynamic>>? cachedRatesData; // Cache for rates data

  final Map<String, String> _packageTranslations = {
    'Room (Egyptian)': 'غرفة (مصري)',
    'Room (Electronic warefare)': 'غرفة (حرب إلك)',
    'Room (Military)': 'غرفة (عسكري)',
    'Room (Foriegns)': 'غرفة (أجنبي)',
    'Mini Suite (Egyptian)': 'ميني سويت (مصري)',
    'Mini Suite (Electronic warefare)': 'ميني سويت (حرب إلك)',
    'Mini Suite (Military)': 'ميني سويت (عسكري)',
    'Mini Suite (Foriegns)': 'ميني سويت (أجنبي)',
    'Suite (Egyptian)': 'سويت (مصري)',
    'Suite (Electonice warefare)': 'سويت (حرب إلك)',
    'Suite (Military)': 'سويت (عسكري)',
    'Suite (Foriegns)': 'سويت (أجنبي)',
    'Wedding Package solitaire': 'باكيدج قاعة سولتير',
    'Wedding Package Akasia': 'باكيدج قاعة أكاسيا',
    'Wedding Extra Suite[Egp]': 'سويت فرح اضافي(مصري)',
    'Wedding Extra Suite[Foriegn]': 'سويت فرح اضافي(اجنبي)',
    'Wedding Extra R[Foriegn]': 'غرفة فرح اضافية(اجنبي)',
    'Wedding Extra R[Egp]': 'غرفة فرح اضافية(مصري)',
  };

  // Function to translate package names to Arabic
  String _translatePackageName(String packageName) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return _packageTranslations[packageName] ??
          packageName; // Use original if no translation
    }
    return packageName; // Return the original if the locale is not Arabic
  }

  @override
  void initState() {
    super.initState();
    if (userAccountType == null) {
      _getUserAccountType();
    }
    if (cachedRatesData == null) {
      _fetchRatesData();
    } else {
      setState(() {
        ratesData = cachedRatesData!; // Use cached data
      });
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

  Future<void> _fetchRatesData() async {
    try {
      QuerySnapshot ratesSnapshot = await _firestore.collection('rates').get();
      QuerySnapshot roomSnapshot = await _firestore.collection('rooms').get();

      List<Map<String, dynamic>> updatedRatesData = [];

      for (var rateDoc in ratesSnapshot.docs) {
        Map<String, dynamic> rate = rateDoc.data() as Map<String, dynamic>;
        String roomType = rate['roomType'];

        int availableRooms = roomSnapshot.docs
            .where((doc) =>
        doc['roomType'] == roomType && doc['status'] == 'Available')
            .length;

        rate['availability'] = availableRooms;
        updatedRatesData.add(rate);
      }

      setState(() {
        ratesData = updatedRatesData;
        cachedRatesData = updatedRatesData; // Cache the fetched data
      });
    } catch (e) {
      print("Error fetching rates data: $e");
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
            .where((doc) =>
                doc['roomType'] == roomType && doc['status'] == 'Available')
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
    final packageController =
        TextEditingController(text: rate?['roomType'] ?? '');
    final rateController =
        TextEditingController(text: rate?['rate']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(docId == null ? S.current.addNewRate : S.current.editRate),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: packageController,
                  decoration: InputDecoration(labelText: S.current.package),
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
                try {
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
                  // Refresh the UI
                  setState(() {});
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error adding/updating rate: $e');
                  // Optionally, show an error message to the user
                }
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
    final rate = ratesData.firstWhere((rate) => rate['roomType'] == docId,
        orElse: () => {});
    if (rate.isEmpty) {
      print("Rate data not found for docId: $docId"); // Debug log
    }
    _showRateDialog(rate: rate.isNotEmpty ? rate : null, docId: docId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600; // Threshold for mobile devices
    print(
        'Screen width: $screenWidth, Using: ${isMobile ? 'Mobile' : 'Desktop'} widget');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          S.current.ratesManagement,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
          ),
        ),
        backgroundColor: const Color(0xFFDBB017),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchRatesData(); // Refresh the data when the button is pressed
            },
          ),
          SizedBox(width: 4,),
          if (userAccountType == 'Admin' || userAccountType == 'Manager')
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDBB017),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text(
                  S.current.addRate,
                  style: const TextStyle(color: Colors.black),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: double.infinity, // Make the container take full width
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
                          (states) => const Color(0xFFDBB017),
                    ),
                    columnSpacing: 20.0,
                    dataRowHeight: 90,
                    horizontalMargin: 12.0,
                    columns: _buildColumns(),
                    rows: ratesData.where((rate) {
                      return rate['roomType'] != null &&
                          rate['roomType']!
                              .toString()
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                    }).map((rate) {
                      String docId = rate['roomType'];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              _translatePackageName(rate['roomType'] ?? 'N/A'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Amiri',
                                fontSize: 20,
                                height: 1.3,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              getLocalizedNumber(rate['rate']) ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Amiri',
                                fontSize: 17,
                                height: 1.1,
                              ),
                            ),
                          ),
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
                                      await _deleteRate(docId);
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextButton(
              child: Text(S.current.reservationsamount),
              onPressed: _showReservationsAmountDialog,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the mobile-specific rates table
  Widget _buildMobileRatesTable(List<Map<String, dynamic>> ratesData) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
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
            (states) => const Color(0xFFDBB017),
          ),
          columnSpacing: 20.0,
          dataRowHeight: 90,
          horizontalMargin: 12.0,
          columns: _buildColumns(),
          rows: ratesData.map((rate) {
            String docId = rate['roomType'];
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    _translatePackageName(rate['roomType'] ?? 'N/A'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      height:
                          1.3, // Adjust line height (smaller value for compact spacing)
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    getLocalizedNumber(rate['rate']) ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                      fontSize: 17,
                      height: 1.1, // Adjust line height
                    ),
                  ),
                ),
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
                            await _deleteRate(docId);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds the desktop-specific rates table
  Widget _buildDesktopRatesTable(List<Map<String, dynamic>> ratesData) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: constraints.maxWidth, // Make the container take full width

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
              (states) => const Color(0xFFDBB017),
            ),
            columnSpacing: 15.0,
            dataRowHeight: 100,
            horizontalMargin: 12.0,
            columns: _buildColumns(),
            rows: _buildRows(ratesData),
          ),
        ),
      );
    });
  }

  /// Builds the common columns for both tables
  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text(
          S.current.package,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
            fontSize: 20,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          S.current.rate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
            fontSize: 20,
          ),
        ),
      ),
      if (userAccountType == 'Admin' || userAccountType == 'Manager')
        DataColumn(
          label: Text(
            S.current.actions,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
    ];
  }

  /// Builds rows based on rates data
  List<DataRow> _buildRows(List<Map<String, dynamic>> ratesData) {
    return ratesData.map((rate) {
      String docId = rate['roomType'];
      return DataRow(
        cells: [
          DataCell(
            Text(
              _translatePackageName(rate['roomType'] ?? 'N/A'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                fontSize: 22,
              ),
            ),
          ),
          DataCell(
            Text(
              getLocalizedNumber(rate['rate']) ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
                fontSize: 17,
              ),
            ),
          ),
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
                      await _deleteRate(docId);
                    },
                  ),
                ],
              ),
            ),
        ],
      );
    }).toList();
  }

  void _showReservationsAmountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.current.reservationsamount),
          content: SingleChildScrollView(
            child: ReservationsAmountSection(showTodayOnly: true),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.current.cancel),
            ),
          ],
        );
      },
    );
  }}