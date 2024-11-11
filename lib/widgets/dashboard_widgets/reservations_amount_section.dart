import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReservationsAmountSection extends StatefulWidget {
  @override
  _ReservationsAmountSectionState createState() => _ReservationsAmountSectionState();
}

class _ReservationsAmountSectionState extends State<ReservationsAmountSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double todayAmount = 0.0;
  double monthlyAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReservationAmounts();
  }




  Future<void> _fetchReservationAmounts() async {
    DateTime now = DateTime.now();

    // Start and end of today
    DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0); // Start of today
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today

    // Start of the current month
    DateTime monthStart = DateTime(now.year, now.month, 1); // Start of this month

    // Log the values to check the DateTime format
    print('Today start: $todayStart');
    print('Today end: $todayEnd');
    print('Month start: $monthStart');

    // Fetch today's reservations
    QuerySnapshot todaySnapshot = await _firestore.collection('reservations')
        .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('checkInDate', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
        .get();

    // Fetch reservations for this month
    QuerySnapshot monthlySnapshot = await _firestore.collection('reservations')
        .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .get();

    // Initialize total cost variables
    double todayTotal = 0.0;
    double monthlyTotal = 0.0;

    // Calculate the total cost for today's reservations
    for (var doc in todaySnapshot.docs) {
      print('Today reservation: ${doc['checkInDate']}');
      if (doc['totalCost'] != null) {
        todayTotal += (doc['totalCost'] ?? 0.0);
      }
    }

    // Calculate the total cost for this month's reservations
    for (var doc in monthlySnapshot.docs) {
      print('Monthly reservation: ${doc['checkInDate']}');
      if (doc['totalCost'] != null) {
        monthlyTotal += (doc['totalCost'] ?? 0.0);
      }
    }

    // Update the UI state with the calculated totals
    setState(() {
      todayAmount = todayTotal;
      monthlyAmount = monthlyTotal;
    });

    // Debugging the results
    print('Today\'s Total: $todayTotal');
    print('This Month\'s Total: $monthlyTotal');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reservations Amount',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Today's Amount
            _buildAmountRow('Today\'s Reservations:', todayAmount),
            const SizedBox(height: 8),
            // This Month's Amount
            _buildAmountRow('This Month\'s Reservations:', monthlyAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDBB017),
          ),
        ),
      ],
    );
  }
}
