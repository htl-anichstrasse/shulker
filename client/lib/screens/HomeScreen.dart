import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    catch (ex) {
      print(ex);
      print("catch");
    }
    finally {
      print("finally");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(
      builder: (context) =>
          Scaffold(
            appBar: AppBar(
              title: Text("Home screen"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 70,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: 200, height: 200),
                    child: ElevatedButton(
                        onPressed: changeDoorStateASNYC,
                        child: Text(_locked ? "Tür öffnen" : "Tür sperren"),
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder())),
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
          ),
    );
  }
}
