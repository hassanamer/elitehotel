import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/screens/invoice_screen.dart';
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
String getLocalizedStatus(String status) {
  if (Intl.getCurrentLocale() == 'ar') {
    switch (status) {
      case 'Checked In':
        return 'تسجيل الدخول';
      case 'Checked Out':
        return 'تسجيل الخروج';
      case 'Upcoming':
        return 'قيد الانتظار';
      default:
        return status; // Return the original status if no translation is available
    }
  }
  return status; // Return the original status for non-Arabic locales
}

String convertToArabic(String text) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String arabicText = text.replaceAllMapped(RegExp(r'\d'), (match) {
    return arabicDigits[int.parse(match.group(0)!)];
  });
  const textDictionary = {
    'Room Type': 'نوع الغرفة',
    'Room Number': 'رقم الغرفة',
    'Invoice Number': 'رقم الفاتورة',
    'Suite': 'جناح',
    'Room': 'غرفة',
    'Mini Suite': 'ميني جناح',
    'Cash': 'كاش',
    'Visa': 'كاش',
    'Bank Transfer': 'تحويل بنكي',
    'Instapay': 'انستاباي',
  };
  textDictionary.forEach((key, value) {
    arabicText = arabicText.replaceAll(key, value);
  });
  return arabicText;
}

String getLocalizedText(String text) {
  if (Intl.getCurrentLocale() == 'ar') {
    return convertToArabic(text);
  }
  return text;
}

class ReservationListScreen extends StatefulWidget {
  @override
  _ReservationListScreenState createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  String selectedStatus = S.current.all;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> reservationData = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>>? cachedReservationData; // Cache for reservation data
  @override
  void initState() {
    super.initState();
    // Only fetch data if there is no cached data
    if (cachedReservationData == null) {
      fetchReservationData();
    } else {
      setState(() {
        reservationData = cachedReservationData!;
        filteredData = reservationData; // Use cached data
      });
    }  }


