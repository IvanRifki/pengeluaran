import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:pengeluaran/function/functions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartTipePengeluaran extends StatefulWidget {
  const PieChartTipePengeluaran({super.key});

  @override
  State<PieChartTipePengeluaran> createState() =>
      _PieChartTipePengeluaranState();
}

final db = DatabaseHelper.instance;

class PieChartData {
  final String xData;
  final num yData;
  final num percent;
  PieChartData(this.xData, this.yData, this.percent);
}

List<PieChartData> pieChartData = [];

class _PieChartTipePengeluaranState extends State<PieChartTipePengeluaran> {
  @override
  void initState() {
    super.initState();
    getPieChartData();
  }

  Future<void> getPieChartData() async {
    final data = await db.queryPieChartByType(DateTime.now().month);
    num totalnominal = data.fold(0,
        (sum, item) => sum + num.parse(removedot(removerp(item['nominal']))));

    pieChartData = data.map((item) {
      final nominal = num.parse(removedot(removerp(item['nominal'])));
      final percent = nominal * 100.0 / totalnominal;
      return PieChartData(item['tipe'], nominal, percent);
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      palette: const [
        Colors.blue,
        Colors.green,
        Colors.red,
        Colors.yellow,
        Colors.orange,
        Colors.purple
      ],
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.left,
        textStyle: TextStyle(fontSize: 12, color: Colors.white),
      ),
      series: <PieSeries<PieChartData, String>>[
        PieSeries<PieChartData, String>(
          legendIconType: LegendIconType.circle,
          explode: true,
          dataSource: pieChartData,
          xValueMapper: (PieChartData data, _) =>
              '${data.xData}\n${currencyFormatterRp.format(data.yData)}',
          yValueMapper: (PieChartData data, _) => data.yData,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            color: Colors.white,
            labelPosition: ChartDataLabelPosition.inside,
          ),
          dataLabelMapper: (PieChartData data, _) =>
              '${data.percent.toStringAsFixed(2)}%',
        ),
      ],
    );
  }
}
