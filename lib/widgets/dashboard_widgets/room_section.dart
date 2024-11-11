import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomsSection extends StatefulWidget {
  @override
  _RoomsSectionState createState() => _RoomsSectionState();
}

class _RoomsSectionState extends State<RoomsSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ratesData = [];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    // Fetch all rates from the rates collection
    QuerySnapshot ratesSnapshot = await _firestore.collection('rates').get();

    // Initialize ratesData with rate information
    ratesData = ratesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Update ratesData with availability from the rooms collection
    for (var rate in ratesData) {
      String roomType = rate['roomType'];
      QuerySnapshot roomSnapshot = await _firestore.collection('rooms')
          .where('roomType', isEqualTo: roomType)
          .get();

      // Calculate the available rooms
      int availableRooms = roomSnapshot.docs.where((doc) => doc['status'] == 'Available').length;

      // Update the availability in the rates data
      rate['availability'] = availableRooms;
    }

    setState(() {}); // Refresh the UI after fetching rates and availability
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    if (screenWidth > 600) {
      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rooms',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Rooms Overview
              Container(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  // Adjust to fit four items per row
                  childAspectRatio: 2,
                  // Adjust aspect ratio
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // Disable scroll for GridView
                  children: ratesData.map((rate) {
                    return _buildRoomTile(
                      rate['roomType'] ?? 'Unknown',
                      '${rate['availability'] ?? 0}', // Display availability
                      '\$${rate['rate'] ?? '0'}/day', // Display rate
                      '2 Days', // Placeholder for badge text
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }else{
      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rooms',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Rooms Overview
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate number of columns based on available width
                  int columns = constraints.maxWidth > 600 ? 4 : 1; // Use 4 columns for larger screens, 2 for smaller ones

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 2,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ratesData.length,
                      itemBuilder: (context, index) {
                        final rate = ratesData[index];
                        return _buildRoomTile(
                          rate['roomType'] ?? 'Unknown',
                          '${rate['availability'] ?? 0}', // Display availability
                          '\$${rate['rate'] ?? '0'}/day', // Display rate
                          '2 Days', // Placeholder for badge text
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );

    }
  }

  Widget _buildRoomTile(String title, String status, String price, String badgeText) {
    return Container(
      margin: const EdgeInsets.all(8.0), // Add margin for spacing
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Adjust border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Increase padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Increase font size
              ),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey)), // Style status
              const SizedBox(height: 1),
              Text(
                price,
                style: const TextStyle(color:  Color(0xFFDBB017), fontSize: 20, fontWeight: FontWeight.bold), // Increase font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}
