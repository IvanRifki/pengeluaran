import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pengeluaran/main.dart';
import 'package:pengeluaran/mainmenu.dart';
import 'dart:async';

import 'package:pengeluaran/pages/dashboard/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

void Main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SplashScreen());
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const Dashboard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pengeluaranicon.png',
              width: 200,
              height: 200,
            ),
            Text(
              'CATAT PENGELUARAN BULANAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
            ),
            Text('V1.0', style: TextStyle(fontSize: 10, color: Colors.white)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
