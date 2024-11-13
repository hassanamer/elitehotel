import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'invoice_screen.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _adultsController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _notesController =
  TextEditingController(); // Notes controller


  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  double _rate = 0.0;
  double _totalCost = 0.0;
  double _remainingBalance = 0.0;
  String _noteFrequency = 'Just Once'; // Default note frequency
  List<String> _packages = []; // List to hold package names
  String? _selectedPackage;
  final List<String> _roomTypes = ['Room', 'Suite', 'Mini Suite'];
  String? _selectedRoomType;
  String? _assignedRoomNumber; // To store the assigned room number
  late DateTime creationDate;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rates')
          .get();
      setState(() {
        _packages = snapshot.docs.map((doc) => doc.id).toList(); // Assuming package names are the document IDs
      });
    } catch (e) {
      print("Error fetching packages: $e");
    }
  }

  void _fetchRate() async {
    if (_selectedPackage == null) return; // Check if a package is selected

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('rates')
          .doc(_selectedPackage) // Fetch rate based on selected package
          .get();
      if (doc.exists) {
        setState(() {
          _rate = double.tryParse(doc['rate'].toString()) ?? 0.0;
          _calculateTotalCost();
        });
      } else {
        print('Rate not found');
      }
    } catch (e) {
      print("Error fetching rate: $e");
    }
  }

  void _calculateTotalCost() {
    if (_checkInDate != null && _checkOutDate != null && _rate > 0) {
      int days = _checkOutDate!.difference(_checkInDate!).inDays;
      setState(() {
        _totalCost = days * _rate;
        _remainingBalance =
            _totalCost - (double.tryParse(_amountPaidController.text) ?? 0.0);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate =
    isCheckIn ? DateTime.now() : _checkInDate ?? DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate;
          }
        } else {
          _checkOutDate = picked;
        }
      });
      _calculateTotalCost();
    }
  }



  bool _validateInputs() {
    if (_guestNameController.text.isEmpty) {
      _showError(S.current.enterGuestName);
      return false;
    }
    if (_selectedRoomType == null) {
      _showError(S.current.selectRoomType);
      return false;
    }
    if (_adultsController.text.isEmpty ||
        int.tryParse(_adultsController.text) == null ||
        int.parse(_adultsController.text) <= 0) {
      _showError(S.current.enterNumOfAdults);
      return false;
    }
    if (_checkInDate == null) {
      _showError(S.current.pleaseCheckinDate);
      return false;
    }
    if (_checkOutDate == null) {
      _showError(S.current.pleaseCheckoutDate);
      return false;
    }
    if (_checkOutDate!.isBefore(_checkInDate!)) {
      _showError(S.current.pleaseCheckoutDateafter);
      return false;
    }
    if (_amountPaidController.text.isEmpty ||
        double.tryParse(_amountPaidController.text) == null ||
        double.parse(_amountPaidController.text) < 0) {
      _showError(S.current.pleaseamountpaid);
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _assignRoom() async {
    if (_selectedRoomType == null) return;

    try {
      QuerySnapshot availableRooms = await FirebaseFirestore.instance
          .collection('rooms')
          .where('roomType', isEqualTo: _selectedRoomType)
          .where('status', isEqualTo: 'Available')
          .limit(1)
          .get();

      if (availableRooms.docs.isNotEmpty) {
        setState(() {
          _assignedRoomNumber = availableRooms.docs.first['roomNumber'];
        });
      } else {
        _showError(S.current.noAvailablerooms);
        _assignedRoomNumber =
        null; // Reset assigned room number if none available
      }
    } catch (e) {
      print("Error assigning room: $e");
    }
  }

  void _createReservation() async {
    creationDate = DateTime.now(); // Initialize creationDate here

    if (!_validateInputs() || _assignedRoomNumber == null) {
      return; // Don't proceed if validation fails or no room is assigned
    }

    try {
      // Generate a random reservationId and document ID
      int newReservationId = Random().nextInt(900000) + 100000; // Generates a 6-digit number

      // Check if reservationId already exists (Optional: to avoid duplicate IDs)
      bool exists = await FirebaseFirestore.instance
          .collection('reservations')
          .where('reservationId', isEqualTo: newReservationId)
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty);

      if (exists) {
        // Retry to get a unique ID if duplicate is found
        newReservationId = Random().nextInt(900000) + 100000;
      }

      // Create reservation document with the random ID
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(newReservationId.toString()) // Set the document ID
          .set({
        'reservationId': newReservationId, // Add the unique reservation ID
        'guestName': _guestNameController.text,
        'roomType': _selectedRoomType,
        'roomNumber': _assignedRoomNumber,
        'adults': int.tryParse(_adultsController.text) ?? 1,
        'children': int.tryParse(_childrenController.text) ?? 0,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
        'amountPaid': double.tryParse(_amountPaidController.text) ?? 0.0,
        'totalCost': _totalCost,
        'remainingBalance': _remainingBalance,
        'notes': {
          'text': _notesController.text,
          'frequency': _noteFrequency,
        },
        'creationDate': DateTime.now(),
      });

      // Update room status and current guest
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(_assignedRoomNumber)
          .update({
        'status': 'Occupied',
        'currentGuest': _guestNameController.text,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.reservationSuccess)),
      );

      // Navigate to the invoice preview with the new reservationId as invoice number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceScreen(
            invoiceNumber: newReservationId,  // Pass the random ID as invoice number
            guestName: _guestNameController.text,
            roomType: _selectedPackage ?? 'N/A',
            roomNumber: _assignedRoomNumber ?? 'N/A',
            checkInDate: _checkInDate ?? DateTime.now(),
            checkOutDate: _checkOutDate ?? DateTime.now(),
            amountPaid: double.tryParse(_amountPaidController.text) ?? 0.0,
            remainingBalance: _remainingBalance,
            totalCost: _totalCost,
            creationDate: creationDate, // Pass the remaining balance

          ),
        ),
      ).then((_) {
        // Reset form after returning from InvoiceScreen
        _resetForm();
      });

    } catch (e) {
      print("Error creating reservation: $e");
    }
  }

