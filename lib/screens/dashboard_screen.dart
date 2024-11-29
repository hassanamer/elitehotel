import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:elitehotel/widgets/dashboard_widgets/reservations_amount_section.dart';
import 'package:elitehotel/widgets/dashboard_widgets/overview_section.dart';
import 'package:elitehotel/widgets/dashboard_widgets/room_occupency_section.dart';
import 'package:elitehotel/widgets/dashboard_widgets/room_section.dart';
import 'package:elitehotel/widgets/dashboard_widgets/room_status_section.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int checkInsToday = 0;
  int checkOutsToday = 0;
  int totalRooms = 0;
  int availableRooms = 0;
  int occupiedRooms = 0;
  List<Map<String, dynamic>> ratesData = [];
  int occupiedCleanRooms = 0;
  int occupiedDirtyRooms = 0;
  int availableCleanRooms = 0;
  int availableDirtyRooms = 0;
  int selectedYear = DateTime.now().year;
  List<int> monthlyOccupancy = List.filled(12, 0);

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      // Fetch room data
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance.collection('rooms').get();
      totalRooms = roomSnapshot.docs.length;
      availableRooms = roomSnapshot.docs.where((doc) => doc['status'] == 'Available').length;

      // Fetch reservations for today
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('checkInDate', isLessThanOrEqualTo: endOfDay)
          .where('checkOutDate', isGreaterThanOrEqualTo: startOfDay)
          .get();

      checkInsToday = reservationSnapshot.docs.where((doc) {
        final checkInDate = (doc['checkInDate'] as Timestamp).toDate();
        return checkInDate.year == today.year &&
            checkInDate.month == today.month &&
            checkInDate.day == today.day;
      }).length;

      occupiedRooms = reservationSnapshot.docs.length;

      QuerySnapshot checkOutSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('checkOutDate', isGreaterThanOrEqualTo: startOfDay)
          .where('checkOutDate', isLessThanOrEqualTo: endOfDay)
          .get();

      checkOutsToday = checkOutSnapshot.docs.length;
      availableRooms = totalRooms - occupiedRooms;

      // Fetch rates and rooms for RoomsSection
      QuerySnapshot ratesSnapshot = await FirebaseFirestore.instance.collection('rates').get();
      ratesData = ratesSnapshot.docs.map((rateDoc) {
        final rateData = rateDoc.data() as Map<String, dynamic>;
        return {
          ...rateData,
          'availability': roomSnapshot.docs.where((roomDoc) => roomDoc['roomType'] == rateData['roomType'] && roomDoc['status'] == 'Available').length,
        };
      }).toList();

      // Fetch room status
      occupiedCleanRooms = roomSnapshot.docs.where((roomDoc) => roomDoc['status'] == 'Occupied' && roomDoc['cleaningStatus'] == 'Clean').length;
      occupiedDirtyRooms = roomSnapshot.docs.where((roomDoc) => roomDoc['status'] == 'Occupied' && roomDoc['cleaningStatus'] == 'Dirty').length;
      availableCleanRooms = roomSnapshot.docs.where((roomDoc) => roomDoc['status'] == 'Available' && roomDoc['cleaningStatus'] == 'Clean').length;
      availableDirtyRooms = roomSnapshot.docs.where((roomDoc) => roomDoc['status'] == 'Available' && roomDoc['cleaningStatus'] == 'Dirty').length;

      // Calculate monthly occupancy
      monthlyOccupancy = await _calculateMonthlyOccupancy(totalRooms);

    } catch (e) {
      print("Error fetching data: $e");
    }

    setState(() {});
  }

  Future<List<int>> _calculateMonthlyOccupancy(int totalRooms) async {
    List<double> newMonthlyOccupancy = List.filled(12, 0.0);
    final reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('checkInDate', isGreaterThanOrEqualTo: DateTime(selectedYear, 1))
        .where('checkOutDate', isLessThan: DateTime(selectedYear + 1, 1))
        .get();

    for (var doc in reservationsSnapshot.docs) {
      final checkInDate = (doc['checkInDate'] as Timestamp).toDate();
      final checkOutDate = (doc['checkOutDate'] as Timestamp).toDate();

      for (int month = 1; month <= 12; month++) {
        DateTime monthStart = DateTime(selectedYear, month, 1);
        DateTime monthEnd = DateTime(selectedYear, month + 1, 0);

        if (checkInDate.isBefore(monthEnd) && checkOutDate.isAfter(monthStart)) {
          DateTime effectiveStart = checkInDate.isBefore(monthStart) ? monthStart : checkInDate;
          DateTime effectiveEnd = checkOutDate.isAfter(monthEnd) ? monthEnd : checkOutDate;

          int daysOccupiedInMonth = effectiveEnd.difference(effectiveStart).inDays + 1;
          newMonthlyOccupancy[month - 1] += daysOccupiedInMonth;
        }
      }
    }

    return newMonthlyOccupancy
        .map((occupancy) => ((occupancy / (totalRooms * 30)) * 100).round())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          S.current.mainDashboard,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Amiri',
          ),
        ),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OverviewSection(
              checkInsToday: checkInsToday,
              checkOutsToday: checkOutsToday,
              totalRooms: totalRooms,
              availableRooms: availableRooms,
              occupiedRooms: occupiedRooms,
            ),
            RoomsSection(ratesData: ratesData),
            RoomStatusSection(
              occupiedCleanRooms: occupiedCleanRooms,
              occupiedDirtyRooms: occupiedDirtyRooms,
              availableCleanRooms: availableCleanRooms,
              availableDirtyRooms: availableDirtyRooms,
            ),
            OccupancyStatistics(
              selectedYear: selectedYear,
              monthlyOccupancy: monthlyOccupancy,
              onYearSelected: _selectYear,
            ),
            ReservationsAmountSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectYear() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = selectedYear;
        return AlertDialog(
          title: Text(S.current.selectYear),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                DropdownButton<int>(
                  value: tempYear,
                  items: List.generate(
                    10,
                        (index) => DropdownMenuItem<int>(
                      value: DateTime.now().year - index,
                      child: Text((DateTime.now().year - index).toString()),
                    ),
                  ),
                  onChanged: (year) {
                    setState(() {
                      tempYear = year!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(S.current.ok),
              onPressed: () {
                Navigator.of(context).pop(tempYear);
              },
            ),
          ],
        );
      },
    );

    if (selected != null && selected != selectedYear) {
      setState(() {
        selectedYear = selected;
        fetchAllData(); // Re-fetch data for the new year
      });
    }
  }
}