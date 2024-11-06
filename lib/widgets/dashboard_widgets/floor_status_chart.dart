import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FloorStatusSection extends StatelessWidget {
  const FloorStatusSection({super.key});

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
              'Floor Status',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return const Text("Error loading data");
                }

                // Calculate the occupancy percentage
                final totalRooms = snapshot.data!.docs.length;
                final occupiedRooms = snapshot.data!.docs
                    .where((doc) => doc['status'] == 'Occupied')
                    .length;

                final occupancyPercentage =
                totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0.0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 61,
                      width: 61,
                      child: CustomPaint(
                        foregroundPainter:
                        CircleProgressPainter(occupancyPercentage),
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        SizedBox(width: 16),
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
