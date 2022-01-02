import 'package:doorlock_app/models/Credential.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class CreatePin extends StatefulWidget {
  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  final formKey = GlobalKey<FormState>();
  bool unlimitedUses = true;
  String _name;
  String _uses;
  String _pin1;
  String _pin2;
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pin hinzufügen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Form(
              //autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "Wie soll der Pin gennant werden?",
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 15,
                      validator: (value) {
                        if (value.length < 1) {
                          return "Der Name muss mind. 1 Buchstaben haben";
                        }
                        if (value.length > 15) {
                          return "Der Name darf max. 15 Buchstaben haben";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _name = value;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: borderOutlineDecoration(),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text("Verwendungen:"),
                        SizedBox(
                          child: CheckboxListTile(
                            title: Text("∞ Verwendungen"),
                            checkColor: Colors.white,
                            value: unlimitedUses,
                            onChanged: (bool value) {
                              setState(() {
                                unlimitedUses = value;
                              });
                            },
                          ),
                        ),
                        TextFormField(
                          enabled: !unlimitedUses,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Verbleibende Verwendungen',
                            hintText: 'Wie oft darf der Pin verwendet werden?',
                          ),
                          validator: (value) {
                            if (unlimitedUses) {
                              _uses = "-1";
                              return null;
                            }
                            if (value.length <= 0) {
                              return "Bitte geben Sie einen Wert ein";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _uses = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: borderOutlineDecoration(),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text("Code:"),
                        SizedBox(
                          child: TextFormField(
                            maxLength: 16,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value.length < 6) {
                                return "Der Pin muss mindestens 6 Zeichen lang sein";
                              }
                              if (value.length > 10) {
                                return "Der Pin darf maximal 10 Zeichen betragen";
                              }
                              print(_pin2);
                              if (_pin2 != null && _pin2 != "") {
                                if (_pin1 != _pin2) {
                                  return "Die Pins stimmen nicht überein";
                                }
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "PIN Code",
                              hintText: "Bitte geben Sie einen Pin ein",
                            ),
                            onChanged: (value) {
                              _pin1 = value;
                            },
                          ),
                        ),
                        SizedBox(
                          child: TextFormField(
                            maxLength: 16,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value.length < 6) {
                                return "Der Pin muss mindestens 6 Zeichen lang sein";
                              }
                              if (value.length > 10) {
                                return "Der Pin darf maximal 10 Zeichen betragen";
                              }
                              if (_pin1 != null) {
                                if (_pin1 != _pin2) {
                                  return "Die Pins stimmen nicht überein";
                                }
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "PIN Code wiederholen",
                              hintText: "Bitte wiederholen Sie ihren Pin",
                            ),
                            onChanged: (value) {
                              _pin2 = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      child: ElevatedButton(
                          onPressed: () {
                            final isValid = formKey.currentState.validate();
                            if (isValid) {
                              Credential.creds.add(new Credential(
                                  uuid.v4(),
                                  DateTime.now(),
                                  DateTime.utc(9999),
                                  int.tryParse(_uses),
                                  _pin1,
                                  _name));
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Erstellen")))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration borderOutlineDecoration() {
  return BoxDecoration(
    border: Border.all(
      width: 1.0,
      color: Colors.grey,
    ),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  );
}

class PinInput extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Function onInputChanged;

  var controller = TextEditingController();

  PinInput(this.labelText, this.hintText, this.onInputChanged);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        controller: controller,
        maxLength: 16,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value.length < 6) {
            return "Der Pin muss mindestens 6 Zeichen lang sein";
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
        onChanged: onInputChanged,
      ),
    );
  }
}

/*
class DateTimeDisplayAndPicker extends StatefulWidget {
  DateTime date;

  @override
  State<DateTimeDisplayAndPicker> createState() =>
      _DateTimeDisplayAndPickerState();
}

class _DateTimeDisplayAndPickerState extends State<DateTimeDisplayAndPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Anfangs Datum: "),
        Text(widget.date.toString()),
        SizedBox(
          width: 10,
        ),
        ElevatedButton(
            onPressed: () {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime(9999, 1, 1))
                  .then((value) {
                    setState(() {
                      widget.date = value;
                    });
              });
            },
            child: Text("bearbeiten"))
      ],
    );
  }
}
*/
