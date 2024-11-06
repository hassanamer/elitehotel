import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewSection extends StatefulWidget {
  @override
  _OverviewSectionState createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection> {
  int checkInsToday = 0;
  int checkOutsToday = 0;
  int totalRooms = 0;
  int availableRooms = 0;
  int occupiedRooms = 0;

  @override
  void initState() {
    super.initState();
    fetchOverviewData();
  }

  Future<void> fetchOverviewData() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    // Fetch room data
    try {
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance.collection('rooms').get();
      totalRooms = roomSnapshot.docs.length;
      availableRooms = roomSnapshot.docs.where((doc) => doc['status'] == 'Available').length;
      occupiedRooms = roomSnapshot.docs.where((doc) => doc['status'] == 'Occupied').length;
    } catch (e) {
      print("Error fetching rooms: $e");
    }

    // Fetch reservations data
    try {
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('checkInDate', isGreaterThanOrEqualTo: startOfDay)
          .where('checkInDate', isLessThanOrEqualTo: endOfDay)
          .get();
      checkInsToday = reservationSnapshot.docs.length;

      QuerySnapshot checkOutSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('checkOutDate', isGreaterThanOrEqualTo: startOfDay)
          .where('checkOutDate', isLessThanOrEqualTo: endOfDay)
          .get();
      checkOutsToday = checkOutSnapshot.docs.length;
    } catch (e) {
      print("Error fetching reservations: $e");
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOverviewColumn("Today's\nCheck-ins", checkInsToday),
                _buildOverviewColumn("Today's\nCheck-outs", checkOutsToday),
                _buildOverviewColumn("Total\nIn Hotel", occupiedRooms + availableRooms),
                _buildOverviewColumn("Total\nAvailable Rooms", availableRooms),
                _buildOverviewColumn("Total\nOccupied Rooms", occupiedRooms),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column _buildOverviewColumn(String title, int value) {
    final titleLines = title.split('\n');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: titleLines[0],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const TextSpan(
                    text: "\n",
                    style: TextStyle(
                      color: Colors.transparent,
                    ),
                  ),
                  TextSpan(
                    text: titleLines[1],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const TextSpan(
                    text: "   ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: value.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:  Color(0xFFDBB017),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
