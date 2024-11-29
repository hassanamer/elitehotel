import 'dart:convert';
import 'dart:ui' as ui; // Import dart:ui for TextDirection

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/assets/elite_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // Import for PdfColors and other PDF-related types
import 'package:pdf/widgets.dart' as pw; // pdf widgets package
import 'package:printing/printing.dart';

import '../generated/l10n.dart';

class InvoiceScreen extends StatefulWidget {
  final String guestName;
  final String roomType;
  final String roomNumber;
  final String guestNumber;
  final String? packageType;
  final String? paymentMethod;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double amountPaid;
  final double totalCost;
  final double remainingBalance;
  final int invoiceNumber;
  final int reservationId;
  final int totalNights;
  final DateTime creationDate;

  const InvoiceScreen({
    super.key,
    required this.guestName,
    required this.roomType,
    required this.roomNumber,
    required this.guestNumber,
    required this.packageType,
    required this.checkInDate,
    required this.paymentMethod,
    required this.totalNights,
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
    // Add listeners to update fields
    paidController.addListener(_updateRemainingBalance);
    remainingBalanceController.addListener(_updateAmountPaid);
  }

  @override
  void dispose() {
    remainingBalanceController.dispose();
    paidController.dispose();
    totalCostController.dispose();
    super.dispose();
  }

  void _updateRemainingBalance() {
    double totalCost = double.tryParse(totalCostController.text) ?? 0.0;
    double amountPaid = double.tryParse(paidController.text) ?? 0.0;
    double remainingBalance = totalCost - amountPaid;

    if (remainingBalance != double.tryParse(remainingBalanceController.text)) {
      remainingBalanceController.text = remainingBalance.toStringAsFixed(2);
    }
  }

  void _updateAmountPaid() {
    double totalCost = double.tryParse(totalCostController.text) ?? 0.0;
    double remainingBalance =
        double.tryParse(remainingBalanceController.text) ?? 0.0;
    double amountPaid = totalCost - remainingBalance;

    if (amountPaid != double.tryParse(paidController.text)) {
      paidController.text = amountPaid.toStringAsFixed(2);
    }
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

  Future<double> _getNightlyRate() async {
    try {
      // Fetch the reservation document using the reservationId
      print("Fetching reservation for ID: ${widget.reservationId}");
      DocumentSnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId.toString())
          .get();
      if (reservationSnapshot.exists && reservationSnapshot.data() != null) {
        // Extract the packageType from the reservation document
        String? packageType = reservationSnapshot['packageType'];
        print("Package type found: $packageType");
        if (packageType != null) {
          // Fetch the rate document using the packageType
          print("Fetching rate for package type: $packageType");
          DocumentSnapshot rateSnapshot = await FirebaseFirestore.instance
              .collection('rates')
              .doc(packageType)
              .get();
          if (rateSnapshot.exists && rateSnapshot.data() != null) {
            var rate = rateSnapshot['rate'];
            print("Rate found: $rate");
            return (rate is String)
                ? double.tryParse(rate) ?? 0.0
                : rate.toDouble();
          } else {
            print("Rate document not found for package type: $packageType");
          }
        } else {
          print("Package type is null in reservation document.");
        }
      } else {
        print("Reservation document not found for ID: ${widget.reservationId}");
      }
      return 0.0; // Return a default rate if the rate is not found
    } catch (e) {
      print("Error fetching nightly rate: $e");
      return 0.0;
    }
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

  Widget _buildInvoiceDetail(String label, String value, IconData icon,
      {bool isBold = false, bool isRed = false}) {
    // Helper function to check if the text contains Arabic characters
    bool _isArabic(String text) {
      return RegExp(r'[\u0600-\u06FF]').hasMatch(text); // Arabic Unicode range
    }

    // Function to get text direction based on language
    ui.TextDirection _getTextDirection(String text) {
      if (_isArabic(text)) {
        return ui.TextDirection.rtl; // Right-to-left for Arabic
      } else {
        return ui.TextDirection.ltr; // Left-to-right for English
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textDirection:
                  _getTextDirection(label), // Apply text direction for label
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isRed ? Colors.red : Colors.black,
          ),
          textDirection:
              _getTextDirection(value), // Apply text direction for value
        ),
      ],
    );
  }

