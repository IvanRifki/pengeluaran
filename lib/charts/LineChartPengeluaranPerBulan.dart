import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:pengeluaran/function/functions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartPengeluaranPerBulan extends StatefulWidget {
  const LineChartPengeluaranPerBulan({super.key});

  @override
  State<LineChartPengeluaranPerBulan> createState() =>
      _LineChartPengeluaranPerBulanState();
}

final db = DatabaseHelper.instance;

NumberFormat currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

List<LineChartData> _chartdata = [];

class LineChartData {
  LineChartData(this.total, this.waktu);
  final String waktu;
  final int total;
}

class _LineChartPengeluaranPerBulanState
    extends State<LineChartPengeluaranPerBulan> {
  @override
  void initState() {
    super.initState();
    getChartData();
  }

  Future<void> getChartData() async {
    final bulanini = DateFormat('MMMM').format(DateTime.now());
    final data = await db.queryLineChartPengeluaran(bulanini);
    _chartdata.clear();

    if (data.isNotEmpty) {
      setState(() {
        _chartdata = data
            .map((data) => LineChartData(
                int.parse(
                  removedot(removerp(data['TotalPengeluaran'])),
                ),
                // data['TotalPengeluaran'] as int,
                DateFormat('dd-MMMM').format(DateFormat('EEEE dd MMMM yyyy')
                    .parse(data['waktu'] as String))))
            .toList();
      });
    } else {
      setState(() {
        _chartdata =
            []; // Ensure _chartdata is set to an empty list if no data is available
      });
    }
  }

  _builChart() {
    if (_chartdata.isNotEmpty) {
      return SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          textStyle: TextStyle(color: Colors.white),
          position: LegendPosition.bottom,
        ),
        tooltipBehavior: TooltipBehavior(
          shadowColor: Colors.black,
          enable: true,
          canShowMarker: true,
          activationMode: ActivationMode.singleTap,
        ),
        zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true,
            enablePinching: true,
            enableDoubleTapZooming: true),
        primaryYAxis: const NumericAxis(
          labelStyle: TextStyle(color: Colors.white),
        ),
        primaryXAxis: const CategoryAxis(
          labelStyle: TextStyle(color: Colors.white),
        ),
        series: <CartesianSeries<LineChartData, String>>[
          LineSeries<LineChartData, String>(
            color: const Color(0xFFFFC107),
            name: 'Banyaknya Pengeluaran',
            enableTooltip: true,
            dataSource: _chartdata,
            xValueMapper: (LineChartData data, _) => data.waktu,
            yValueMapper: (LineChartData data, _) => data.total,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              color: Colors.amber,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            dataLabelMapper: (datum, index) {
              return currencyFormatter.format(datum.total);
            },
            markerSettings:
                const MarkerSettings(isVisible: true, color: Colors.red),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _chartdata.isNotEmpty ? _builChart() : Container();
  }
}
