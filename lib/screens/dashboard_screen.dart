import 'package:elitehotel/widgets/dashboard_widgets/reservations_amount_section.dart';
import 'package:flutter/material.dart';
import 'package:elitehotel/widgets/dashboard_widgets/overview_section.dart';
import 'package:elitehotel/widgets/dashboard_widgets/room_occupency_section.dart';
import 'package:elitehotel/widgets/dashboard_widgets/room_section.dart';

import '../generated/l10n.dart';
import '../widgets/dashboard_widgets/room_status_section.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text(
         S.current.mainDashboard,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color:  Colors.black,
          ),
        ),
        backgroundColor:  const Color(0xFFDBB017),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OverviewSection(),
            RoomsSection(),
            RoomStatusSection(),
            OccupancyStatistics(),
            ReservationsAmountSection(),
          ],
        ),
      ),
    );
  }
}
