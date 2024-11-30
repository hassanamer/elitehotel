import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/widgets/dashboard_widgets/floor_status_chart.dart';
import 'package:flutter/material.dart';

class RoomStatusSection extends StatefulWidget {
  final int occupiedCleanRooms; // Number of occupied clean rooms
  final int occupiedDirtyRooms; // Number of occupied dirty rooms
  final int availableCleanRooms; // Number of available clean rooms
  final int availableDirtyRooms; // Number of available dirty rooms

  const RoomStatusSection({
    Key? key,
    required this.occupiedCleanRooms,
    required this.occupiedDirtyRooms,
    required this.availableCleanRooms,
    required this.availableDirtyRooms,
  }) : super(key: key);

  @override
  _RoomStatusSectionState createState() => _RoomStatusSectionState();
}

class _RoomStatusSectionState extends State<RoomStatusSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int occupiedCleanRooms = 0;
  int occupiedDirtyRooms = 0;
  int availableCleanRooms = 0;
  int availableDirtyRooms = 0;

  @override
  void initState() {
    super.initState();
  }


  Future<bool> _checkIfRoomIsReserved(String roomId) async {
    try {
      final reservations = await _firestore
          .collection('reservations')
          .where('roomNumber', isEqualTo: roomId)
          .where('checkOutDate', isGreaterThanOrEqualTo: DateTime.now())
          .get();

      return reservations.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 400,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.current.roomStatus,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 1.3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatusTileWeb(
                            S.current.occupiedRooms,
                            widget.occupiedCleanRooms.toString(),
                            widget.occupiedDirtyRooms.toString(),
                            Icons.cancel,
                            Colors.red,
                          ),
                          _buildStatusTileWeb(
                            S.current.availableRooms,
                            widget.availableCleanRooms.toString(),
                            widget.availableDirtyRooms.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          // Increased height of the FloorStatusSection container
                          Container(
                            height: 350, // Increased the height here
                            child: FloorStatusSection(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 700,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.current.roomStatus,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int columns = constraints.maxWidth > 600 ? 3 : 1;
                        return Column(
                          children: [
                            GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: 2.5,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                switch (index) {
                                  case 0:
                                    return _buildStatusTile(
                                      S.current.occupiedRooms,
                                      occupiedCleanRooms.toString(),
                                      occupiedDirtyRooms.toString(),
                                      Icons.cancel,
                                      Colors.red,
                                    );
                                  case 1:
                                    return _buildStatusTile(
                                      S.current.availableRooms,
                                      availableCleanRooms.toString(),
                                      availableDirtyRooms.toString(),
                                      Icons.check_circle,
                                      Colors.green,
                                    );
                                  default:
                                    return Container();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            Text(
                              S.current.floorStatus,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Increased height for mobile as well
                            Container(
                              height: 350,
                              // Increased the height here for mobile
                              child: FloorStatusSection(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

Widget _buildStatusTileWeb(
  String title,
  String clean,
  String dirty,
  IconData icon,
  Color iconColor,
) {
  return Container(
    margin: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      gradient: LinearGradient(
        colors: [Colors.white, Colors.blue.shade100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade400,
          blurRadius: 8.0,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.current.clean,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  clean,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.current.dirty,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                  ),
                ),
                Text(
                  dirty,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatusTile(
  String title,
  String clean,
  String dirty,
  IconData icon,
  Color iconColor,
) {
  return Card(
    elevation: 4,
    color: Colors.blue.shade50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$clean ${S.current.clean} / $dirty ${S.current.dirty}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
