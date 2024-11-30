import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';

class ReservationsAmountSection extends StatefulWidget {
  final bool showTodayOnly;

  ReservationsAmountSection({this.showTodayOnly = false});

  @override
  _ReservationsAmountSectionState createState() =>
      _ReservationsAmountSectionState();
}

class _ReservationsAmountSectionState extends State<ReservationsAmountSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double todayAmount = 0.0;
  double monthlyAmount = 0.0;
  Map<String, double> todayPaymentMethods = {};
  Map<String, double> monthlyPaymentMethods = {};

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
    QuerySnapshot todaySnapshot = await _firestore
        .collection('reservations')
        .where('checkInDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('checkInDate', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
        .get();
    double todayTotal = 0.0;
    Map<String, double> todayPayments = {};
    for (var doc in todaySnapshot.docs) {
      double cost = doc['totalCost'] ?? 0.0;
      todayTotal += cost;
      String paymentMethod = doc['paymentMethod'] ?? 'Unknown';
      todayPayments[paymentMethod] =
          (todayPayments[paymentMethod] ?? 0.0) + cost;
    }
    if (!widget.showTodayOnly) {
      QuerySnapshot monthlySnapshot = await _firestore
          .collection('reservations')
          .where('checkInDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();
      double monthlyTotal = 0.0;
      Map<String, double> monthlyPayments = {};
      for (var doc in monthlySnapshot.docs) {
        double cost = doc['totalCost'] ?? 0.0;
        monthlyTotal += cost;
        String paymentMethod = doc['paymentMethod'] ?? 'Unknown';
        monthlyPayments[paymentMethod] =
            (monthlyPayments[paymentMethod] ?? 0.0) + cost;
      }
      setState(() {
        monthlyAmount = monthlyTotal;
        monthlyPaymentMethods = monthlyPayments;
      });
    }
    setState(() {
      todayAmount = todayTotal;
      todayPaymentMethods = todayPayments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            S.current.reservationsamount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildAmountCard(S.current.todayreservations, todayAmount),
          const SizedBox(height: 8),
          if (!widget.showTodayOnly) ...[
            _buildAmountCard(S.current.monthreservations, monthlyAmount),
            const SizedBox(height: 16),
            Text(
              S.current.paymentmethods,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.current.todayspaymentmethods,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...todayPaymentMethods.entries
                .map((entry) => _buildAmountCard('${entry.key}', entry.value))
                .toList(),
            const SizedBox(height: 16),
            Text(
              S.current.monthlypaymentmethods,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...monthlyPaymentMethods.entries
                .map((entry) => _buildAmountCard('${entry.key}', entry.value))
                .toList(),
          ] else ...[
            Text(
              S.current.todayspaymentmethods,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...todayPaymentMethods.entries
                .map((entry) => _buildAmountCard('${entry.key}', entry.value))
                .toList(),
          ],
        ]),
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
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'Amiri',

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',

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
