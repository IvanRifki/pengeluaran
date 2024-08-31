import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartTipePengeluaran extends StatefulWidget {
  const PieChartTipePengeluaran({super.key});

  @override
  State<PieChartTipePengeluaran> createState() =>
      _PieChartTipePengeluaranState();
}

final db = DatabaseHelper.instance;

NumberFormat currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
  name: 'IDR',
);

class PieChartData {
  final String xData;
  final num yData;
  final num percent;
  PieChartData(this.xData, this.yData, this.percent);
}

final List<PieChartData> pieChartData = [];

class _PieChartTipePengeluaranState extends State<PieChartTipePengeluaran> {
  @override
  void initState() {
    setState(() {
      getPieChartData();
    });
    super.initState();
  }

  Future<void> getPieChartData() async {
    final data = await db.queryPieChartByType(DateTime.now().month);
    num totalnominal = 0;
    List<PieChartData> transformData(List<Map<String, dynamic>> data) {
      return data
          .map((item) =>
              PieChartData(item['tipe'], item['nominal'], item['nominal']))
          .toList();
    }

    for (int i = 0; i < data.length; i++) {
      totalnominal = totalnominal + data[i]['nominal'] / 2;
    }

    pieChartData.clear();

    for (int i = 0; i < data.length; i++) {
      DateTime waktu = DateFormat('EEEE dd MMMM yyyy').parse(data[i]['waktu']);
      // pieChartData.add(PieChartData(data[i]['tipe'], data[i]['nominal'],
      //     data[i]['nominal'] * 100.0 / totalnominal));

      if (waktu.month == DateTime.now().month) {
        pieChartData.add(PieChartData(data[i]['tipe'], data[i]['nominal'] / 2,
            data[i]['nominal'] / 2 * 100.0 / totalnominal));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      palette: [
        Colors.blue,
        Colors.green,
        Colors.red,
        Colors.yellow,
        Colors.orange,
        Colors.purple
      ],
      legend: Legend(
        isVisible: true,
        // overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.left,
        textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      series: <PieSeries<PieChartData, String>>[
        PieSeries<PieChartData, String>(
            legendIconType: LegendIconType.circle,
            explode: true,
            dataSource: pieChartData,
            xValueMapper: (PieChartData data, _) =>
                data.xData + '\n' + currencyFormatter.format(data.yData),
            yValueMapper: (PieChartData data, _) => data.yData,
            dataLabelSettings: DataLabelSettings(
                isVisible: true,
                color: Colors.white,
                labelPosition: ChartDataLabelPosition.inside),
            dataLabelMapper: (PieChartData data, _) =>
                // currencyFormatter.format(data.yData),
                data.percent.toStringAsFixed(2) + '%')
      ],
    );
  }
}
