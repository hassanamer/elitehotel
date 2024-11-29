import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestScreen extends StatefulWidget {
  @override
  _GuestScreenState createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  String selectedStatus = 'all';
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> guestData = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>>? cachedGuestData; // Cache for guest data
  @override
  void initState() {
    super.initState();
    fetchGuestData();
  }


  Future<void> fetchGuestData({bool forceRefresh = false}) async {
    if (cachedGuestData != null && !forceRefresh) {
      // Use cached data if available and not forcing a refresh
      setState(() {
        guestData = cachedGuestData!;
        filteredData = guestData;
      });
      return;
    }

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
            'guestAddress': reservationData['guestAddress'] ?? 'Unknown',
            'roomNumber': reservationData['roomNumber'] ?? 'Unknown',
            'nationality': reservationData['nationality'] ?? 'Unknown',
            'job': reservationData['job'] ?? 'Unknown',
            'totalAmount': reservationData['totalCost']?.toString() ?? '0',
            'amountPaid': reservationData['amountPaid']?.toString() ?? '0',
            'nationalId': reservationData['nationalId']?.toString() ?? '0',
            'mobileNumber': reservationData['mobileNumber']?.toString() ?? '0',
            'status': roomInfo['status'] ?? 'Unknown',
            'checkInOut': checkInOutStatus,
          };
        }).toList();

        filteredData = guestData;
        cachedGuestData = guestData; // Cache the fetched data
      });
    } catch (e) {
      print("Error fetching guest data: $e");
    }
  }
  String _localizeStatus(String status, Locale locale) {
    if (locale.languageCode == 'ar') {
      switch (status) {
        case 'Checked In':
          return 'تم تسجيل الدخول';
        case 'Checked Out':
          return 'تم تسجيل الخروج';
        case 'Upcoming':
          return 'قادم';
        case 'Occupied':
          return 'محجوز';
        case 'Available':
          return 'متاح';
        default:
          return status;
      }
    }
    return status;
  }
  String _reverseLocalizeStatus(String localizedStatus, Locale locale) {
    if (locale.languageCode == 'ar') {
      switch (localizedStatus) {
        case 'تم تسجيل الدخول':
          return 'Checked In';
        case 'تم تسجيل الخروج':
          return 'Checked Out';
        case 'قادم':
          return 'Upcoming';
        case 'محجوز':
          return 'Occupied';
        case 'متاح':
          return 'Available';
        case 'all': // For the "all" dropdown option
          return 'all';
        default:
          return localizedStatus;
      }
    }
    return localizedStatus;
  }
  final statusOptions = {
    'all': S.current.all,
    'Checked In': S.current.checkedIn,
    'Checked Out': S.current.checkedOut,
    'Upcoming': S.current.upcoming,
  };
  void filterData() {
    String searchQuery = searchController.text.toLowerCase();
    Locale locale = Localizations.localeOf(context);
    print("Selected Status: $selectedStatus");
    print("Search Query: $searchQuery");
    setState(() {
      filteredData = guestData.where((guest) {
        // Reverse localize the selected status for filtering
        String actualStatus = _reverseLocalizeStatus(selectedStatus, locale);
        print("Actual Status for Filtering: $actualStatus");
        // Match the reversed localized status
        bool matchesStatus = actualStatus == 'all' ||
            guest['checkInOut'] == actualStatus;
        print("Guest CheckInOut: ${guest['checkInOut']}, Matches Status: $matchesStatus");
        // Match search query
        bool matchesSearch =
            (guest['name']?.toString().toLowerCase().contains(searchQuery) ?? false) ||
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
        print("Matches Search: $matchesSearch");
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


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Locale locale = Localizations.localeOf(context);

    if (screenWidth > 600) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:  Text(S.current.guestManagement,
              style: TextStyle(fontSize: 26,  fontFamily: 'Amiri',fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFDBB017),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                fetchGuestData(forceRefresh: true); // Refresh cached data
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
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: S.current.searchBy,
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
                      value: selectedStatus, // Ensure selectedStatus is one of the keys in statusOptions
                      items: statusOptions.keys.map((key) {
                        return DropdownMenuItem<String>(
                          value: key, // Use the key (e.g., 'all', 'Checked In')
                          child: Text(statusOptions[key]!,style: TextStyle( fontFamily: 'Amiri',fontWeight: FontWeight.bold),), // Display the localized string
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!; // Update selectedStatus with the key
                          filterData();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: S.current.filterByStatus, // Localized label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),                ],
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
                      columns:  [
                        DataColumn(
                            label: Text(S.current.reservationId,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.name,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.roomNumber,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.totalAmount,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.amountPaidLabel,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.status,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.checkInOut,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                        DataColumn(
                            label: Text(S.current.more,
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Amiri',))),
                      ],
                      rows: filteredData.map((guest) {
                        return DataRow(cells: [
                          DataCell(Text(getLocalizedNumber(
                              guest['reservationId'].toString()),style: TextStyle(fontSize: 16,),)),
                          DataCell(Text(guest['name']!,style: TextStyle(fontSize: 16,),)),

                          DataCell(Text(getLocalizedNumber(
                              guest['roomNumber']!),style: TextStyle(fontSize: 16,),)),

                          DataCell(Text(getLocalizedNumber(
                              '${guest['totalAmount']}'),style: TextStyle(fontSize: 16,),)),

                          DataCell(Text(getLocalizedNumber(
                              '${guest['amountPaid']}'),style: TextStyle(fontSize: 16,),)),

                          DataCell(
                            Text(
                              _localizeStatus(guest['status']!, locale),
                              style: TextStyle(
                                color: getStatusColor(guest['status']!),
                                fontWeight: FontWeight.w600,fontSize: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _localizeStatus(guest['checkInOut']!, locale),                              style: TextStyle(
                                color: getStatusColor(guest['checkInOut']!),
                                fontWeight: FontWeight.w600,
                              fontSize: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GuestDetailScreen(guest: guest),
                                  ),
                                );
                              },
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
          title:  Text(S.current.guestManagement,
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
                        labelText: S.current.searchBy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => filterData(),
                    ),
                  ),
                  const SizedBox(width: 12),
// Dropdown Widget
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus, // Ensure selectedStatus is one of the keys in statusOptions
                      items: statusOptions.keys.map((key) {
                        return DropdownMenuItem<String>(
                          value: key, // Use the key (e.g., 'all', 'Checked In')
                          child: Text(statusOptions[key]!), // Display the localized string
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!; // Update selectedStatus with the key
                          filterData();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: S.current.filterByStatus, // Localized label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),                ],
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
                      columns:  [
                        DataColumn(
                            label: Text(S.current.reservationId,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text(S.current.name,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text(S.current.roomNumber,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text(S.current.totalAmount,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text(S.current.amountPaid,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text(S.current.roomStatus,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text(S.current.checkInOut,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('More',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: filteredData.map((guest) {
                        return DataRow(cells: [
                          DataCell(Text(getLocalizedNumber(
                              guest['reservationId'].toString()))),
                          DataCell(Text(guest['name']!)),

                          DataCell(Text(getLocalizedNumber(
                              guest['roomNumber']!))),

                          DataCell(Text(getLocalizedNumber(
                              '${guest['totalAmount']}'))),
                          DataCell(Text(getLocalizedNumber(
                              '${guest['amountPaid']}'))),
                          DataCell(
                            Text(
                              _localizeStatus(guest['status']!, locale),
                              style: TextStyle(
                                color: getStatusColor(guest['status']!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _localizeStatus(guest['checkInOut']!, locale),                              style: TextStyle(
                                color: getStatusColor(guest['checkInOut']!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GuestDetailScreen(guest: guest),
                                  ),
                                );
                              },
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

class GuestDetailScreen extends StatelessWidget {

  final Map<String, dynamic> guest;

  GuestDetailScreen({required this.guest}) {
    // Print the guest data to debug
    print('Guest Data in Detail Screen: $guest');
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.guestdetails),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard(S.current.guestdetails, guest['name'], Icons.person),
            _buildDetailCard(S.current.guestAddress, guest['guestAddress'] ?? 'N/A', Icons.home),
            _buildDetailCard(S.current.job, guest['job'], Icons.work),
            _buildDetailCard(S.current.mobileNumber, getLocalizedNumber(guest['mobileNumber'].toString()), Icons.phone),
            _buildDetailCard(S.current.nationalId,getLocalizedNumber(guest['nationalId'].toString()), Icons.badge),
            _buildDetailCard(S.current.nationality, guest['nationality'], Icons.flag),
            // Add more cards for additional details if needed
          ],
        ),
      ),
    );
  }
  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}