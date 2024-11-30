import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PackageOccupancyTable extends StatefulWidget {
  final int selectedYear;
  final ValueChanged<int> onYearChanged;

  const PackageOccupancyTable({Key? key, required this.selectedYear, required this.onYearChanged}) : super(key: key);

  @override
  _PackageOccupancyTableState createState() => _PackageOccupancyTableState();
}

class _PackageOccupancyTableState extends State<PackageOccupancyTable> {
  Map<String, List<double>> packageMonthlyOccupancy = {};
  List<String> packageTypes = [];

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPackageTypes();
  }

  Future<void> _fetchPackageTypes() async {
    final ratesCollection = FirebaseFirestore.instance.collection('rates');
    final querySnapshot = await ratesCollection.get();
    final List<String> packages = querySnapshot.docs.map((doc) => doc['roomType'].toString()).toList();

    setState(() {
      packageTypes = packages;
    });
    _fetchOccupancyData();
  }

  Future<void> _fetchOccupancyData() async {
    final reservationCollection = FirebaseFirestore.instance.collection('reservations');
    Map<String, List<int>> monthlyReservations = {};

    for (String package in packageTypes) {
      monthlyReservations[package] = List.filled(12, 0);
    }

    final querySnapshot = await reservationCollection
        .where('checkInDate', isGreaterThanOrEqualTo: DateTime(widget.selectedYear, 1, 1))
        .where('checkOutDate', isLessThan: DateTime(widget.selectedYear + 1, 1, 1))
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final packageType = data['packageType'];
      final checkInDate = (data['checkInDate'] as Timestamp).toDate();
      final checkOutDate = (data['checkOutDate'] as Timestamp).toDate();

      if (packageType != null && packageTypes.contains(packageType)) {
        int checkInMonth = checkInDate.month - 1;
        int checkOutMonth = checkOutDate.month - 1;

        for (int month = checkInMonth; month <= checkOutMonth; month++) {
          monthlyReservations[packageType]?[month] = (monthlyReservations[packageType]?[month] ?? 0) + 1;
        }
      }
    }

    setState(() {
      packageMonthlyOccupancy = monthlyReservations.map((package, monthsReserved) {
        final totalRooms = 20; // Adjust as necessary
        final occupancyPercentages = monthsReserved.map((reservedCount) {
          return (reservedCount / totalRooms) * 100;
        }).toList();
        return MapEntry(package, occupancyPercentages);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    Color titleColor = isMobile ? Color(0xFFDBB017) : Colors.black;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(titleColor),
            const SizedBox(height: 16),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Row _buildHeader(Color titleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Package Occupancy for ${widget.selectedYear}',
          style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.calendar_today, size: 20),
          onPressed: () => _selectYear(context),
        ),
      ],
    );
  }

  void _selectYear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Year'),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(5, (index) {
              int year = widget.selectedYear - index;
              return ListTile(
                title: Text('$year'),
                onTap: () {
                  widget.onYearChanged(year);
                  _fetchOccupancyData();
                  Navigator.pop(context);
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Package Type')),
          ...months.map((month) => DataColumn(label: Text(month))).toList(),
        ],
        rows: packageTypes.map((packageType) {
          final occupancyPercentages = packageMonthlyOccupancy[packageType] ?? List.filled(12, 0.0);
          Color rowColor = _getRowColor(packageType);

          return DataRow(
            color: MaterialStateProperty.all(rowColor),
            cells: [
              DataCell(Text(packageType)),
              ...occupancyPercentages.map((percentage) => DataCell(Text('${percentage.toStringAsFixed(1)}%'))).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getRowColor(String packageType) {
    // You can map your package type to different colors here.
    // For now, I'll cycle through a few colors.

    List<Color> rowColors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.yellow,
      Colors.redAccent,
      Colors.grey
    ];

    int index = packageTypes.indexOf(packageType);
    return rowColors[index % rowColors.length]; // Cycle colors
  }
}
