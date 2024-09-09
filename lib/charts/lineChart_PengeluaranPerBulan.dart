import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:pengeluaran/function/functions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartPengeluaranPerBulan extends StatefulWidget {
  DateTime? waktuPengeluaran;
  LineChartPengeluaranPerBulan(this.waktuPengeluaran, {super.key});

  @override
  State<LineChartPengeluaranPerBulan> createState() =>
      _LineChartPengeluaranPerBulanState();
}

final db = DatabaseHelper.instance;

List<LineChartData> _chartdata = [];
DateTime? waktuPengeluaran;

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
    getChartData(widget.waktuPengeluaran);
  }

  Future<void> getChartData(waktuPengeluaran) async {
    waktuPengeluaran = waktuPengeluaran ?? DateTime.now().month;

    final bulanini = bulanSekarang();
    print(
        'ini ada di linechart ${dtFormatMMMM(waktuPengeluaran)} ini datemonth ${DateTime.now().month} ini bulansekarang $bulanini ');

    final data =
        await db.queryLineChartPengeluaran(dtFormatMMMM(waktuPengeluaran));
    _chartdata.clear();

    if (data.isNotEmpty) {
      setState(() {
        _chartdata = data
            .map((data) => LineChartData(
                int.parse(
                  removedot(removerp(data['TotalPengeluaran'])),
                ),
                DateFormat('dd MMM').format(DateFormat('EEEE dd MMMM yyyy')
                    .parse(data['waktu'] as String))))
            .toList();
      });
    } else {
      setState(() {
        _chartdata = [];
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
              return currencyFormatterRp.format(datum.total);
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
