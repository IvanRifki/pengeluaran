// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class LineChartPengeluaranPerBulan extends StatefulWidget {
//   const LineChartPengeluaranPerBulan({super.key});

//   @override
//   State<LineChartPengeluaranPerBulan> createState() =>
//       _LineChartPengeluaranPerBulanState();
// }

// final db = DatabaseHelper.instance;

// // NumberFormat currencyFormatter = NumberFormat.currency(
// //   locale: 'id_ID',
// //   symbol: 'Rp ',
// //   decimalDigits: 0,
// //   name: 'IDR',
// // );

// // class PieChartData {
// //   final String xData;
// //   final num yData;
// //   final num percent;
// //   PieChartData(this.xData, this.yData, this.percent);
// // }

// class LineChartData {
//   LineChartData(this.total, this.waktu);
//   final String waktu;
//   final int total;
// }

// NumberFormat currencyFormatter = NumberFormat.currency(
//   locale: 'id_ID',
//   symbol: 'Rp ',
//   decimalDigits: 0,
//   name: 'IDR',
// );

// List<LineChartData> _chartdata = [];
// // final List<PieChartData> pieChartData = [];

// class _LineChartPengeluaranPerBulanState
//     extends State<LineChartPengeluaranPerBulan> {
//   @override
//   void initState() {
//     setState(() {
//       getChartData();
//     });
//     super.initState();
//   }

//   Future<void> getChartData() async {
//     final bulanini = DateFormat('MMMM').format(DateTime.now());
//     final data = await db.queryLineChartPengeluaran(bulanini);
//     _chartdata.clear();

//     if (data.isNotEmpty) {
//       String Bulannya = DateFormat('dd-MMMM')
//           .format(DateFormat('EEEE dd MMMM yyyy').parse(data[0]['waktu']));

//       print('ini data ${Bulannya.runtimeType}');

//       _chartdata = data
//           .map((data) => LineChartData(
//               data['TotalPengeluaran'],
//               DateFormat('dd-MMMM').format(
//                   DateFormat('EEEE dd MMMM yyyy').parse(data['waktu']))))
//           .toList();
//       setState(() {
//         _chartdata = _chartdata;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SfCartesianChart(
//       // title: ChartTitle(
//       //     text: 'Pengeluaran Per Bulan',
//       //     textStyle: TextStyle(color: Colors.white)),
//       legend: Legend(
//         isVisible: true,
//         textStyle: TextStyle(color: Colors.white),
//         position: LegendPosition.bottom,
//       ),
//       // backgroundColor: Colors.white,
//       tooltipBehavior: TooltipBehavior(
//         shadowColor: Colors.black,
//         enable: true,
//         canShowMarker: true,
//         activationMode: ActivationMode.singleTap,
//       ),
//       zoomPanBehavior: ZoomPanBehavior(
//           enablePanning: true,
//           enablePinching: true,
//           enableDoubleTapZooming: true),
//       primaryYAxis: NumericAxis(
//         labelStyle: TextStyle(color: Colors.white),
//         // title: AxisTitle(text: 'Pengeluaran'),
//       ),
//       primaryXAxis: CategoryAxis(
//         labelStyle: TextStyle(color: Colors.white),
//         // title: AxisTitle(text: 'Bulan'),
//       ),
//       series: <CartesianSeries<LineChartData, String>>[
//         LineSeries<LineChartData, String>(
//           color: Color(0xFFFFC107),
//           name: 'Banyaknya Pengeluaran',
//           enableTooltip: true,
//           dataSource: _chartdata,
//           xValueMapper: (LineChartData data, _) => data.waktu,
//           yValueMapper: (LineChartData data, _) => data.total,
//           dataLabelSettings: DataLabelSettings(
//             isVisible: true,
//             labelPosition: ChartDataLabelPosition.inside,
//             color: Colors.amber,
//             textStyle: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           dataLabelMapper: (datum, index) {
//             return currencyFormatter.format(datum.total);
//           },
//           // dataLabelMapper: (LineChartData data, _) {
//           //   return currencyFormatter.format(data.total);
//           // },
//           markerSettings: MarkerSettings(isVisible: true, color: Colors.red),
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pengeluaran/databasehelper/dbhelper_pengeluaran.dart';
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
                data['TotalPengeluaran'],
                DateFormat('dd-MMMM').format(
                    DateFormat('EEEE dd MMMM yyyy').parse(data['waktu']))))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      legend: Legend(
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
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: Colors.white),
      ),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries<LineChartData, String>>[
        LineSeries<LineChartData, String>(
          color: Color(0xFFFFC107),
          name: 'Banyaknya Pengeluaran',
          enableTooltip: true,
          dataSource: _chartdata,
          xValueMapper: (LineChartData data, _) => data.waktu,
          yValueMapper: (LineChartData data, _) => data.total,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            color: Colors.amber,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          dataLabelMapper: (datum, index) {
            return currencyFormatter.format(datum.total);
          },
          markerSettings: MarkerSettings(isVisible: true, color: Colors.red),
        ),
      ],
    );
  }
}
