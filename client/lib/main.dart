import 'package:doorlock_app/screens/ConnectScreen.dart';
import 'package:doorlock_app/screens/HomeScreen.dart';
import 'package:doorlock_app/views/PinManager.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shulker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        "/pairDevice": (context) => ConnectScreen(),
      },
    );
  }
}
