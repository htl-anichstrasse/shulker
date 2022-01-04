import 'package:doorlock_app/util/RegexHelper.dart';
import 'package:flutter/material.dart';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final networkFormKey = GlobalKey<FormState>();
  int screenId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Türschloss verbinden"),
      ),
      body: Builder(
        builder: (context) {
          if (screenId == 0) {
            return Container(
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                            onPressed: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "Türschloss mit QR-Code verbinden",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                Text("empfohlen",
                                  style: TextStyle(
                                      color: Colors.white60
                                  ),)
                              ],
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                screenId = 1;
                              });
                            },
                            child: Text(
                              "Türschloss manuell verbinden",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Padding(
              padding: EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: networkFormKey,
                    child: Column(
                      children: [
                        Text("Netzwerk"),
                        TextFormField(
                          validator: (value) {
                            if (!RegexHelper.isIpV4(value)) {
                              return "Bitte geben Sie eine gültige IPv4 Adresse ein";
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: "IP-Adresse"),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Port"),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Erfolgreich gespeichert"),
                                    ],
                                  )));
                            },
                            child: Text("Speichern"))
                      ],
                    ),
                  )
                ],
              ));
        }
      ),
    );
  }
}
