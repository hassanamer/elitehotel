import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/assets/elite_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceScreen extends StatefulWidget {
  final String guestName;
  final String roomType;
  final String roomNumber;
  final String guestNumber;
  final String? paymentMethod;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double amountPaid;
  final double totalCost;
  final double remainingBalance;
  final int invoiceNumber;
  final int reservationId;
  final DateTime creationDate;

  const InvoiceScreen({
    super.key,
    required this.guestName,
    required this.roomType,
    required this.roomNumber,
    required this.guestNumber,
    required this.checkInDate,
    required this.paymentMethod,
    required this.checkOutDate,
    required this.amountPaid,
    required this.reservationId,
    required this.totalCost,
    required this.remainingBalance,
    required this.invoiceNumber,
    required this.creationDate,
  });

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String? userAccountType;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController remainingBalanceController;
  late TextEditingController totalCostController;
  late TextEditingController paidController;

  @override
  void initState() {
    super.initState();
    _getUserAccountType();
    remainingBalanceController = TextEditingController(
      text: widget.remainingBalance.toStringAsFixed(2),
    );
    totalCostController = TextEditingController(
      text: widget.totalCost.toStringAsFixed(2),
    );
    paidController = TextEditingController(
      text: widget.amountPaid.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    remainingBalanceController.dispose();
    paidController.dispose();
    totalCostController.dispose();
    super.dispose();
  }

  Uint8List loadLogo() {
    return base64Decode(eliteImageBase64);
  }

  // Get the user's account type (Admin, Manager, etc.)
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

// Update the total cost, amount paid, and remaining balance in the reservations collection
  Future<void> _updateReservationDetails() async {
    try {
      // Get the total cost and amount paid (make sure these values are fetched from the user input or other logic)
      double totalCost = double.parse(totalCostController
          .text); // Assuming you have a controller for total cost
      double amountPaid = double.parse(paidController
          .text); // Assuming you have a controller for amount paid

      // Calculate the remaining balance
      double remainingBalance = totalCost - amountPaid;

      // Update the fields in the reservation document
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId.toString())
          .update({
        'totalCost': totalCost,
        'amountPaid': amountPaid,
        'remainingBalance': remainingBalance,
      });

      // Show success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Updated successfully!')));
    } catch (e) {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating reservation: $e')));
    }
  }

  // Fetch the nightly rate for the room type
  Future<double> _getNightlyRate() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('rates')
          .doc(widget.roomType)
          .get();
      if (snapshot.exists && snapshot.data() != null) {
        var rate = snapshot['rate'];
        return (rate is String)
            ? double.tryParse(rate) ?? 0.0
            : rate.toDouble();
      } else {
        return 0.0; // Return a default rate if the rate is not found
      }
    } catch (e) {
      print("Error fetching nightly rate: $e");
      return 0.0;
    }
  }

  // Widget to display invoice detail with conditional styling
  Widget _buildInvoiceDetail(String label, String value, IconData icon,
      {bool isBold = false, bool isRed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isRed ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  // Divider widget for consistent spacing
  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade300, thickness: 1);
  }

  // Widget to display editable or static fields
  Widget _buildEditableField(String label, String value, IconData icon,
      {bool isEditable = false, TextEditingController? controller}) {
    bool isAdminOrManager =
        userAccountType == 'Admin' || userAccountType == 'Manager';

    return isEditable && isAdminOrManager
        ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(),
            ),
            onChanged: (newValue) {
              // Optionally handle value changes here
            },
          )
        : Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _getNightlyRate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("Nightly rate not found"));
        } else {
          final nightlyRate = snapshot.data!;
          final totalNights =
              widget.checkOutDate.difference(widget.checkInDate).inDays;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Invoice #${widget.invoiceNumber}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              backgroundColor: const Color(0xFFDBB017),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Invoice Details',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      shadowColor: Colors.grey.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInvoiceDetail('Invoice Number',
                                '${widget.invoiceNumber}', Icons.receipt),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Guest Name', widget.guestName, Icons.person),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Room Type', widget.roomType, Icons.king_bed),
                            _buildDivider(),
                            _buildInvoiceDetail('Room Number',
                                widget.roomNumber, Icons.door_front_door),
                            _buildDivider(),
                            _buildInvoiceDetail('Payment Method',
                                widget.paymentMethod ?? 'N/A', Icons.payment),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Check-In Date',
                                DateFormat('yyyy-MM-dd')
                                    .format(widget.checkInDate),
                                Icons.calendar_today),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Check-Out Date',
                                DateFormat('yyyy-MM-dd')
                                    .format(widget.checkOutDate),
                                Icons.calendar_today_outlined),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Creation Date',
                                DateFormat('yyyy-MM-dd')
                                    .format(widget.creationDate),
                                Icons.date_range),
                            _buildDivider(),
                            _buildEditableField(
                                'Total Cost',
                                '\$${widget.totalCost.toStringAsFixed(2)}',
                                Icons.attach_money,
                                isEditable: true,
                                controller: totalCostController),
                            _buildDivider(),
                            _buildEditableField(
                                'Amount Paid',
                                '\$${widget.amountPaid.toStringAsFixed(2)}',
                                Icons.money_off_csred_sharp,
                                isEditable: true,
                                controller: paidController),
                            _buildDivider(),
                            _buildEditableField(
                                'Remaining Balance',
                                '\$${widget.remainingBalance.toStringAsFixed(2)}',
                                Icons.account_balance_wallet,
                                isEditable: true,
                                controller: remainingBalanceController),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _updateReservationDetails();
                          },
                          icon: Icon(Icons.save),
                          label: Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDBB017)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final Uint8List logoData =
                                loadLogo(); // Load the logo data

                            await Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async {
                                final pdf = pw.Document();

                                pdf.addPage(
                                  pw.Page(
                                    margin: pw.EdgeInsets.fromLTRB(
                                        8, 12, 8, 12), // Set margins to zero
                                    build: (context) => pw.Stack(
                                      children: [
                                    // Watermark logo
                                    pw.Positioned.fill(
                                    child: pw.Opacity(
                                      opacity: 0.05, // Set low opacity for watermark effect
                                      child: pw.Center(
                                        child: pw.Image(
                                          pw.MemoryImage(logoData),
                                          fit: pw.BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(
                                              color: PdfColors.black,
                                              width: 2,
                                            ),
                                          ),
                                      padding: const pw.EdgeInsets.all(10),
                                      child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          // Header with logo and text
                                          pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                        children: [

                                          pw.Column(
                                            crossAxisAlignment: pw.CrossAxisAlignment.center, // Center the column content
                                            children: [
                                              pw.Center(
                                                child: pw.Image(
                                                  pw.MemoryImage(logoData),
                                                  width: 680,
                                                  height: 100,
                                                ),
                                              ),
                                              pw.SizedBox(height: 6),
                                              pw.Center(
                                                child: pw.Container(
                                                  color: PdfColor.fromInt(0xFFDBB017),
                                                  padding: const pw.EdgeInsets.all(3),
                                                  child: pw.Text(
                                                    'ELITE HOTEL',
                                                    style: pw.TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: pw.FontWeight.bold,
                                                      color: PdfColors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                          // Centered "INVOICE" text
                                          pw.Center(
                                            child: pw.Container(
                                              color: PdfColor.fromInt(0xFFDBB017),
                                              padding: const pw.EdgeInsets.all(10),
                                              child: pw.Text(
                                                'INVOICE',
                                                style: pw.TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: pw.FontWeight.bold,
                                                  color: PdfColors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          pw.SizedBox(height: 10),
                                          // Bill To section
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Date: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: '${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Invoice Number: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: '${widget.invoiceNumber}',
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Bill To: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: '${widget.guestName}',
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Mobile: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: '${widget.guestNumber}',
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Room Type: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: '${widget.roomType}',
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Room Number: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: '${widget.roomNumber}',
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Check-In Date: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: DateFormat('dd-MM-yyyy').format(widget.checkInDate),
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          pw.SizedBox(height: 6),
                                          pw.RichText(
                                            text: pw.TextSpan(
                                              children: [
                                                pw.TextSpan(
                                                  text: 'Check-Out Date: ',
                                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                                ),
                                                pw.TextSpan(
                                                  text: DateFormat('dd-MM-yyyy').format(widget.checkOutDate),
                                                  style: pw.TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),

                                          pw.SizedBox(height: 20),
                                          // Table with updated headers
                                          pw.Table(
                                            border: pw.TableBorder.symmetric(
                                              inside: pw.BorderSide(
                                                  width: 0.7,
                                                  color: PdfColors.grey),
                                              outside: pw.BorderSide(
                                                  width: 1,
                                                  color: PdfColors.black),
                                            ),
                                            children: [
                                              pw.TableRow(
                                                children: [
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            5.0),
                                                    child: pw.Text('Item',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            5.0),
                                                    child: pw.Text('Number',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            5.0),
                                                    child: pw.Text('Price',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            5.0),
                                                    child: pw.Text('Total',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            5.0),
                                                    child: pw.Text('Remaining',
                                                        style: pw.TextStyle(
                                                            color:
                                                                PdfColors.black,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            5.0),
                                                    child: pw.Text(
                                                        'Payment Method',
                                                        style: pw.TextStyle(
                                                            color:
                                                                PdfColors.black,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                ],
                                              ),
                                              pw.TableRow(
                                                children: [
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        pw.Text('Hotel Nights'),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        '$totalNights'), // Number
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        '\$${nightlyRate.toStringAsFixed(2)}'), // Price
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        '\$${widget.totalCost.toStringAsFixed(2)}'), // Total
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        '\$${widget.remainingBalance.toStringAsFixed(2)}',
                                                        style: pw.TextStyle(
                                                            color: PdfColors
                                                                .black)), // Remaining
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        '${widget.paymentMethod}',
                                                        style: pw.TextStyle(
                                                            color: PdfColors
                                                                .black)), // Payment Method
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 20),
                                          // Footer with hotel contact and signature
                                          pw.Text('Thank you for choosing us!',
                                              style: pw.TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                          pw.SizedBox(height: 8),
                                          pw.Text(
                                            'We hope you enjoyed your stay and experienced the luxury.',
                                            style: pw.TextStyle(
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColor.fromInt(0xFFDBB017),
                                            ),
                                          ),
                                          pw.SizedBox(height: 5),

                                          pw.Text(
                                            'We look forward to another memorable stay!',
                                            style: pw.TextStyle(
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColor.fromInt(0xFFDBB017),
                                            ),
                                          ),
                                          pw.SizedBox(height: 30),

                                          pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.end,
                                            children: [
                                              pw.Column(
                                                crossAxisAlignment: pw.CrossAxisAlignment.center, // Center the column content
                                                children: [
                                                  pw.BarcodeWidget(
                                                    barcode: pw.Barcode.qrCode(),
                                                    data: 'https://elitehotel.com/feedback',
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                                  pw.SizedBox(height: 10),
                                                  pw.Text('Hotel Contact: 123-456-7890',
                                                      style:
                                                      pw.TextStyle(fontSize: 12)),
                                                  pw.SizedBox(height: 6),
                                                  pw.Text(
                                                      'Address: 123 Elite St, Luxury City',
                                                      style:
                                                      pw.TextStyle(fontSize: 12)),
                                                  pw.SizedBox(height: 20),
                                                  pw.Text(
                                                      'Signature: ____________________',
                                                      style:
                                                      pw.TextStyle(fontSize: 12)),
                                                ],
                                              ),

                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ]
                                    ),
                                ),
                                );
                                return pdf.save();
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.print,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'Print Invoice',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDBB017),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
