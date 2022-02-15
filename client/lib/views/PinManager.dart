import 'package:doorlock_app/models/Credential.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';

class PinManager extends StatefulWidget {
  @override
  _PinManagerState createState() => _PinManagerState();
}

class _PinManagerState extends State<PinManager> {
  List<Credential> exampleCreds = Credential.getExampleCredentials();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Center(
        child: ListView.builder(
            itemCount: exampleCreds.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                    childrenPadding: EdgeInsets.all(15).copyWith(top: 0),
                    leading: const Icon(Icons.password),
                    title: Text(exampleCreds[index].label),
                    children: [
                      TextField(
                        controller: TextEditingController()
                          ..text = exampleCreds[index].usesLeft.toString(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Verbleibende Verwendungen',
                          hintText: '',
                          border: InputBorder.none,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Gültig ab: " +
                              exampleCreds[index].startDateTime.toString()),
                          Text("Gültig bis: " +
                              exampleCreds[index].endDateTime.toString()),
                        ],
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text("Pin Löschen"),
                                      content: Text(
                                          "Möchten Sie diesen Pin wirklich löschen?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              print(index);
                                            },
                                            child: Text("Ja")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Nein"))
                                      ],
                                    ),
                                barrierDismissible: true);
                          },
                          child: Icon(Icons.delete),
                          mini: true,
                        ),
                      ),
                    ]),
              );
            }),
      ),
    );
  }
}

class EditPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pin bearbeiten"),
      ),
      body: Text("edit pin"),
    );
  }
}
