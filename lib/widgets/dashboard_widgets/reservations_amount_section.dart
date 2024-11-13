import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    DateTime todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    DateTime monthStart = DateTime(now.year, now.month, 1);

    QuerySnapshot todaySnapshot = await _firestore.collection('reservations')
        .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('checkInDate', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
        .get();

    QuerySnapshot monthlySnapshot = await _firestore.collection('reservations')
        .where('checkInDate', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .get();

    double todayTotal = 0.0;
    double monthlyTotal = 0.0;

    for (var doc in todaySnapshot.docs) {
      if (doc['totalCost'] != null) {
        todayTotal += (doc['totalCost'] ?? 0.0);
      }
    }

    for (var doc in monthlySnapshot.docs) {
      if (doc['totalCost'] != null) {
        monthlyTotal += (doc['totalCost'] ?? 0.0);
      }
    }

    setState(() {
      todayAmount = todayTotal;
      monthlyAmount = monthlyTotal;
    });
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
             Text(
              S.current.reservationsamount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Today's Reservations Card
            _buildAmountCard(S.current.todayreservations, todayAmount),
            const SizedBox(height: 8),
            // This Month's Reservations Card
            _buildAmountCard(S.current.monthreservations, monthlyAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(String title, double amount) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis ,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDBB017),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
