import 'dart:async';

import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:doorlock_app/screens/ConnectDeviceScreen.dart';
import 'package:doorlock_app/screens/HomeScreen.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doorlock_app/screens/ConnectVPN.dart';
import 'package:doorlock_app/util/SharedPrefsHelper.dart';

class CheckConnectionScreen extends StatefulWidget {
  @override
  _CheckConnectionScreenState createState() => _CheckConnectionScreenState();
}


class _CheckConnectionScreenState extends State<CheckConnectionScreen> {
  bool _ipPortExists;
  bool _vpnConnected;

  var timer;

  checkVPNConnectionLoop() async {
    if (await CheckVpnConnection.isVpnActive()) {
      timer.cancel();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      displaySnackBar(context, Colors.green, "VPN Verbindung erfolgreich");
    }
  }

  checkIpPortSaved() async {
    print("check ip port saved method");

    bool keysExist = await ipPortExist();
    print(await getIp());
    print(await getPort());
    setState(() {
      _ipPortExists = keysExist;
      print(_ipPortExists);
    });
  }

  checkVPNConnection() async {
    print("check vpn connection method");
    if (await CheckVpnConnection.isVpnActive()) {
      setState(() {
        timer.cancel();
        //displaySnackBar(context, Colors.green, "VPN verbunden!");
        _vpnConnected = true;
      });
    } else {
      setState(() {
        _vpnConnected = false;
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (timer == null) {
      timer = Timer.periodic(Duration(milliseconds: 300), (Timer t) => checkVPNConnection());
    }

    if (_vpnConnected == null) {
      checkVPNConnection();
    }
    if (_ipPortExists == null) {
      checkIpPortSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD of CHECK CONNECTION SCREEN");
    return new Builder(builder: (context) {
      print("_vpnConnected:");
      print(_vpnConnected);
      if (_vpnConnected == null) {
        return LoadingScreen();
      }
      if (!_vpnConnected) {
        return ConnectVPN();
      }
      print("_ipPortExists:");
      print(_ipPortExists);
      if (_ipPortExists == null){
        return LoadingScreen();
      }
      if (!_ipPortExists) {
        return ConnectDeviceWizard();
      }

      return HomeScreen();
    });
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Überprüfe Verbindung...",
                  style: TextStyle(
                    fontSize: 14,
                  ),),
                  SizedBox(
                    height: 10,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}
