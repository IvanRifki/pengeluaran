import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pengeluaran/pages/dashboard/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SplashScreen());
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const Dashboard()),
      );
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
            const Text(
              'CATAT PENGELUARAN BULANAN',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
            ),
            const Text('V1.0',
                style: TextStyle(fontSize: 10, color: Colors.white)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
