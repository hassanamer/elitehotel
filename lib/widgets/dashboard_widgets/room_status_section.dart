import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/widgets/dashboard_widgets/floor_status_chart.dart';
import 'package:flutter/material.dart';

class RoomStatusSection extends StatefulWidget {
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
    _fetchRoomData();
  }

  Future<void> _fetchRoomData() async {
    try {
      final roomSnapshot = await _firestore.collection('rooms').get();
      int tempOccupiedClean = 0;
      int tempOccupiedDirty = 0;
      int tempAvailableClean = 0;
      int tempAvailableDirty = 0;

      for (var roomDoc in roomSnapshot.docs) {
        var roomData = roomDoc.data();
        bool isOccupied = roomData['status'] == 'Occupied';
        String cleaningStatus = roomData['cleaningStatus'];



        if (isOccupied) {
          if (cleaningStatus == 'Clean') {
            tempOccupiedClean++;
          } else if (cleaningStatus == 'Dirty') {
            tempOccupiedDirty++;
          }
        } else {
          bool isReserved = await _checkIfRoomIsReserved(roomDoc.id);

          if (!isReserved) {
            if (cleaningStatus == 'Clean') {
              tempAvailableClean++;
            } else if (cleaningStatus == 'Dirty') {
              tempAvailableDirty++;
            }
          }
        }
      }

      setState(() {
        occupiedCleanRooms = tempOccupiedClean;
        occupiedDirtyRooms = tempOccupiedDirty;
        availableCleanRooms = tempAvailableClean;
        availableDirtyRooms = tempAvailableDirty;
      });
    } catch (e) {
    }
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 350,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                     S.current.roomStatus ,
                    style: TextStyle(
                      fontSize: 20,
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
                        childAspectRatio: 1.7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatusTileWeb(
                              S.current.occupiedRooms,
                              occupiedCleanRooms.toString(),
                              occupiedDirtyRooms.toString()),
                          _buildStatusTileWeb(
                              S.current.availableRooms,
                              availableCleanRooms.toString(),
                              availableDirtyRooms.toString()),
                          FloorStatusSection(),
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
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                   S.current.roomStatus,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Adjust the number of columns based on screen width
                        int columns = constraints.maxWidth > 600 ? 3 : 1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  childAspectRatio: 2.3,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 4,
                                // Total number of items in the grid
                                itemBuilder: (context, index) {
                                  // Return the appropriate widget based on index
                                  switch (index) {
                                    case 0:
                                      return _buildStatusTile(
                                        S.current.occupiedRooms,
                                        occupiedCleanRooms.toString(),
                                        occupiedDirtyRooms.toString(),
                                      );
                                    case 1:
                                      return _buildStatusTile(
                                       S.current.availableRooms,
                                        availableCleanRooms.toString(),
                                        availableDirtyRooms.toString(),
                                      );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(), // Optional: To separate Floor Status visually
                             Text(
                              S.current.floorStatus,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FloorStatusSection(), // FloorStatus remains unaffected here

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

  Widget _buildStatusTileWeb(String title, String clean, String dirty) {
    Color cleanColor = Colors.green;
    Color dirtyColor = Colors.red;

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(S.current.clean, style: TextStyle(color: Colors.black)),
                  Text(
                    clean,
                    style: TextStyle(
                        color: cleanColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(S.current.dirty, style: TextStyle(color: Colors.black)),
                  Text(
                    dirty,
                    style: TextStyle(
                        color: dirtyColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTile(String title, String clean, String dirty) {
    Color cleanColor = Colors.green;
    Color dirtyColor = Colors.red;

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 80, // Fixed height for status tiles
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(S.current.clean, style: TextStyle(color: Colors.black)),
                    Text(
                      clean,
                      style: TextStyle(color: cleanColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(S.current.dirty, style: TextStyle(color: Colors.black)),
                    Text(
                      dirty,
                      style: TextStyle(color: dirtyColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
