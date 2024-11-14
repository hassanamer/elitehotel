import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceScreen extends StatelessWidget {
  final String guestName;
  final String roomType;
  final String roomNumber;
  final String? paymentMethod;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double amountPaid;
  final double totalCost;
  final double remainingBalance;
  final int invoiceNumber;
  final DateTime creationDate;

  const InvoiceScreen({
    super.key,
    required this.guestName,
    required this.roomType,
    required this.roomNumber,
    required this.checkInDate,
    required this.paymentMethod,
    required this.checkOutDate,
    required this.amountPaid,
    required this.totalCost,
    required this.remainingBalance, required this.invoiceNumber,
    required this.creationDate,
  });

  // final String invoiceNumber =
  //     'INV-${Random().nextInt(999999).toString().padLeft(6, '0')}';

  Future<double> _getNightlyRate() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('rates')
          .doc(roomType) // Assuming the room type is used as the document ID
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        var rate = snapshot['rate'];
        // Ensure the rate is a double, convert if necessary
        return (rate is String)
            ? double.tryParse(rate) ?? 0.0
            : rate.toDouble();
      } else {
        return 0.0; // Return a default rate if the rate is not found
      }
    } catch (e) {
      print("Error fetching nightly rate: $e");
      return 0.0; // Return a default value if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getNightlyRate(), // Fetch nightly rate
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading while fetching data
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return Center(child: Text("Nightly rate not found"));
        } else {
          final nightlyRate = snapshot.data!;
          final totalNights = checkOutDate.difference(checkInDate).inDays;

          return Scaffold(
            appBar: AppBar(
              title:  Text('Invoices',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
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
                            _buildInvoiceDetail(
                                'Invoice Number',   '${invoiceNumber.toString()}', Icons.receipt),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Guest Name', guestName, Icons.person),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Room Type', roomType, Icons.king_bed),
                            _buildDivider(),
                            _buildInvoiceDetail('Room Number', roomNumber,
                                Icons.door_front_door),
                            _buildDivider(),
                            _buildInvoiceDetail('Payment Method', paymentMethod!,
                                Icons.door_front_door),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Check-In Date',
                                DateFormat('yyyy-MM-dd').format(checkInDate),
                                Icons.calendar_today),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Check-Out Date',
                                DateFormat('yyyy-MM-dd').format(checkOutDate),
                                Icons.calendar_today_outlined),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Creation Date', // Display creation date
                                DateFormat('yyyy-MM-dd').format(creationDate),
                                Icons.date_range,
                                isBold: false),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Total Cost',
                                '\$${totalCost.toStringAsFixed(2)}',
                                Icons.attach_money,
                                isBold: false),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Amount Paid',
                                '\$${amountPaid.toStringAsFixed(2)}',
                                Icons.money_off_csred_sharp),
                            _buildDivider(),
                            _buildInvoiceDetail(
                                'Remaining Balance',
                                '\$${remainingBalance.toStringAsFixed(2)}',
                                Icons.account_balance_wallet,
                                isRed: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Printing.layoutPdf(
                            onLayout: (PdfPageFormat format) async {
                              final pdf = pw.Document();

                              pdf.addPage(
                                pw.Page(
                                  build: (context) => pw.Container(
                                    padding: const pw.EdgeInsets.all(20),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        pw.Container(
                                          color: PdfColor.fromInt(0xFFDBB017),
                                          padding: const pw.EdgeInsets.all(10),
                                          child: pw.Column(
                                            children: [
                                              pw.Text('INVOICE',
                                                  style: pw.TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      color: PdfColors.white)),
                                              pw.Text('ELITE HOTEL',
                                                  style: pw.TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      color: PdfColors.white)),
                                            ],
                                          ),
                                        ),
                                        pw.SizedBox(height: 10),
                                        // Invoice Details
                                        pw.Text('Invoice No: $invoiceNumber',
                                            style: pw.TextStyle(fontSize: 12)),
                                        pw.SizedBox(height: 10),
                                        pw.Text(
                                            'Date: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                                            style: pw.TextStyle(fontSize: 12)),
                                        pw.SizedBox(height: 10),

                                        pw.Text('Guest Name: $guestName',
                                            style: pw.TextStyle(fontSize: 12)),
                                        pw.SizedBox(height: 10),
                                        pw.Text('Room Type: $roomType',
                                            style: pw.TextStyle(fontSize: 12)),
                                        pw.SizedBox(height: 10),
                                        pw.Text('Room Number: $roomNumber',
                                            style: pw.TextStyle(fontSize: 12)),
                                        pw.SizedBox(height: 10),
                                        pw.Text(
                                            'Check-In Date: ${DateFormat('yyyy-MM-dd').format(checkInDate)}',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                color: PdfColors.black)),
                                        pw.SizedBox(height: 10),
                                        pw.Text(
                                            'Check-Out Date: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                color: PdfColors.black)),
                                        pw.SizedBox(height: 10),
                                        // Modern Table with dynamic nights calculation
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
                                                  child: pw.Text('Quantity',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          5.0),
                                                  child: pw.Text('Night Price',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          5.0),
                                                  child: pw.Text('Total Cost',
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
                                                          color: PdfColors.red,
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                ),
                                                pw.Padding(
                                                  padding:
                                                  const pw.EdgeInsets.all(
                                                      5.0),
                                                  child: pw.Text('Payment Method',
                                                      style: pw.TextStyle(
                                                          color: PdfColors.black,
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
                                                      '$totalNights'), // Quantity
                                                ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          8.0),
                                                  child: pw.Text(
                                                      '\$${nightlyRate.toStringAsFixed(2)}'), // Nightly Rate
                                                ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          8.0),
                                                  child: pw.Text(
                                                      '\$${totalCost.toStringAsFixed(2)}'), // Total Cost
                                                ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          8.0),
                                                  child: pw.Text(
                                                      '\$${remainingBalance.toStringAsFixed(2)}',
                                                      style: pw.TextStyle(
                                                          color: PdfColors
                                                              .red)), // Total Cost
                                                ),
                                                pw.Padding(
                                                  padding:
                                                  const pw.EdgeInsets.all(
                                                      8.0),
                                                  child: pw.Text(
                                                      '${paymentMethod}',
                                                      style: pw.TextStyle(
                                                          color: PdfColors
                                                              .red)), // Total Cost
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        pw.SizedBox(height: 20),
                                        // Footer
                                        pw.Text('Thank you for choosing us!',
                                            style: pw.TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    pw.FontWeight.bold)),
                                        pw.SizedBox(height: 10),

                                        pw.Text(
                                            'Experience luxury at Elite Hotel - Where every moment matters.',
                                            style: pw.TextStyle(
                                                fontSize: 14,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColor.fromInt(
                                                    0xFFDBB017))),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              return pdf.save();
                            },
                          );
                        },
                        icon: const Icon(Icons.print,color: Colors.black,),
                        label: const Text('Print Invoice',style: TextStyle(color: Colors.black),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDBB017),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                        ),
                      ),
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

  Widget _buildInvoiceDetail(String label, String value, IconData icon,
      {bool isBold = false, bool isRed = false}) {
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
        ),
      ],
    );
  }

  Widget _buildDivider() => Divider(color: Colors.grey[300], thickness: 1);
}
