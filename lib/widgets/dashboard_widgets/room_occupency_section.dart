import 'package:elitehotel/generated/l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OccupancyStatistics extends StatelessWidget {
  final int selectedYear;
  final List<int> monthlyOccupancy;
  final Function onYearSelected;

  const OccupancyStatistics({
    Key? key,
    required this.selectedYear,
    required this.monthlyOccupancy,
    required this.onYearSelected,
  }) : super(key: key);

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
            _buildChart(),
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
          '${S.current.occupancyStatistics} ($selectedYear)',
          style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.calendar_today, size: 20),
          onPressed: () => onYearSelected(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
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
                        var months = [
                          S.current.jan,
                          S.current.feb,
                          S.current.mar,
                          S.current.apr,
                          S.current.may,
                          S.current.jun,
                          S.current.jul,
                          S.current.aug,
                          S.current.sep,
                          S.current.oct,
                          S.current.nov,
                          S.current.dec,
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