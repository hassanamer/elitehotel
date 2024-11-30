import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';

class FloorStatusSection extends StatelessWidget {
  const FloorStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 400, // Set the height of the card here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text("Error loading data");
                  }

                  // Group rooms by floor and calculate occupancy for each floor
                  final roomsByFloor = <String, List<DocumentSnapshot>>{};
                  int totalRooms = 0;
                  int totalOccupiedRooms = 0;

                  for (var doc in snapshot.data!.docs) {
                    final floor = doc['roomFloor'].toString(); // Convert roomFloor to String
                    if (!roomsByFloor.containsKey(floor)) {
                      roomsByFloor[floor] = [];
                    }
                    roomsByFloor[floor]!.add(doc);

                    // Count total rooms and total occupied rooms
                    totalRooms++;
                    if (doc['status'] == 'Occupied') {
                      totalOccupiedRooms++;
                    }
                  }

                  // Calculate total occupancy percentage
                  final totalOccupancyPercentage = totalRooms > 0 ? (totalOccupiedRooms / totalRooms) * 100 : 0.0;

                  // Build a list of floor occupancy widgets
                  return Column(
                    children: [
                      // Individual floor charts in a Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: roomsByFloor.entries.map((entry) {
                          final floor = entry.key;
                          final rooms = entry.value;
                          final floorTotalRooms = rooms.length;
                          final floorOccupiedRooms =
                              rooms.where((doc) => doc['status'] == 'Occupied').length;
                          final floorOccupancyPercentage =
                          floorTotalRooms > 0 ? (floorOccupiedRooms / floorTotalRooms) * 100 : 0.0;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: Column(
                                children: [
                                  Text(
                                    '${S.current.floor} $floor',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 70,
                                    width: 61,
                                    child: CustomPaint(
                                      foregroundPainter: CircleProgressPainter(floorOccupancyPercentage),
                                      child: Center(
                                        child: Text(
                                          '${floorOccupancyPercentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontSize: floorOccupancyPercentage >= 100 ? 20 : 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const Divider(),

                      // Total hotel occupancy chart
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.current.totalhotel,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 61,
                              width: 61,
                              child: CustomPaint(
                                foregroundPainter: CircleProgressPainter(totalOccupancyPercentage),
                                child: Center(
                                  child: Text(
                                    '${totalOccupancyPercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: totalOccupancyPercentage >= 100 ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.circle, color: Colors.red, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      S.current.occupied,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.circle, color: Colors.grey, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      S.current.available,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint baseCircle = Paint()
      ..strokeWidth = 8.0
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = 8.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Draw background circle
    canvas.drawCircle(center, radius, baseCircle);

    // Draw the arc for the progress
    double angle = 2 * 3.141592653589793 * (progress / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2, // Start from the top
      angle,
      false,
      completeArc,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
