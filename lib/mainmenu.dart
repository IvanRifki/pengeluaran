import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pengeluaran/charts/LineChartPengeluaranPerBulan.dart';
import 'package:pengeluaran/charts/lineChartPengeluaran.dart';
import 'package:pengeluaran/charts/pieChartTipePengeluaran.dart';
import 'package:pengeluaran/pages/daftarpengeluaran/daftarpengeluaran.dart';
import 'package:pengeluaran/pages/dashboard/dashboard.dart';
import 'package:pengeluaran/pages/splashscreen/splashscreen.dart';
import 'package:pengeluaran/static/static.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  runApp(const MainMenuScreen());
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[900]),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey[900],
            toolbarHeight: 0,
            bottom: TabBar(
              labelColor: Colors.amber,
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Dashboard'),
                Tab(icon: Icon(Icons.menu_book), text: 'Daftar Pengeluaran'),
              ],
            ),
          ),
          body: TabBarView(children: [
            Dashboard(),
            Daftarpengeluaran(),
          ]),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
