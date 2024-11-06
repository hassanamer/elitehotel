import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/screens/invoice_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _adultsController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _notesController = TextEditingController(); // Notes controller



  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  double _rate = 0.0;
  double _totalCost = 0.0;
  double _remainingBalance = 0.0;
  String _noteFrequency = 'Just Once'; // Default note frequency

  final List<String> _roomTypes = ['Room', 'Suite', 'Mini Suite'];
  String? _selectedRoomType;
  String? _assignedRoomNumber; // To store the assigned room number

  void _calculateTotalCost() {
    if (_checkInDate != null && _checkOutDate != null && _rate > 0) {
      int days = _checkOutDate!.difference(_checkInDate!).inDays;
      setState(() {
        _totalCost = days * _rate;
        _remainingBalance = _totalCost - (double.tryParse(_amountPaidController.text) ?? 0.0);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate = isCheckIn ? DateTime.now() : _checkInDate ?? DateTime.now();
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

  Future<void> _fetchRate() async {
    if (_selectedRoomType == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('rates')
          .doc(_selectedRoomType)
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

  bool _validateInputs() {
    if (_guestNameController.text.isEmpty) {
      _showError('Please enter the guest name.');
      return false;
    }
    if (_selectedRoomType == null) {
      _showError('Please select a room type.');
      return false;
    }
    if (_adultsController.text.isEmpty || int.tryParse(_adultsController.text) == null || int.parse(_adultsController.text) <= 0) {
      _showError('Please enter a valid number of adults.');
      return false;
    }
    if (_checkInDate == null) {
      _showError('Please select a check-in date.');
      return false;
    }
    if (_checkOutDate == null) {
      _showError('Please select a check-out date.');
      return false;
    }
    if (_checkOutDate!.isBefore(_checkInDate!)) {
      _showError('Check-out date must be after check-in date.');
      return false;
    }
    if (_amountPaidController.text.isEmpty || double.tryParse(_amountPaidController.text) == null || double.parse(_amountPaidController.text) < 0) {
      _showError('Please enter a valid amount paid.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        _showError('No available rooms of this type');
        _assignedRoomNumber = null; // Reset assigned room number if none available
      }
    } catch (e) {
      print("Error assigning room: $e");
    }
  }

  void _createReservation() async {
    if (!_validateInputs() || _assignedRoomNumber == null) {
      return; // Don't proceed if validation fails or no room is assigned
    }

    try {
      // Fetch the current maximum reservationId
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('reservations').orderBy('reservationId', descending: true).limit(1).get();
      int newReservationId = 1; // Default value

      if (snapshot.docs.isNotEmpty) {
        newReservationId = (snapshot.docs.first['reservationId'] as int) + 1; // Increment the max reservationId
      }

      // Create reservation document
      await FirebaseFirestore.instance.collection('reservations').add({
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
          'text': _notesController.text, // Add the note text to the reservation
          'frequency': _noteFrequency, // Add the frequency of the note (Just Once or Daily)
        },
      });

      // Update room status and current guest
      await FirebaseFirestore.instance.collection('rooms').doc(_assignedRoomNumber).update({
        'status': 'Occupied',
        'currentGuest': _guestNameController.text,
      });

      // Debug prints to verify the values before showing the invoice
      print('Guest Name: ${_guestNameController.text}');
      print('Room Type: $_selectedRoomType');
      print('Room Number: $_assignedRoomNumber');
      print('Check-In Date: ${_checkInDate != null ? DateFormat('yyyy-MM-dd').format(_checkInDate!) : 'N/A'}');
      print('Check-Out Date: ${_checkOutDate != null ? DateFormat('yyyy-MM-dd').format(_checkOutDate!) : 'N/A'}');
      print('Total Cost: $_totalCost');
      print('Amount Paid: ${_amountPaidController.text}');
      print('Remaining Balance: $_remainingBalance');

      // Show invoice preview
      // _showInvoicePreview();

      // Reset form fields to ensure they are ready for the next reservation
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation created successfully!')),
      );
    } catch (e) {
      print("Error creating reservation: $e");
    }
  }


  // void _showInvoicePreview() {
  //   Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) => InvoiceScreen(
  //       guestName: _guestNameController.text,
  //       roomType: _selectedRoomType!,
  //       roomNumber: _assignedRoomNumber!,
  //       checkInDate: _checkInDate!,
  //       checkOutDate: _checkOutDate!,
  //       totalCost: _totalCost,
  //       amountPaid: double.tryParse(_amountPaidController.text) ?? 0.0,
  //       remainingBalance: _remainingBalance,
  //     ),
  //   ));
  // }
  //
  // void _generateInvoice() async {
  //   final pdf = pw.Document();
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           children: [
  //             pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 20),
  //             pw.Text('Guest Name: ${_guestNameController.text}'),
  //             pw.Text('Room Type: $_selectedRoomType'),
  //             pw.Text('Room Number: $_assignedRoomNumber'),
  //             pw.Text('Check-In Date: ${_checkInDate != null ? DateFormat('yyyy-MM-dd').format(_checkInDate!) : 'N/A'}'),
  //             pw.Text('Check-Out Date: ${_checkOutDate != null ? DateFormat('yyyy-MM-dd').format(_checkOutDate!) : 'N/A'}'),
  //             pw.Text('Total Cost: \$${_totalCost.toStringAsFixed(2)}'),
  //             pw.Text('Amount Paid: \$${_amountPaidController.text}'),
  //             pw.Text('Remaining Balance: \$${_remainingBalance.toStringAsFixed(2)}'),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Save the PDF and prompt the user to print or download
  //   await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  // }

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Reservation'),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _guestNameController,
                decoration: InputDecoration(
                  labelText: 'Guest Name',
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
                  labelText: 'Room Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value;
                  });
                  _fetchRate();
                  _assignRoom();
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _adultsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Adults',
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
                        labelText: 'Number of Children',
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
                            ? 'Check-In Date'
                            : DateFormat('yyyy-MM-dd').format(_checkInDate!),
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
                            ? 'Check-Out Date'
                            : DateFormat('yyyy-MM-dd').format(_checkOutDate!),
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
                  labelText: 'Amount Paid',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotalCost(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes (e.g., breakfast request)'),
              ),
              DropdownButton<String>(
                value: _noteFrequency,
                items: <String>['Just Once', 'Daily'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _noteFrequency = newValue!;
                  });
                },
                hint: Text('Select Note Frequency'),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost: \$${_totalCost.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Remaining: \$${_remainingBalance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createReservation,
                child: Text('Create Reservation'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDBB017)),
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
                  stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
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
                      columns: const [
                        DataColumn(label: Text('ReservationId', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Guest Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Room Type', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Room Number', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Check-In', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Total Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Notes')), // New column for notes
                      ],
                      rows: reservations.map((reservation) {
                        return DataRow(
                          cells: [
                            DataCell(Text(reservation['reservationId'].toString() ?? 'N/A')),
                            DataCell(Text(reservation['guestName'] ?? 'N/A')),
                            DataCell(Text(reservation['roomType'] ?? 'N/A')),
                            DataCell(Text(reservation['roomNumber'] ?? 'N/A')),
                            DataCell(Text(
                              DateFormat('yyyy-MM-dd').format(
                                  (reservation['checkInDate'] as Timestamp).toDate()),
                            )),
                            DataCell(Text(
                              DateFormat('yyyy-MM-dd').format(
                                  (reservation['checkOutDate'] as Timestamp).toDate()),
                            )),
                            DataCell(Text('\$${reservation['totalCost'].toString()}')),
                            DataCell(Text(
                              '\$${reservation['remainingBalance'].toString()}',
                              style: TextStyle(color: Colors.red),
                            )),
                            DataCell(Text(
                                '${reservation['notes']?['text'] ?? ''} (${reservation['notes']?['frequency'] ?? 'Just Once'})'
                            )), // Show notes with frequency

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
      ),
    );
  }
}