  // Divider widget for consistent spacing
  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade300, thickness: 1);
  }

  String getLocalizedInvoiceTitle(int invoiceNumber) {
    if (Intl.getCurrentLocale() == 'ar') {
      return 'فاتورة #${convertToArabic(invoiceNumber.toString())}';
    }
    return 'Invoice #$invoiceNumber';
  }

  // Widget to display editable or static fields
  Widget _buildEditableField(String label, String value, IconData icon,
      {bool isEditable = false, TextEditingController? controller}) {
    bool isAdminOrManager = userAccountType == 'Admin' ||
        userAccountType == 'Manager' ||
        userAccountType == 'Front Desk';

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      onChanged: (newValue) {
        // Optionally handle value changes here
      },
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
                getLocalizedInvoiceTitle(widget.invoiceNumber),
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
                        S.current.invoicesDetails,
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
                            _buildInvoiceDetail(
                                S.current.invoicesNumber,
                                getLocalizedText('${widget.invoiceNumber}'),
                                Icons.receipt),
                            _buildDivider(),
                            _buildInvoiceDetail(S.current.guestNameLabel,
                                widget.guestName, Icons.person),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.roomType,
                                getLocalizedText(widget.roomType),
                                Icons.king_bed),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.roomNumber,
                                getLocalizedText(widget.roomNumber),
                                Icons.door_front_door),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.paymenMethod,
                                getLocalizedText(widget.paymentMethod!) ??
                                    'N/A',
                                Icons.payment),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.checkInDate,
                                DateFormat('yyyy-MM-dd')
                                    .format(widget.checkInDate),
                                Icons.calendar_today),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.checkOutDate,
                                DateFormat('yyyy-MM-dd')
                                    .format(widget.checkOutDate),
                                Icons.calendar_today_outlined),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.totalnights,
                                getLocalizedText('${widget.totalNights}'),
                                Icons.calendar_today_outlined),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                S.current.creationDate,
                                DateFormat('yyyy-MM-dd')
                                    .format(widget.creationDate),
                                Icons.date_range),
                            _buildDivider(),
                            _buildEditableField(
                                S.current.totalCost,
                                getLocalizedText(
                                    '${widget.totalCost.toStringAsFixed(2)}'),
                                Icons.money,
                                isEditable: true,
                                controller: totalCostController),
                            _buildDivider(),
                            _buildEditableField(
                                S.current.amountPaid,
                                getLocalizedText(
                                    '${widget.amountPaid.toStringAsFixed(2)}'),
                                Icons.money_off_csred_sharp,
                                isEditable: true,
                                controller: paidController),
                            _buildDivider(),
                            _buildEditableField(
                                S.current.remainingBalanceLabel,
                                getLocalizedText(
                                    '${widget.remainingBalance.toStringAsFixed(2)}'),
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
                          icon: Icon(
                            Icons.save,
                            color: Colors.black,
                          ),
                          label: Text(
                            S.current.savechanges,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDBB017)),
                        ),
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              print(
                                  'Current maxWidth: ${constraints.maxWidth}'); // Debugging line
                              if (constraints.maxWidth > 600) {
                                // Adjust the threshold as needed {
                                // For web, desktop, and large screens
                                return ElevatedButton.icon(
                                  onPressed: () async {
                                    final Uint8List logoData =
                                        loadLogo(); // Load the logo data
                                    final arabicFont = pw.Font.ttf(
                                        await rootBundle
                                            .load('assets/Amiri-Bold.ttf'));

                                    await Printing.layoutPdf(
                                      onLayout: (PdfPageFormat format) async {
                                        final pdf = pw.Document();
// Helper function to check if the text contains Arabic characters
                                        bool _isArabic(String text) {
                                          return RegExp(r'[\u0600-\u06FF]')
                                              .hasMatch(
                                                  text); // Arabic Unicode range
                                        }

                                        pdf.addPage(
                                          pw.Page(
                                            margin: pw.EdgeInsets.fromLTRB(
                                                8, 8, 0, 8),
                                            // Set margins to zero
                                            build: (context) =>
                                                pw.Stack(children: [
                                              // Watermark logo
                                              pw.Positioned.fill(
                                                child: pw.Opacity(
                                                  opacity: 0.05,
                                                  // Set low opacity for watermark effect
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
                                                padding:
                                                    const pw.EdgeInsets.all(10),
                                                child: pw.Column(
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    // Header with logo and text
                                                    pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .end,
                                                      children: [
                                                        pw.Column(
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .center,
                                                          // Center the column content
                                                          children: [
                                                            pw.Center(
                                                              child: pw.Image(
                                                                pw.MemoryImage(
                                                                    logoData),
                                                                width: 650,
                                                                height: 80,
                                                              ),
                                                            ),
                                                            pw.SizedBox(
                                                                height: 4),
                                                            pw.Center(
                                                              child:
                                                                  pw.Container(
                                                                color: PdfColor
                                                                    .fromInt(
                                                                        0xFFDBB017),
                                                                padding: const pw
                                                                    .EdgeInsets.all(
                                                                    3),
                                                                child: pw.Text(
                                                                  'ELITE HOTEL',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                    color: PdfColors
                                                                        .white,
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
                                                          color:
                                                              PdfColor.fromInt(
                                                                  0xFFDBB017),
                                                          padding: const pw
                                                              .EdgeInsets.all(
                                                              5),
                                                          child: pw.Column(
                                                              children: [
                                                                pw.Text(
                                                                  'INVOICE',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                    color: PdfColors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                pw.SizedBox(
                                                                    height: 5),
                                                                pw.Text(
                                                                  'Number: ${widget.invoiceNumber}',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                    color: PdfColors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ])),
                                                    ),
                                                    pw.SizedBox(height: 10),
                                                    // Bill To section
                                                    pw.Row(
                                                        children: [
                                                          pw.Text(
                                                             'Date: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 18,
                                                                font:
                                                                    arabicFont,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.Text(
                                                                '${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                                                            style: pw.TextStyle(
                                                              fontSize: 18,
                                                              font: arabicFont,
                                                            ),
                                                            textDirection: _isArabic(
                                                                DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                                                ? pw.TextDirection
                                                                .rtl
                                                                : pw.TextDirection
                                                                .ltr,

                                                          ),
                                                        ],

                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.Row(
                                                      children: [
                                                        pw.Text(
                                                          'Bill To: ',
                                                          style: pw.TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        pw.Text(
                                                          '${widget.guestName}',
                                                          style: pw.TextStyle(
                                                            fontSize: 18,
                                                            font: arabicFont,
                                                          ),
                                                          textDirection: _isArabic(
                                                                  widget
                                                                      .guestName)
                                                              ? pw.TextDirection
                                                                  .rtl
                                                              : pw.TextDirection
                                                                  .ltr, // Check if the guest name is Arabic or English
                                                        ),
                                                      ],
                                                    ),

                                                    pw.SizedBox(height: 4),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text: 'Mobile: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 18,
                                                                font:
                                                                    arabicFont,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.guestNumber}',
                                                            style: pw.TextStyle(
                                                                font:
                                                                    arabicFont,
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text: 'Room Type: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.roomType}',
                                                            style: pw.TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text:
                                                                'Room Number: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.roomNumber}',
                                                            style: pw.TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text:
                                                                'Check-In Date: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text: DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(widget
                                                                    .checkInDate),
                                                            style: pw.TextStyle(
                                                              fontSize: 18,
                                                              font: arabicFont,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text:
                                                                'Check-Out Date: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 18,
                                                                font:
                                                                    arabicFont,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text: DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(widget
                                                                    .checkOutDate),
                                                            style: pw.TextStyle(
                                                                font:
                                                                    arabicFont,
                                                                fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    pw.SizedBox(height: 8),
                                                    // Table with updated headers
                                                    pw.Table(
                                                      border: pw.TableBorder
                                                          .symmetric(
                                                        inside: pw.BorderSide(
                                                            width: 0.7,
                                                            color:
                                                                PdfColors.grey),
                                                        outside: pw.BorderSide(
                                                            width: 1,
                                                            color: PdfColors
                                                                .black),
                                                      ),
                                                      children: [
                                                        pw.TableRow(
                                                          children: [
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Item',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Number',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Price',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Total',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Remaining',
                                                                  style: pw.TextStyle(
                                                                      color: PdfColors
                                                                          .black,
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Payment Method',
                                                                  style: pw.TextStyle(
                                                                      color: PdfColors
                                                                          .black,
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                          ],
                                                        ),
                                                        pw.TableRow(
                                                          children: [
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  'Hotel Nights'),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '$totalNights'), // Number
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '${nightlyRate.toStringAsFixed(2)}'), // Price
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '${widget.totalCost.toStringAsFixed(2)}'), // Total
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '${widget.remainingBalance.toStringAsFixed(2)}',
                                                                  style: pw.TextStyle(
                                                                      color: PdfColors
                                                                          .black)), // Remaining
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
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
                                                    pw.Text(
                                                        'Thank you for choosing us!',
                                                        style: pw.TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                    pw.SizedBox(height: 8),
                                                    pw.Text(
                                                      'We hope you enjoyed your stay and experienced the luxury.',
                                                      style: pw.TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        color: PdfColor.fromInt(
                                                            0xFFDBB017),
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 5),

                                                    pw.Text(
                                                      'We look forward to another memorable stay!',
                                                      style: pw.TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        color: PdfColor.fromInt(
                                                            0xFFDBB017),
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 80),

                                                    pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        pw.Text(
                                                            'Signature: ____________',
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold)),
                                                        pw.SizedBox(width: 100),
                                                        pw.Column(children: [
                                                          pw.Text('About Us',
                                                              style: pw.TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold)),
                                                          pw.SizedBox(
                                                              height: 6),
                                                          pw.BarcodeWidget(
                                                            barcode: pw.Barcode
                                                                .qrCode(),
                                                            data:
                                                                'https://67220be7972e6.site123.me',
                                                            width: 60,
                                                            height: 50,
                                                          ),
                                                          pw.SizedBox(
                                                              height: 20),
                                                        ]),

                                                        // pw.SizedBox(height: 3),
                                                      ],
                                                    ),
                                                    pw.Divider(
                                                        thickness: 1,
                                                        color: PdfColors.grey),
                                                    pw.SizedBox(height: 4),
                                                    pw.Row(children: [
                                                      pw.SizedBox(width: 70),
                                                      pw.Column(
                                                          // mainAxisAlignment: pw.MainAxisAlignment.center,
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            // Add a line to separate the sections
                                                            pw.SizedBox(
                                                                width: 4),
                                                            // Space between icon and text
                                                            pw.Text(
                                                              'Hotel Contact: 01015231391 - 0223052590',
                                                              style: pw.TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold),
                                                            ),
                                                            pw.SizedBox(
                                                                height: 6),
                                                            pw.Text(
                                                                'Address: El-Nasr Rd, Masaken Al Mohandesin, Nasr City',
                                                                style: pw.TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold)),
                                                          ]),
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                            ]),
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
                                  label: Text(
                                    S.current.printInvoice,
                                    style: TextStyle(color: Colors.black,fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDBB017),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 30),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                );
                              } else {
                                // For mobile and smaller screens
                                return ElevatedButton.icon(
                                  onPressed: () async {
                                    final Uint8List logoData =
                                        loadLogo(); // Load the logo data

                                    await Printing.layoutPdf(
                                      onLayout: (PdfPageFormat format) async {
                                        final pdf = pw.Document();

                                        pdf.addPage(
                                          pw.Page(
                                            margin: pw.EdgeInsets.fromLTRB(
                                                8, 8, 8, 8),
                                            // Set margins to zero
                                            build: (context) =>
                                                pw.Stack(children: [
                                              // Watermark logo
                                              pw.Positioned.fill(
                                                child: pw.Opacity(
                                                  opacity: 0.05,
                                                  // Set low opacity for watermark effect
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
                                                padding:
                                                    const pw.EdgeInsets.all(10),
                                                child: pw.Column(
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    // Header with logo and text
                                                    pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .end,
                                                      children: [
                                                        pw.Column(
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .center,
                                                          // Center the column content
                                                          children: [
                                                            pw.Center(
                                                              child: pw.Image(
                                                                pw.MemoryImage(
                                                                    logoData),
                                                                width: 680,
                                                                height: 100,
                                                              ),
                                                            ),
                                                            pw.SizedBox(
                                                                height: 6),
                                                            pw.Center(
                                                              child:
                                                                  pw.Container(
                                                                color: PdfColor
                                                                    .fromInt(
                                                                        0xFFDBB017),
                                                                padding: const pw
                                                                    .EdgeInsets.all(
                                                                    3),
                                                                child: pw.Text(
                                                                  'ELITE HOTEL',
                                                                  style: pw
                                                                      .TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight: pw
                                                                        .FontWeight
                                                                        .bold,
                                                                    color: PdfColors
                                                                        .white,
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
                                                        color: PdfColor.fromInt(
                                                            0xFFDBB017),
                                                        padding: const pw
                                                            .EdgeInsets.all(10),
                                                        child: pw.Text(
                                                          'INVOICE',
                                                          style: pw.TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold,
                                                            color:
                                                                PdfColors.white,
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
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
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
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.guestName}',
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
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
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.guestNumber}',
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
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
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.roomType}',
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 6),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text:
                                                                'Room Number: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text:
                                                                '${widget.roomNumber}',
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 6),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text:
                                                                'Check-In Date: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text: DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(widget
                                                                    .checkInDate),
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 6),
                                                    pw.RichText(
                                                      text: pw.TextSpan(
                                                        children: [
                                                          pw.TextSpan(
                                                            text:
                                                                'Check-Out Date: ',
                                                            style: pw.TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: pw
                                                                    .FontWeight
                                                                    .bold),
                                                          ),
                                                          pw.TextSpan(
                                                            text: DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(widget
                                                                    .checkOutDate),
                                                            style: pw.TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    pw.SizedBox(height: 20),
                                                    // Table with updated headers
                                                    pw.Table(
                                                      border: pw.TableBorder
                                                          .symmetric(
                                                        inside: pw.BorderSide(
                                                            width: 0.7,
                                                            color:
                                                                PdfColors.grey),
                                                        outside: pw.BorderSide(
                                                            width: 1,
                                                            color: PdfColors
                                                                .black),
                                                      ),
                                                      children: [
                                                        pw.TableRow(
                                                          children: [
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Item',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Number',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Price',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Total',
                                                                  style: pw.TextStyle(
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Remaining',
                                                                  style: pw.TextStyle(
                                                                      color: PdfColors
                                                                          .black,
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  5.0),
                                                              child: pw.Text(
                                                                  'Payment Method',
                                                                  style: pw.TextStyle(
                                                                      color: PdfColors
                                                                          .black,
                                                                      fontWeight: pw
                                                                          .FontWeight
                                                                          .bold)),
                                                            ),
                                                          ],
                                                        ),
                                                        pw.TableRow(
                                                          children: [
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  'Hotel Nights'),
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '$totalNights'), // Number
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '${nightlyRate.toStringAsFixed(2)}'), // Price
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '${widget.totalCost.toStringAsFixed(2)}'), // Total
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
                                                                  8.0),
                                                              child: pw.Text(
                                                                  '${widget.remainingBalance.toStringAsFixed(2)}',
                                                                  style: pw.TextStyle(
                                                                      color: PdfColors
                                                                          .black)), // Remaining
                                                            ),
                                                            pw.Padding(
                                                              padding: const pw
                                                                  .EdgeInsets.all(
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
                                                    pw.Text(
                                                        'Thank you for choosing us!',
                                                        style: pw.TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                    pw.SizedBox(height: 8),
                                                    pw.Text(
                                                      'We hope you enjoyed your stay and experienced the luxury.',
                                                      style: pw.TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        color: PdfColor.fromInt(
                                                            0xFFDBB017),
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 5),

                                                    pw.Text(
                                                      'We look forward to another memorable stay!',
                                                      style: pw.TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            pw.FontWeight.bold,
                                                        color: PdfColor.fromInt(
                                                            0xFFDBB017),
                                                      ),
                                                    ),
                                                    pw.SizedBox(height: 30),

                                                    pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .end,
                                                      children: [
                                                        pw.Column(
                                                          crossAxisAlignment: pw
                                                              .CrossAxisAlignment
                                                              .center,
                                                          // Center the column content
                                                          children: [
                                                            pw.BarcodeWidget(
                                                              barcode:
                                                                  pw.Barcode
                                                                      .qrCode(),
                                                              data:
                                                                  'https://elitehotel.com/feedback',
                                                              width: 80,
                                                              height: 80,
                                                            ),
                                                            pw.SizedBox(
                                                                height: 10),
                                                            pw.Text(
                                                                'Hotel Contact: 123-456-7890',
                                                                style: pw
                                                                    .TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                            pw.SizedBox(
                                                                height: 6),
                                                            pw.Text(
                                                                'Address: 123 Elite St, Luxury City',
                                                                style: pw
                                                                    .TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                            pw.SizedBox(
                                                                height: 20),
                                                            pw.Text(
                                                                'Signature: ____________________',
                                                                style: pw
                                                                    .TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                          ),
                                        );
                                        return pdf.save();
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.print,
                                    color: Colors.black,
                                    size: 15,
                                  ),
                                  label: const Text(
                                    'Print Invoice',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDBB017),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    // Adjust padding
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
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
