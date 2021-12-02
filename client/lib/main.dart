import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Türschloss Steuerung'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _locked = false;

  Future<http.Response> changeDoorStateASNYC() async {

    setState(() {
      _locked = !_locked;
    });

    final url = "http://10.0.2.2:63444/api/Lock/lockDoor";
    try {
      print("test");

      return await http.post(Uri.parse(url),
          body: jsonEncode(<String, bool>{
            "open": _locked,
          })).timeout(Duration(seconds: 5));
    } on TimeoutException {
      print("timeout");
    }
    catch (ex){
      print(ex);
      print("catch");

    }
    finally {
      print("finally");
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 70,
            ),
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 200, height: 200),
              child: ElevatedButton(
                  onPressed: changeDoorStateASNYC,
                  child: Text(_locked ? "Tür öffnen" : "Tür sperren"),
                  style: ElevatedButton.styleFrom(shape: CircleBorder())),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              _locked ? "Die Tür ist gesperrt" : "Die Tür ist geöffnet",
              style: TextStyle(
                color: _locked ? Colors.green : Colors.deepOrange,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
