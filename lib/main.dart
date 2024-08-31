import 'package:flutter/material.dart';
import 'package:pengeluaran/pages/daftarpengeluaran/daftarpengeluaran.dart';
import 'package:pengeluaran/pages/dashboard/dashboard.dart';
// import 'package:pengeluaran/charts/LineChartPengeluaranPerBulan.dart';
// import 'package:pengeluaran/charts/lineChartPengeluaran.dart';
// import 'package:pengeluaran/charts/pieChartTipePengeluaran.dart';
// import 'package:pengeluaran/pages/daftarpengeluaran/daftarpengeluaran.dart';
// import 'package:pengeluaran/pages/dashboard/dashboard.dart';
import 'package:pengeluaran/pages/splashscreen/splashscreen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:pengeluaran/static/static.dart';
import 'dart:io';

void main() {
  if (isDesktop()) {}
  sqfliteFfiInit();
  runApp(const MyApp());
}

bool isDesktop() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[900]),
      home: const SplashScreen(),
      // home: const Daftarpengeluaran(),
      // home: const Dashboard(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   // int _counter = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       // body: Center(
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     children: <Widget>[
//       //       const Text(
//       //         'You have pushed the button this many times:',
//       //       ),
//       //       Text(
//       //         '$_counter',
//       //         style: Theme.of(context).textTheme.headlineMedium,
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
// }
