import 'package:doorlock_app/util/RegexHelper.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';
import 'package:doorlock_app/util/StorageHelper.dart';
import 'package:doorlock_app/views/QrScan.dart';
import 'package:flutter/material.dart';

class ConnectWizard extends StatefulWidget {
  @override
  _ConnectWizardState createState() => _ConnectWizardState();
}

class _ConnectWizardState extends State<ConnectWizard> {
  final networkFormKey = GlobalKey<FormState>();
  int screenId = 0;
  String _ip;
  String _port;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Türschloss verbinden"),
      ),
      body: Builder(builder: (context) {
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
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QRScanPage(onScanned)));
                          },
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
                              Text(
                                "empfohlen",
                                style: TextStyle(color: Colors.white60),
                              )
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
                        initialValue: _ip,
                        validator: (value) {
                          if (!RegexHelper.isIpV4(value)) {
                            return "Die eingegebene IP-Adresse ist ungültig";
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: "IP-Adresse"),
                        onChanged: (val) {
                          setState(() {
                            _ip = val;
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: _port,
                        decoration: InputDecoration(labelText: "Port"),
                        validator: (value) {
                          if (value.length < 2 || int.tryParse(value) > 65535) {
                            return "Der eingegebene Port ist ungültig";
                          }

                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _port = val;
                          });
                        },
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (!networkFormKey.currentState.validate()) {
                              return;
                            }
                            saveIp(_ip);
                            savePort(_port);
                            var x = getPort();

                            Navigator.pushNamed(context, "/userAuth");
                          },
                          child: Text("Verbinden")),
                      ElevatedButton(
                          onPressed: () {
                            deleteData();
                          },
                          child: Text("Lokale Daten löschen"))
                    ],
                  ),
                )
              ],
            ));
      }),
    );

  }
  void onScanned(barcode) {
    // validate the qr code format
    if (!barcode.contains(";")){
      displaySnackBar(context, Colors.red, "Ungültiger QR-Code");
      return;
    }

    setState(() {
      screenId = 1;
      _ip = barcode.split(";")[0].trim();
      _port = barcode.split(";")[1].trim();
      displaySnackBar(context, Colors.green, "QR-Code erfolgreich gescannt");
    });

  }
}
