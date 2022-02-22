import 'package:doorlock_app/screens/AuthScreen.dart';
import 'package:doorlock_app/screens/CheckConnectionScreen.dart';
import 'package:doorlock_app/screens/ConnectDeviceScreen.dart';
import 'package:doorlock_app/screens/ConnectVPN.dart';
import 'package:doorlock_app/screens/HomeScreen.dart';
import 'package:doorlock_app/util/Themes.dart';
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
        '/': (context) => CheckConnectionScreen(),
        '/home': (context) => HomeScreen(),
        "/pairDevice": (context) => ConnectDeviceWizard(),
        "/userAuth": (context) => AuthScreen(),
        "/connectVPN": (context) => ConnectVPN(),
        "/connectDevice": (context) => ConnectDeviceWizard(),
      },
    );
  }
}
