import 'package:doorlock_app/models/Credential.dart';
import 'package:doorlock_app/services/ServerCommunication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';

class PinManager extends StatefulWidget {
  @override
  _PinManagerState createState() => _PinManagerState();
}

class _PinManagerState extends State<PinManager> {
  getCredentials() async {
    List<Credential> temp = await ServerManager.getInstance().getCredentials();
    setState(() {
      credentials = temp;
      loading = false;
    });
  }

  List<Credential> credentials = [];
  bool loading;

  @override
  void initState() {
    getCredentials();
    loading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading == null || loading) {
      return new Builder(builder: (context) {
        return Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            )
        );
      });
    }


    return new Builder(builder: (context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Center(
          child: ListView.builder(
              itemCount: credentials.length,
              itemBuilder: (context, index) {
                return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ExpansionTile(
                        childrenPadding: EdgeInsets.all(15).copyWith(top: 0),
                        leading: const Icon(Icons.password),
                        title: Text(credentials[index].label),
                        children: [
                          TextField(
                            controller: TextEditingController()
                              ..text = credentials[index].usesLeft.toString(),
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
                                  credentials[index].startDateTime.toString()),
                              Text("Gültig bis: " +
                                  credentials[index].endDateTime.toString()),
                            ],
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                  width: 30, height: 30),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Icon(Icons.delete),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                ),
                              ),
                            ),
                          ),
                        ]));
              }),
        ),
      );
    });
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
