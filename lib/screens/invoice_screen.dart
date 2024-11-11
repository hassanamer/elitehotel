import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart'; // Import printing package
import 'package:pdf/widgets.dart' as pw;
class InvoiceScreen extends StatelessWidget {
  final String guestName;
  final String roomType;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalCost;
  final double amountPaid;
  final double remainingBalance;

  const InvoiceScreen({
    Key? key,
    required this.guestName,
    required this.roomType,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalCost,
    required this.amountPaid,
    required this.remainingBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Invoice'),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guest Name: $guestName', style: TextStyle(fontSize: 18)),
                    Text('Room Type: $roomType', style: TextStyle(fontSize: 18)),
                    Text('Room Number: $roomNumber', style: TextStyle(fontSize: 18)),
                    Text('Check-In Date: ${DateFormat('yyyy-MM-dd').format(checkInDate)}', style: TextStyle(fontSize: 18)),
                    Text('Check-Out Date: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('Total Cost: \$${totalCost.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Amount Paid: \$${amountPaid.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                    Text('Remaining Balance: \$${remainingBalance.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pdf = pw.Document();

                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Invoice Details', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 20),
                          pw.Text('Guest Name: $guestName', style: pw.TextStyle(fontSize: 18)),
                          pw.Text('Room Type: $roomType', style: pw.TextStyle(fontSize: 18)),
                          pw.Text('Room Number: $roomNumber', style: pw.TextStyle(fontSize: 18)),
                          pw.Text('Check-In Date: ${DateFormat('yyyy-MM-dd').format(checkInDate)}', style: pw.TextStyle(fontSize: 18)),
                          pw.Text('Check-Out Date: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}', style: pw.TextStyle(fontSize: 18)),
                          pw.SizedBox(height: 10),
                          pw.Text('Total Cost: \$${totalCost.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Amount Paid: \$${amountPaid.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
                          pw.Text('Remaining Balance: \$${remainingBalance.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, color: PdfColors.red)),
                        ],
                      );
                    },
                  ),
                );

                await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
              },
              child: Text('Print Invoice'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDBB017)),
            ),
          ],
        ),
      ),
    );
  }
}
