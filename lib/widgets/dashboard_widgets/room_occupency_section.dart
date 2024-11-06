import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OccupancyStatistics extends StatefulWidget {
  @override
  _OccupancyStatisticsState createState() => _OccupancyStatisticsState();
}

class _OccupancyStatisticsState extends State<OccupancyStatistics> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedYear = DateTime.now().year;
  List<int> monthlyOccupancy = List.filled(12, 0);

  @override
  void initState() {
    super.initState();
    _fetchOccupancyData();
  }

  void _fetchOccupancyData() async {
    List<double> newMonthlyOccupancy = List.filled(12, 0.0);

    final roomsSnapshot = await _firestore.collection('rooms').get();
    final totalRooms = roomsSnapshot.size;

    final reservationsSnapshot = await _firestore
        .collection('reservations')
        .where('checkInDate', isGreaterThanOrEqualTo: DateTime(selectedYear, 1))
        .where('checkOutDate', isLessThan: DateTime(selectedYear + 1, 1))
        .get();

    for (var doc in reservationsSnapshot.docs) {
      final checkInDate = (doc['checkInDate'] as Timestamp).toDate();
      final checkOutDate = (doc['checkOutDate'] as Timestamp).toDate();

      for (int month = 1; month <= 12; month++) {
        DateTime monthStart = DateTime(selectedYear, month, 1);
        DateTime monthEnd = DateTime(selectedYear, month + 1, 0);

        if (checkInDate.isBefore(monthEnd) && checkOutDate.isAfter(monthStart)) {
          DateTime effectiveStart = checkInDate.isBefore(monthStart) ? monthStart : checkInDate;
          DateTime effectiveEnd = checkOutDate.isAfter(monthEnd) ? monthEnd : checkOutDate;

          int daysOccupiedInMonth = effectiveEnd.difference(effectiveStart).inDays + 1;

          newMonthlyOccupancy[month - 1] += daysOccupiedInMonth;
        }
      }
    }

    List<int> integerMonthlyOccupancy = newMonthlyOccupancy
        .map((occupancy) => ((occupancy / (totalRooms * 30)) * 100).round())
        .toList();

    setState(() {
      monthlyOccupancy = integerMonthlyOccupancy;
    });
  }

  void _selectYear() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = selectedYear;
        return AlertDialog(
          title: Text('Select Year'),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                DropdownButton<int>(
                  value: tempYear,
                  items: List.generate(
                    10,
                        (index) => DropdownMenuItem<int>(
                      value: DateTime.now().year - index,
                      child: Text((DateTime.now().year - index).toString()),
                    ),
                  ),
                  onChanged: (year) {
                    setState(() {
                      tempYear = year!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(tempYear);
              },
            ),
          ],
        );
      },
    );

    if (selected != null && selected != selectedYear) {
      setState(() {
        selectedYear = selected;
        _fetchOccupancyData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the device is mobile
    bool isMobile = MediaQuery.of(context).size.width < 600; // Adjust the width threshold as needed
    Color titleColor = isMobile ? Color(0xFFDBB017) : Colors.black; //
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Occupancy Statistics ($selectedYear)',
                  style:  TextStyle(color:titleColor,fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, size: 20),
                  onPressed: _selectYear,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                double chartHeight = constraints.maxWidth < 600 ? 500 : 350;
                double barWidth = constraints.maxWidth < 600 ? 20 : 15;

                return AspectRatio(
                  aspectRatio: 1.6,
                  child: Container(
                    height: chartHeight,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barGroups: _buildBarGroups(barWidth),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                ];
                                return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                if (value % 20 == 0) {
                                  return Text('${value.toInt()}%', style: const TextStyle(fontSize: 8));
                                }
                                return Container();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(double barWidth) {
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthlyOccupancy[index].toDouble(),
            color: Colors.blue,
            width: barWidth,
            borderRadius: BorderRadius.circular(7),
          ),
        ],
      );
    });
  }
}
