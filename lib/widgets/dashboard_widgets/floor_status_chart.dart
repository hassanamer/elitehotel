import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FloorStatusSection extends StatelessWidget {
  const FloorStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                // Updated group rooms by floor logic
                final roomsByFloor = <String, List<DocumentSnapshot>>{};
                for (var doc in snapshot.data!.docs) {
                  final floor = doc['roomFloor'].toString(); // Convert roomFloor to String
                  if (!roomsByFloor.containsKey(floor)) {
                    roomsByFloor[floor] = [];
                  }
                  roomsByFloor[floor]!.add(doc);
                }


                // Build a list of floor occupancy widgets
                return Column(
                  children: roomsByFloor.entries.map((entry) {
                    final floor = entry.key;
                    final rooms = entry.value;
                    final totalRooms = rooms.length;
                    final occupiedRooms = rooms.where((doc) => doc['status'] == 'Occupied').length;
                    final occupancyPercentage = totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Floor $floor',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 61,
                            width: 61,
                            child: CustomPaint(
                              foregroundPainter: CircleProgressPainter(occupancyPercentage),
                              child: Center(
                                child: Text(
                                  '${occupancyPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: occupancyPercentage >= 100 ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.circle, color: Colors.red, size: 10),
                                  SizedBox(width: 4),
                                  Text(
                                    'Occupied',
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
                                    'Available',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