  Future<void> fetchReservationData() async {
    try {
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance.collection('reservations').get();

      setState(() {
        reservationData = reservationSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Debugging output to check the data types
          print('Fetched data: $data');

          DateTime checkInDate;
          DateTime checkOutDate;

          // Check if checkInDate is of type Timestamp or DateTime
          if (data['checkInDate'] is Timestamp) {
            checkInDate = (data['checkInDate'] as Timestamp).toDate();
            print('checkInDate is Timestamp: $checkInDate');
          } else if (data['checkInDate'] is DateTime) {
            checkInDate = data['checkInDate'] as DateTime;
            print('checkInDate is DateTime: $checkInDate');
          } else {
            checkInDate = DateTime.now(); // Default value or handle error
            print('checkInDate is neither Timestamp nor DateTime, using default: $checkInDate');
          }

          // Check if checkOutDate is of type Timestamp or DateTime
          if (data['checkOutDate'] is Timestamp) {
            checkOutDate = (data['checkOutDate'] as Timestamp).toDate();
            print('checkOutDate is Timestamp: $checkOutDate');
          } else if (data['checkOutDate'] is DateTime) {
            checkOutDate = data['checkOutDate'] as DateTime;
            print('checkOutDate is DateTime: $checkOutDate');
          } else {
            checkOutDate = DateTime.now(); // Default value or handle error
            print('checkOutDate is neither Timestamp nor DateTime, using default: $checkOutDate');
          }

          String status = DateTime.now().isBefore(checkInDate)
              ? 'Upcoming'
              : DateTime.now().isAfter(checkOutDate)
              ? 'Checked Out'
              : 'Checked In';

          return {
            'reservationId': data['reservationId'] ?? 'Unknown',
            'guestName': data['guestName'] ?? 'Unknown',
            'roomNumber': data['roomNumber'] ?? 'Unknown',
            'paymentMethod': data['paymentMethod'] ?? 'Unknown',
            'roomType': data['roomType'] ?? 'Unknown',
            'totalCost': data['totalCost']?.toString() ?? '0',
            'mobileNumber': data['mobileNumber']?.toString() ?? '0',
            'amountPaid': data['amountPaid']?.toString() ?? '0',
            'remainingBalance': data['remainingBalance']?.toString() ?? '0',
            'status': status,
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
          };
        }).toList();

        filteredData = reservationData;
        cachedReservationData = reservationData; // Cache the fetched data
      });
    } catch (e) {
      print("Error fetching reservation data: $e");
    }
  }

  void filterData() {
    String searchQuery = searchController.text.toLowerCase();
    Locale locale = Localizations.localeOf(context);

    setState(() {
      filteredData = reservationData.where((reservation) {
        String localizedStatus = getLocalizedStatus(reservation['status']);

        // Ensure checkOutDate is a DateTime
        DateTime checkOutDate;
        if (reservation['checkOutDate'] is Timestamp) {
          checkOutDate = (reservation['checkOutDate'] as Timestamp).toDate();
        } else if (reservation['checkOutDate'] is DateTime) {
          checkOutDate = reservation['checkOutDate'] as DateTime;
        } else {
          checkOutDate = DateTime.now(); // Default value or handle error
        }

        // Get today's date without time
        DateTime today = DateTime.now();
        DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
        DateTime checkOutDateOnly = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

        // Check if the reservation's checkout date is today
        bool isTodayCheckout = checkOutDateOnly.isAtSameMomentAs(todayDateOnly);

        // Debugging output
        print('Reservation ID: ${reservation['reservationId']}');
        print('CheckOut Date: $checkOutDate');
        print('Is Today Checkout: $isTodayCheckout');
        print('Selected Status: $selectedStatus');
        print('Localized Status: $localizedStatus');

        // Check if the selected status matches the reservation status
        bool matchesStatus = selectedStatus == S.current.all ||
            localizedStatus == selectedStatus ||
            (selectedStatus == 'Today\'s Checkouts' && isTodayCheckout);

        // Check if the search query matches any of the fields
        bool matchesSearch = (reservation['guestName']?.toString().toLowerCase().contains(searchQuery) ?? false) ||
            (reservation['reservationId']?.toString().toLowerCase().contains(searchQuery) ?? false) ||
            (reservation['roomNumber']?.toString().toLowerCase().contains(searchQuery) ?? false);

        // Return true if both status and search match
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }
  Color getStatusColor(String status) {
    switch (status) {
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
        title: Text(S.current.sideMenuReservations,
            style: TextStyle( fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 22)),
        backgroundColor: const Color(0xFFDBB017),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchReservationData(); // Refresh the data when the button is pressed
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
                    value: selectedStatus,
                    items: [
                      DropdownMenuItem(value: S.current.all, child: Text(S.current.all)),
                      DropdownMenuItem(value: S.current.checkedIn, child: Text(S.current.checkedIn)),
                      DropdownMenuItem(value: S.current.checkedOut, child: Text(S.current.checkedOut)),
                      DropdownMenuItem(value: S.current.upcoming, child: Text(S.current.upcoming)),
                      DropdownMenuItem(value: 'Today\'s Checkouts', child: Text('Today\'s Checkouts')),

                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                        filterData(); // Call filterData when the dropdown value changes
                      });
                    },
                    decoration: InputDecoration(
                      labelText: S.current.filterByStatus,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),              ],
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
                    columns: [
                      DataColumn(
                          label: Text(S.current.reservationId,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.guestName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.roomNumber,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.totalCost,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.amountPaid,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.status,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.checkOutDate,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.more,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                      DataColumn(
                          label: Text(S.current.invoices,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 17))),
                    ],
                    rows: filteredData.map((reservation) {
                      return DataRow(cells: [
                        DataCell(Text(getLocalizedNumber(reservation['reservationId'].toString()),style: TextStyle(fontSize: 16,),)),
                        DataCell(Text(reservation['guestName']!,style: TextStyle(fontSize: 16,),)),
                        DataCell(Text(getLocalizedNumber(reservation['roomNumber']!),style: TextStyle(fontSize: 16,),)),
                        DataCell(Text(getLocalizedNumber('${reservation['totalCost']}'),style: TextStyle(fontSize: 16,),)),
                        DataCell(Text(getLocalizedNumber('${reservation['amountPaid']}'),style: TextStyle(fontSize: 16,),)),
                        DataCell(
                          Text(
                            getLocalizedStatus(reservation['status']!),
                            style: TextStyle(
                              color: getStatusColor(reservation['status']!),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(reservation['checkOutDate']),
                      style: TextStyle(fontSize: 16,),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservationDetailScreen(
                                      reservation: reservation),
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                              icon: Icon(Icons.receipt),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceScreen(
                                      packageType: reservation['packageType'],
                                      guestNumber: reservation['mobileNumber'],
                                      totalNights: reservation['checkOutDate']
                                          .difference(
                                              reservation['checkInDate'])
                                          .inDays,
                                      paymentMethod:
                                          reservation['paymentMethod'],
                                      reservationId:
                                          reservation['reservationId'],
                                      invoiceNumber:
                                          reservation['reservationId'],
                                      guestName: reservation['guestName'],
                                      roomType: reservation['roomType'],
                                      roomNumber: reservation['roomNumber'],
                                      checkInDate: reservation['checkInDate'],
                                      checkOutDate: reservation['checkOutDate'],
                                      amountPaid: double.tryParse(
                                              reservation['amountPaid']) ??
                                          0.0,
                                      remainingBalance: double.tryParse(
                                              reservation[
                                                  'remainingBalance']) ??
                                          0.0,
                                      totalCost: double.tryParse(
                                              reservation['totalCost']) ??
                                          0.0,
                                      creationDate: reservation['creationDate']?? DateTime.now(),
                                    ),
                                  ),
                                );
                              }),
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
    );}
    else{
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(S.current.sideMenuReservations,
              style: TextStyle( fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 26)),
          backgroundColor: const Color(0xFFDBB017),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
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
                      value: selectedStatus,
                      items: [
                        DropdownMenuItem(value: S.current.all, child: Text(S.current.all)),
                        DropdownMenuItem(value: S.current.checkedIn, child: Text(S.current.checkedIn)),
                        DropdownMenuItem(value: S.current.checkedOut, child: Text(S.current.checkedOut)),
                        DropdownMenuItem(value: S.current.upcoming, child: Text(S.current.upcoming)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          filterData();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: S.current.filterByStatus,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),              ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFFDBB017)),
                      columnSpacing: 20.0,
                      horizontalMargin: 12.0,
                      columns: [
                        DataColumn(
                            label: Text(S.current.reservationId,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.guestName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.roomNumber,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.totalCost,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.amountPaid,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.status,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.checkInOut,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.more,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                        DataColumn(
                            label: Text(S.current.invoices,
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri',fontSize: 18))),
                      ],
                      rows: filteredData.map((reservation) {
                        return DataRow(cells: [
                          DataCell(Text(getLocalizedNumber(reservation['reservationId'].toString()),style: TextStyle(fontSize: 16,),)),
                          DataCell(Text(reservation['guestName']!,style: TextStyle(fontSize: 16,),)),
                          DataCell(Text(getLocalizedNumber(reservation['roomNumber']!),style: TextStyle(fontSize: 16,),)),
                          DataCell(Text(getLocalizedNumber('${reservation['totalCost']}'),style: TextStyle(fontSize: 16,),)),
                          DataCell(Text(getLocalizedNumber('${reservation['amountPaid']}'),style: TextStyle(fontSize: 16,),)),
                          DataCell(
                            Text(
                              getLocalizedStatus(reservation['status']!),
                              style: TextStyle(
                                color: getStatusColor(reservation['status']!),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(reservation['checkInDate']),
                              style: TextStyle(fontSize: 16,),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationDetailScreen(
                                        reservation: reservation),
                                  ),
                                );
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                                icon: Icon(Icons.receipt),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceScreen(
                                        packageType: reservation['packageType'],
                                        guestNumber: reservation['mobileNumber'],
                                        totalNights: reservation['checkOutDate']
                                            .difference(
                                            reservation['checkInDate'])
                                            .inDays,
                                        paymentMethod:
                                        reservation['paymentMethod'],
                                        reservationId:
                                        reservation['reservationId'],
                                        invoiceNumber:
                                        reservation['reservationId'],
                                        guestName: reservation['guestName'],
                                        roomType: reservation['roomType'],
                                        roomNumber: reservation['roomNumber'],
                                        checkInDate: reservation['checkInDate'],
                                        checkOutDate: reservation['checkOutDate'],
                                        amountPaid: double.tryParse(
                                            reservation['amountPaid']) ??
                                            0.0,
                                        remainingBalance: double.tryParse(
                                            reservation[
                                            'remainingBalance']) ??
                                            0.0,
                                        totalCost: double.tryParse(
                                            reservation['totalCost']) ??
                                            0.0,
                                        creationDate: reservation['creationDate']?? DateTime.now(),
                                      ),
                                    ),
                                  );
                                }),
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
    };
  }
}

class ReservationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;

  ReservationDetailScreen({required this.reservation});

  @override
  Widget build(BuildContext context) {
    int totalNights = reservation['checkOutDate']
        .difference(reservation['checkInDate'])
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.reservationDetails),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard(S.current.guestNameLabel, reservation['guestName'],
                Icons.person),
            _buildDetailCard(
                S.current.roomNumber, getLocalizedNumber(reservation['roomNumber']), Icons.hotel),
            _buildDetailCard(S.current.totalCost, getLocalizedNumber('${reservation['totalCost']}'),
                Icons.attach_money),
            _buildDetailCard(S.current.amountPaid,
                getLocalizedNumber('${reservation['amountPaid']}'), Icons.money_off),
            _buildDetailCard(
                S.current.remainingBalanceLabel,
                getLocalizedNumber('${reservation['remainingBalance']}'),
                Icons.rotate_left_outlined),
            _buildDetailCard(S.current.paymenMethod,
                getLocalizedText(reservation['paymentMethod']), Icons.money),
            _buildDetailCard(
                S.current.checkInDate,
                DateFormat('yyyy-MM-dd').format(reservation['checkInDate']),
                Icons.calendar_today),
            _buildDetailCard(
                S.current.checkOutDate,
                DateFormat('yyyy-MM-dd').format(reservation['checkOutDate']),
                Icons.calendar_today),
            _buildDetailCard(
                S.current.totalnights, getLocalizedNumber('$totalNights'), Icons.nights_stay),
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
