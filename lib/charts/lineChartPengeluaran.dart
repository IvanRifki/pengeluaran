import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartPengeluaran extends StatefulWidget {
  const LineChartPengeluaran({super.key});

  @override
  State<LineChartPengeluaran> createState() => _LineChartPengeluaranState();
}

List<LineChartData> _chartdata = [];
Future<void> getChartData() async {
  final bulanini = DateFormat('MMMM').format(DateTime.now());
  final data = await db.queryLineChartPengeluaran(bulanini);
  _chartdata.clear();
  _chartdata = data
      .map((data) => LineChartData(data['TotalPengeluaran'],
          DateFormat('EEEE dd MMMM yyyy').parse(data['waktu'])))
      .toList();
}

final db = DatabaseHelper.instance;

class LineChartData {
  LineChartData(this.total, this.waktu);
  final DateTime waktu;
  final int total;
}

@override
void main() {
  getChartData();
  runApp(const LineChartPengeluaran());
}

class _LineChartPengeluaranState extends State<LineChartPengeluaran> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <CartesianSeries<LineChartData, DateTime>>[
        LineSeries<LineChartData, DateTime>(
          color: Color(0xFFFFC107),
          dataSource: _chartdata,
          xValueMapper: (LineChartData data, _) => data.waktu,
          yValueMapper: (LineChartData data, _) => data.total,
        )
      ],
    );
  }
}
