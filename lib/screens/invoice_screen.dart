import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              onPressed: () {
                // Here you can call the print functionality if needed
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
