import 'package:doorlock_app/screens/ConnectScreen.dart';
import 'package:doorlock_app/screens/HomeScreen.dart';
import 'package:doorlock_app/util/Themes.dart';
import 'package:doorlock_app/views/PinManager.dart';
import 'package:doorlock_app/views/QrScan.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shulker',
      theme: myTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        "/pairDevice": (context) => ConnectWizard(),
      },
    );
  }
}