// Define frequency options with keys and localized values
  final noteFrequencyOptions = {
    'justOnce': S.current.justOnce,
    'daily': S.current.daily,
  };



  void _resetForm() {
    setState(() {
      _guestNameController.clear();
      _selectedRoomType = null;
      _assignedRoomNumber = null;
      _adultsController.clear();
      _childrenController.clear();
      _amountPaidController.clear();
      _checkInDate = null;
      _checkOutDate = null;
      _rate = 0.0;
      _totalCost = 0.0;
      _remainingBalance = 0.0;
      _notesController.clear(); // Clear notes field
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(S.current.reservations),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: (screenWidth > 600)
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _guestNameController,
                decoration: InputDecoration(
                  labelText: S.current.guestName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPackage,
                items: _packages.map((package) {
                  return DropdownMenuItem(
                    value: package,
                    child: Text(package),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: S.current.selectPackage,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedPackage = value;
                  });
                  _fetchRate(); // Fetch rate based on selected package
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                items: _roomTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: S.current.roomType,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value;
                  });
                  _assignRoom(); // Assign room based on selected room type
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _adultsController,
                      decoration: InputDecoration(
                        labelText: S.current.numberOfAdults,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _childrenController,
                      decoration: InputDecoration(
                        labelText: S.current.numberOfChildren,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _checkInDate == null
                            ? S.current.checkInDate
                            : DateFormat('yyyy-MM-dd')
                            .format(_checkInDate!),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _checkOutDate == null
                            ? S.current.checkOutDate
                            : DateFormat('yyyy-MM-dd')
                            .format(_checkOutDate!),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountPaidController,
                decoration: InputDecoration(
                  labelText: S.current.amountPaid,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotalCost(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                    labelText: S.current.notesBreakfast),
              ),
              DropdownButton<String>(
                value: noteFrequencyOptions.keys.contains(_noteFrequency) ? _noteFrequency : 'justOnce', // Fallback if unmatched
                items: noteFrequencyOptions.keys.map((key) {
                  return DropdownMenuItem<String>(
                    value: key,  // Use the key as the identifier
                    child: Text(noteFrequencyOptions[key]!),  // Display localized text
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _noteFrequency = newValue!;
                  });
                },
                hint: Text(S.current.selectNoteFrequency),
              ),              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${S.current.totalCost}: \$${_totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${S.current.remainingBalanceLabel}: \$${_remainingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createReservation,
                child: Text(S.current.createReservation),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBB017)),
              ),
              const SizedBox(height: 20),
              Container(
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reservations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final reservations = snapshot.data!.docs;

                    return DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFFDBB017)),
                      columnSpacing: 12.0,
                      horizontalMargin: 12.0,
                      columns:  [
                        DataColumn(
                            label: Text(S.current.reservationId,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.guestName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.roomType,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.roomNumber,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.checkIn,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.checkOut,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.totalCost,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(
                            label: Text(S.current.remainingBalance,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 13))),
                        DataColumn(label: Text(S.current.notes, style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 13),)),
                        DataColumn(label: Text(S.current.invoices, style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 13),),),
                        DataColumn(label: Text(S.current.actions, style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 13),),),
                      ],
                      rows: reservations.map((reservation) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                                reservation['reservationId'].toString() ??
                                    'N/A')),
                            DataCell(
                                Text(reservation['guestName'] ?? 'N/A')),
                            DataCell(
                                Text(reservation['roomType'] ?? 'N/A')),
                            DataCell(
                                Text(reservation['roomNumber'] ?? 'N/A')),
                            DataCell(Text(
                              DateFormat('yyyy-MM-dd').format(
                                  (reservation['checkInDate']
                                  as Timestamp)
                                      .toDate()),
                            )),
                            DataCell(Text(
                              DateFormat('yyyy-MM-dd').format(
                                  (reservation['checkOutDate']
                                  as Timestamp)
                                      .toDate()),
                            )),
                            DataCell(Text(
                                '\$${reservation['totalCost'].toString()}')),
                            DataCell(Text(
                              '\$${reservation['remainingBalance'].toString()}',
                              style: TextStyle(color: Colors.red),
                            )),
                            DataCell(Text(
                                '${reservation['notes']?['text'] ?? ''} (${reservation['notes']?['frequency'] ?? 'Just Once'})')), // Show notes with frequency
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceScreen(
                                        invoiceNumber: reservation['reservationId'], // Pass the reservation ID as invoice number
                                        guestName: reservation['guestName'], // Pass the guest name
                                        roomType: reservation['roomType'], // Pass the room type
                                        roomNumber: reservation['roomNumber'], // Pass the room number
                                        checkInDate: (reservation['checkInDate'] as Timestamp).toDate(), // Pass the check-in date
                                        checkOutDate: (reservation['checkOutDate'] as Timestamp).toDate(), // Pass the check-out date
                                        amountPaid: reservation['amountPaid'] ?? 0.0, // Pass the amount paid
                                        remainingBalance: reservation['remainingBalance'] ?? 0.0, // Pass the remaining balance
                                        totalCost: reservation['totalCost'] ?? 0.0, // Pass the remaining balance
                                        creationDate: (reservation['creationDate'] as Timestamp).toDate(), // Pass the creation date
                                      ),
                                    ),
                                  );
                                },
                                icon:Icon(Icons.insert_chart_outlined_outlined),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () async {
                                  // Delete reservation from Firestore
                                  await FirebaseFirestore.instance
                                      .collection('reservations')
                                      .doc(reservation['reservationId'].toString())
                                      .delete();

                                  // Update room status to Available
                                  await FirebaseFirestore.instance
                                      .collection('rooms')
                                      .doc(reservation['roomNumber'])
                                      .update({
                                    'status': 'Available',
                                    'currentGuest': null, // Clear current guest
                                  });

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(S.current.reservationDeletedSuccess)),
                                  );
                                },
                                icon: Icon(Icons.delete, color: Colors.red), // Change icon to delete
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _guestNameController,
                decoration: InputDecoration(
                  labelText: S.current.guestName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                items: _roomTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: S.current.roomType,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value!;
                  });
                  _fetchRate();
                  _assignRoom();                      },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _adultsController,
                      decoration: InputDecoration(
                        labelText: S.current.numberOfAdults,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _childrenController,
                      decoration: InputDecoration(
                        labelText: S.current.numberOfChildren,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _checkInDate == null
                            ? S.current.checkInDate
                            : DateFormat('yyyy-MM-dd')
                            .format(_checkInDate!),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _checkOutDate == null
                            ? S.current.checkOutDate
                            : DateFormat('yyyy-MM-dd')
                            .format(_checkOutDate!),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountPaidController,
                decoration: InputDecoration(
                  labelText: S.current.amountPaidLabel,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotalCost(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                    labelText: S.current.notesBreakfast),
              ),
              DropdownButton<String>(
                // Ensure _noteFrequency is a valid key or fall back to 'justOnce'
                value: noteFrequencyOptions.containsKey(_noteFrequency) ? _noteFrequency : 'justOnce',
                items: noteFrequencyOptions.keys.map((key) {
                  return DropdownMenuItem<String>(
                    value: key,  // Use the key as the value
                    child: Text(noteFrequencyOptions[key]!),  // Display the localized text
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _noteFrequency = newValue!;  // Update with the key only
                  });
                },
                hint: Text(S.current.selectNoteFrequency),
              ),              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${S.current.totalCost}: \$${_totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${S.current.remainingBalance}: \$${_remainingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createReservation,
                child: Text(S.current.createReservation),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBB017)),
              ),
              const SizedBox(height: 20),
              Container(
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reservations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final reservations = snapshot.data!.docs;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      // Enables vertical scrolling
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // Enables horizontal scrolling
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => const Color(0xFFDBB017)),
                          columnSpacing: 12.0,
                          horizontalMargin: 12.0,
                          columns:  [
                            DataColumn(
                                label: Text(S.current.reservationId,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.guestName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.roomType,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.roomNumber,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.checkIn,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.checkOut,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.totalCost,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text(S.current.remainingBalanceLabel,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),),),
                            DataColumn(label: Text(S.current.notes, style: TextStyle(
                                fontWeight: FontWeight.bold,color: Colors.black),),),
                            DataColumn(label: Text(S.current.invoices, style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 13),),),
                            DataColumn(label: Text(S.current.actions, style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 13),),),
                          ],
                          rows: reservations.map((reservation) {
                            return DataRow(
                              cells: [
                                DataCell(Text(reservation['reservationId']
                                    .toString() ??
                                    'N/A')),
                                DataCell(Text(
                                    reservation['guestName'] ?? 'N/A')),
                                DataCell(Text(
                                    reservation['roomType'] ?? 'N/A')),
                                DataCell(Text(
                                    reservation['roomNumber'] ?? 'N/A')),
                                DataCell(Text(
                                  DateFormat('yyyy-MM-dd').format(
                                      (reservation['checkInDate']
                                      as Timestamp)
                                          .toDate()),
                                )),
                                DataCell(Text(
                                  DateFormat('yyyy-MM-dd').format(
                                      (reservation['checkOutDate']
                                      as Timestamp)
                                          .toDate()),
                                )),
                                DataCell(Text(
                                    '\$${reservation['totalCost'].toString()}')),
                                DataCell(Text(
                                  '\$${reservation['remainingBalance'].toString()}',
                                  style: TextStyle(color: Colors.black),
                                )),
                                  DataCell(Text(
                                      '${reservation['notes']?['text'] ?? ''} (${reservation['notes']?['frequency'] ?? 'Just Once'})'),), // Show notes with frequency
                                DataCell(
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InvoiceScreen(
                                            invoiceNumber: reservation['reservationId'], // Pass the reservation ID as invoice number
                                            guestName: reservation['guestName'], // Pass the guest name
                                            roomType: reservation['roomType'], // Pass the room type
                                            roomNumber: reservation['roomNumber'], // Pass the room number
                                            checkInDate: (reservation['checkInDate'] as Timestamp).toDate(), // Pass the check-in date
                                            checkOutDate: (reservation['checkOutDate'] as Timestamp).toDate(), // Pass the check-out date
                                            amountPaid: (reservation['amountPaid'] ?? 0.0).toDouble(), // Ensure amountPaid is a double
                                            remainingBalance: (reservation['remainingBalance'] ?? 0.0).toDouble(), // Pass the remaining balance
                                            totalCost: (reservation['totalCost'] ?? 0.0).toDouble(), // Pass the remaining balance
                                            creationDate: (reservation['creationDate'] as Timestamp).toDate(), // Pass the creation date
                                          ),
                                        ),
                                      );
                                    },
                                    icon:Icon(Icons.insert_chart_outlined_outlined),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    onPressed: () async {
                                      // Delete reservation from Firestore
                                      await FirebaseFirestore.instance
                                          .collection('reservations')
                                          .doc(reservation['reservationId'].toString())
                                          .delete();

                                      // Update room status to Available
                                      await FirebaseFirestore.instance
                                          .collection('rooms')
                                          .doc(reservation['roomNumber'])
                                          .update({
                                        'status': 'Available',
                                        'currentGuest': null, // Clear current guest
                                      });

                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(S.current.reservationDeletedSuccess)),
                                      );
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red), // Change icon to delete
                                  ),
                                ),
                              ],
                            );
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
      ),
    );
  }
}
