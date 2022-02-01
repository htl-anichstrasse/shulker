import 'package:doorlock_app/screens/ConnectDeviceScreen.dart';
import 'package:doorlock_app/screens/ConnectVPN.dart';
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
  bool _lockPaired;
  bool _vpnConnected;

  int selectedSidenavIndex = 0;

  final List<String> titles = ["Shulker", "Pinverwaltung", "Einstellungen"];
  String title = "Shulker";

  changeLockStatus() {
    setState(() {
      _locked = !_locked;
    });

    changeDoorStateAsync(!_locked);
  }

  loadIpPort() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool toReturn = ((prefs.containsKey("ip") && prefs.containsKey("port")));

    setState(() {
      _lockPaired = !toReturn;
    });
  }

  checkVPNConnection() async {
    if (await CheckVpnConnection.isVpnActive()) {
      _vpnConnected = true;
    } else {
      _vpnConnected = false;
    }

  }

  @override
  void initState() {
    super.initState();
    checkVPNConnection();
    loadIpPort();
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(
      builder: (context) {
        if (_vpnConnected == null) {
          return SizedBox.shrink();
        }
        if (!_vpnConnected) {
          return ConnectVPN();
        }
        if (_lockPaired == null){
          return SizedBox.shrink();
        }
        if (_lockPaired) {
          return ConnectWizard();
        }

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
                                  shape: CircleBorder())),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          _locked
                              ? "Die Tür ist gesperrt"
                              : "Die Tür ist geöffnet",
                          style: TextStyle(
                            color: _locked ? Colors.green : Colors.deepOrange,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
