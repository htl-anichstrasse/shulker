import 'package:doorlock_app/services/ServerCommunication.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _pin;
  final authFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentifikation erforderlich"),
        centerTitle: true,
      ),
      body: Container(
        child: Form(
          key: authFormKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
            child: Center(
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        "Master-Passwort eingeben um fortzufahren",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          maxLength: 16,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: "Master-Passwort",
                          ),
                          validator: (value) {
                            if (value.length < 6) {
                              return "Minimum 6 Zeichen";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _pin = value;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (!authFormKey.currentState.validate()) {
                              return;
                            }

                            ServerManager.getInstance()
                                .requestAndSaveSession(_pin)
                                .then((value) {
                              if (value == "error") {
                                displaySnackBar(context, Colors.red,
                                    "Fehler bei der Kommunikation mit dem T??rschloss");
                                return;
                              }
                              if (value == "invalid"){
                                displaySnackBar(context, Colors.red,
                                    "Falscher Pin");
                                return;
                              }

                              if (value != null) {
                                displaySnackBar(
                                    context, Colors.green, "Erfolgreich verbunden");
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/", (route) => false);
                              } else {
                                displaySnackBar(
                                    context, Colors.redAccent, "Falscher Pin");
                              }
                            });
                          },
                          child: Text("Best??tigen"))
                    ],
                  ),
                  Expanded(child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, "/pairDevice");
                      },
                      child: Text("T??rschloss neu verbinden"),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
