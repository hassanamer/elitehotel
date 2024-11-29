import 'package:elitehotel/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ratesData; // List of rates data with availability

  const RoomsSection({
    Key? key,
    required this.ratesData,
  }) : super(key: key);
  @override
  _RoomsSectionState createState() => _RoomsSectionState();
}

class _RoomsSectionState extends State<RoomsSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ratesData = [];
  final Map<String, String> _packageTranslations = {
    'Room (Egyptian)': 'غرفة (مصري)',
    'Room (Electronic warefare)': 'غرفة (حرب إلك)',
    'Room (Military)': 'غرفة (عسكري)',
    'Room (Foriegns)': 'غرفة (أجنبي)',
    'Mini Suite (Egyptian)': 'ميني سويت (مصري)',
    'Mini Suite (Electronic warefare)': 'ميني سويت (حرب إلك)',
    'Mini Suite (Military)': 'ميني سويت (عسكري)',
    'Mini Suite (Foriegns)': 'ميني سويت (أجنبي)',
    'Suite (Egyptian)': 'سويت (مصري)',
    'Suite (Electonice warefare)': 'سويت (حرب إلك)',
    'Suite (Military)': 'سويت (عسكري)',
    'Suite (Foriegns)': 'سويت (أجنبي)',
    'Wedding Package': 'باكيدج فرح',
    'Wedding Package solitaire': 'باكيدج قاعة سولتير',
    'Wedding Package Akasia': 'باكيدج قاعة أكاسيا',
    'Wedding Extra Suite[Egp]': 'سويت فرح اضافي(مصري)',
    'Wedding Extra Suite[Foriegn]': 'سويت فرح اضافي(اجنبي)',
    'Wedding Extra R[Foriegn]': 'غرفة فرح اضافية(اجنبي)',
    'Wedding Extra R[Egp]': 'غرفة فرح اضافية(مصري)',
  };
  // Function to translate package names to Arabic
  String _translatePackageName(String packageName) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return _packageTranslations[packageName] ??
          packageName; // Use original if no translation
    }
    return packageName; // Return the original if the locale is not Arabic
  }

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    // Fetch all rates and rooms in a single batch
    final ratesSnapshot = await _firestore.collection('rates').get();
    final roomsSnapshot = await _firestore.collection('rooms').get();

    // Create a map of roomType to available rooms count
    Map<String, int> roomAvailability = {};
    for (var roomDoc in roomsSnapshot.docs) {
      final roomData = roomDoc.data() as Map<String, dynamic>;
      if (roomData['status'] == 'Available') {
        final roomType = roomData['roomType'];
        roomAvailability[roomType] = (roomAvailability[roomType] ?? 0) + 1;
      }
    }

    // Combine rates data with availability data
    ratesData = ratesSnapshot.docs.map((rateDoc) {
      final rateData = rateDoc.data() as Map<String, dynamic>;
      final roomType = rateData['roomType'];
      return {
        ...rateData,
        'availability': roomAvailability[roomType] ?? 0, // Add availability count
      };
    }).toList();

    setState(() {}); // Refresh the UI
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
               Text(
                 S.current.rooms ,
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
                      '${rate['rate'] ?? '0'}/${S.current.day}', // Display rate
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
               Text(
               S.current.rooms,
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
                _translatePackageName(title),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Increase font size
              ),
              const SizedBox(height: 8),
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
