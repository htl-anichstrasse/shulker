import 'package:doorlock_app/services/CustomException.dart';
import 'package:doorlock_app/services/ServerWrapper.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      appBar: AppBar(),
      body: Container(
        child: Form(
          key: authFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "PIN eingeben um fortzufahren",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "PIN Code",
                      ),
                      validator: (value) {
                        if (value.length < 6) {
                          return "Der Pin muss mindestens 6 Zeichen lang sein";
                        }
                        if (value.length > 10) {
                          return "Der Pin darf maximal 10 Zeichen betragen";
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

                        ServerWrapper.getInstance()
                            .getSession(_pin)
                            .then((value) {
                          if (value == "Error on fetching") {
                            displaySnackBar(context, Colors.red,
                                "Server kommunikations Fehler.");
                            return;
                          }

                          if (value != null) {
                            ServerWrapper.getInstance().setToken(value);

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
                      child: Text("Bestätigen"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
