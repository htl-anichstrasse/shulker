import 'package:doorlock_app/models/Credential.dart';
import 'package:doorlock_app/services/ServerCommunication.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CreatePin extends StatefulWidget {
  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  final formKey = GlobalKey<FormState>();
  bool unlimitedUses = true;

  DateTime fromDate = DateTime.now();
  TimeOfDay fromTime = TimeOfDay(hour: 0, minute: 0);
  DateTime untilDate = DateTime.now();
  TimeOfDay untilTime = TimeOfDay(hour: 23, minute: 59);
  bool untilForever = true;

  String _name;
  String _uses;
  String _pin1;
  String _pin2;
  var uuid = Uuid();

  void uploadCredential(Credential c) {

  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Pin hinzufügen"),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(primary: Colors.blueAccent[200]),
                onPressed: () {
                  final isValid = formKey.currentState.validate();
                  if (isValid) {
                    Navigator.pop(context);

                    DateTime fromDateTime = DateTime(
                        fromDate.year,
                        fromDate.month,
                        fromDate.day,
                        fromTime.hour,
                        fromTime.minute);
                    DateTime untilDateTime = untilForever
                        ? DateTime.utc(9999)
                        : DateTime(untilDate.year, untilDate.month,
                            untilDate.day, untilTime.hour, untilTime.minute);

                    Credential c = new Credential(uuid.v4(), fromDateTime,
                        untilDateTime, int.tryParse(_uses), _pin1, _name);

                    ServerManager.getInstance().uploadCredential(c);

                    displaySnackBar(
                        context, Colors.green, "PIN erfolgreich hinzugefügt");
                  }
                },
                child: Text("Erstellen")),
          )
        ],
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
                        Text("Verwendbar von bis:"),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("vom "),
                            GestureDetector(
                              child: Text(
                                DateFormat("dd.MM.yyyy").format(fromDate),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: fromDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  locale: const Locale("de", "DE"),
                                ).then((value) {
                                  setState(() {
                                    fromDate = value;
                                    if (value.isAfter(untilDate)) {
                                      untilDate = fromDate;
                                    }
                                  });
                                });
                              },
                            ),
                            Spacer(),
                            GestureDetector(
                              child: Text(
                                localizations.formatTimeOfDay(fromTime),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                showTimePicker(
                                        context: context, initialTime: fromTime)
                                    .then((value) {
                                  setState(() {
                                    fromTime = value;
                                    double toDouble(TimeOfDay myTime) =>
                                        myTime.hour + myTime.minute / 60.0;
                                    if (fromDate.isAtSameMomentAs(untilDate) &&
                                        toDouble(value) > toDouble(untilTime)) {
                                      untilTime = fromTime;
                                    }
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("bis "),
                            GestureDetector(
                              child: Text(
                                untilForever
                                    ? "für immer"
                                    : DateFormat("dd.MM.yyyy")
                                        .format(untilDate),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                if (untilForever) {
                                  return;
                                }
                                showDatePicker(
                                  context: context,
                                  initialDate: untilDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  locale: const Locale("de", "DE"),
                                ).then((value) {
                                  setState(() {
                                    untilDate = value;
                                    if (value.isBefore(fromDate)) {
                                      fromDate = value;
                                    }
                                  });
                                });
                              },
                            ),
                            Spacer(),
                            GestureDetector(
                              child: Text(
                                untilForever
                                    ? ""
                                    : localizations.formatTimeOfDay(untilTime),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                showTimePicker(
                                        context: context,
                                        initialTime: untilTime)
                                    .then((value) {
                                  setState(() {
                                    untilTime = value;
                                  });
                                });
                              },
                            ),
                            Spacer(),
                            Text("für immer"),
                            Checkbox(
                                value: untilForever,
                                onChanged: (value) {
                                  setState(() {
                                    untilForever = value;
                                  });
                                })
                          ],
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
                        Text("Schlüssel:"),
                        SizedBox(
                          child: TextFormField(
                            maxLength: 16,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            validator: (value) {
                              if (value.length < 6) {
                                return "Der Pin muss mindestens 6 Zeichen lang sein";
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
                            validator: (value) {
                              if (value.length < 6) {
                                return "Der Pin muss mindestens 6 Zeichen lang sein";
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
