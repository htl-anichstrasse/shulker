import 'package:doorlock_app/models/Credential.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                  leading: const Text("****"),
                  title: const Text("test"),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text("Bearbeiten"),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: Text("Löschen"),
                        value: 1,
                      )
                    ],
                    onSelected: (index) {
                      print(index);
                      if (index == 0) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return EditPin();
                            }));
                      }
                    },
                  ),
                  onTap: () {});
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
