import 'dart:async';

import 'package:doorlock_app/screens/ConnectDeviceScreen.dart';
import 'package:doorlock_app/views/CreatePin.dart';
import 'package:doorlock_app/views/PinManager.dart';
import 'package:doorlock_app/views/Settings.dart';
import 'package:doorlock_app/widgets/Sidenav.dart';
import 'package:flutter/material.dart';
import 'package:check_vpn_connection/check_vpn_connection.dart';

import 'package:doorlock_app/services/ServerCommunication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _locked = false;

  bool buttonEnabled = true;

  int selectedSidenavIndex = 0;

  final List<String> titles = ["Shulker", "Pinverwaltung", "Einstellungen"];
  String title = "Shulker";

  changeLockStatus() {
    // if button is disabled -> do nothing
    if (!buttonEnabled) {
      return;
    }
    // disable button, updateLockStatus will re-enable
    setState(() {
      buttonEnabled = false;
    });

    // updates the lock status on the server, then run updateLockStatus
    print("sending new lock status to server");
    ServerManager.getInstance()
        .changeLockStatus(!_locked)
        .then((value) => value == "ok" ? updateLockStatus() : null);
    //changeDoorStateAsync(!_locked);
  }

  updateLockStatus() async {
    print("updating local lock status");
    bool serverLockStatus =
        await ServerManager.getInstance().isLockLocked();
    setState(() {
      buttonEnabled = true;
      _locked = serverLockStatus;
    });
  }

  @override
  void initState() {
    //if (timer == null) {
    //  timer = Timer.periodic(Duration(milliseconds: 2000), (Timer t) => updateLockStatus());
    //}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(
      builder: (context) {
        return Scaffold(
            appBar: AppBar(
              title: Text("$title"),
            ),
            drawer: Sidenav((int index) {
              setState(() {
                selectedSidenavIndex = index;
                title = titles[index];
              });
            }, selectedSidenavIndex),
            floatingActionButton: Builder(builder: (context) {
              if (selectedSidenavIndex == 1) {
                return FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreatePin()));
                  },
                );
              }
              return Container();
            }),
            body: Builder(
              builder: (context) {
                if (selectedSidenavIndex == 0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 70,
                        ),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints.tightFor(width: 200, height: 200),
                          child: ElevatedButton(
                              onPressed: changeLockStatus,
                              child:
                                  Text(_locked ? "Tür öffnen" : "Tür sperren"),
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  primary: buttonEnabled
                                      ? Colors.blueAccent
                                      : Colors.grey)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _locked
                                  ? "Die Tür ist gesperrt"
                                  : "Die Tür ist geöffnet",
                              style: TextStyle(
                                color: _locked ? Colors.green : Colors.deepOrange,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Builder(builder: (context) => !buttonEnabled ? Container(height: 20.0, width: 20.0, child: CircularProgressIndicator()) : SizedBox.shrink()),
                          ],
                        )
                      ],
                    ),
                  );
                }
                if (selectedSidenavIndex == 1) {
                  Scaffold.of(context).build(context);
                  return PinManager();
                }
                if (selectedSidenavIndex == 2) {
                  return SettingsView();
                }

                return Text("Invalid Sidenav selected index");
              },
            ));
      },
    );
  }
}