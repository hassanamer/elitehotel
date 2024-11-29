// lib/widgets/dashboard_widgets/overview_section.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OverviewSection extends StatelessWidget {
  final int checkInsToday;
  final int checkOutsToday;
  final int totalRooms;
  final int availableRooms;
  final int occupiedRooms;

  const OverviewSection({
    Key? key,
    required this.checkInsToday,
    required this.checkOutsToday,
    required this.totalRooms,
    required this.availableRooms,
    required this.occupiedRooms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.overview,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            screenWidth > 600 &&
                (kIsWeb ||
                    Platform.isWindows ||
                    Platform.isLinux ||
                    Platform.isMacOS)
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOverviewColumn(
                    screenWidth, S.current.todaysCheckIns, checkInsToday),
                _buildOverviewColumn(screenWidth,
                    S.current.todaysCheckOuts, checkOutsToday),
                _buildOverviewColumn(screenWidth, S.current.totalInHotel,
                    totalRooms),
                _buildOverviewColumn(screenWidth,
                    S.current.totalAvailableRooms, availableRooms),
                _buildOverviewColumn(screenWidth,
                    S.current.totalOccupiedRooms, occupiedRooms),
              ],
            )
                : Column(
              children: [
                _buildOverviewCardMobile(
                    S.current.todaysCheckInsMobile, checkInsToday),
                _buildOverviewCardMobile(
                    S.current.todaysCheckOutsMobile, checkOutsToday),
                _buildOverviewCardMobile(S.current.totalInHotelMobile,
                    occupiedRooms + availableRooms),
                _buildOverviewCardMobile(
                    S.current.totalAvailableRoomsMobile, availableRooms),
                _buildOverviewCardMobile(
                    S.current.totalOccupiedRoomsMobile, occupiedRooms),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewColumn(double screenWidth, String title, int value) {
    final titleLines = title.split('\n');

    // Desktop and Web layout (wide screens)
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
                      color: Color(0xFFDBB017),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCardMobile(String title, int value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDBB017),
              ),
            ),
          ],
        ),
      ),
    );
  }
}