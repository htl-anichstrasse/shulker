import 'dart:async';

import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:doorlock_app/screens/AuthScreen.dart';
import 'package:doorlock_app/screens/ConnectDeviceScreen.dart';
import 'package:doorlock_app/screens/HomeScreen.dart';
import 'package:doorlock_app/services/ServerCommunication.dart';
import 'package:flutter/material.dart';
import 'package:doorlock_app/screens/ConnectVPN.dart';
import 'package:doorlock_app/util/SharedPrefsHelper.dart';

class CheckConnectionScreen extends StatefulWidget {
  @override
  _CheckConnectionScreenState createState() => _CheckConnectionScreenState();
}

class _CheckConnectionScreenState extends State<CheckConnectionScreen> {
  bool _ipPortExists;
  bool _connectionWorks;
  bool _vpnConnected;

  var timer;

  checkServerConnection() async {
    bool ipPortExists = await ipPortExist();
    if (!ipPortExists) {
      return;
    }

    bool connectionWorking = await ServerManager.getInstance()
        .checkConnection(await getIp(), await getPort());
    setState(() {
      _connectionWorks = connectionWorking;
    });
  }

  checkVPNConnection() async {
    print("check vpn connection method");
    print(_connectionWorks);
    if (_connectionWorks) timer.cancel();

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

  checkIpPortSaved() async {
    print("check ip port saved method");

    bool keysExist = await ipPortExist();
    setState(() {
      _ipPortExists = keysExist;
      print(_ipPortExists);
    });
  }

  doesSessionExist() {
    if (ServerManager.getInstance().sessionToken == null) {
      return false;
    }
    return true;
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
      timer = Timer.periodic(
          Duration(milliseconds: 300), (Timer t) => checkVPNConnection());
    }

    if (_connectionWorks == null) {
      checkServerConnection();
    }
    if (timer == null) {
      timer = Timer.periodic(
          Duration(milliseconds: 300), (Timer t) => checkVPNConnection());
    }
    if (_ipPortExists == null) {
      checkIpPortSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(builder: (context) {
      print(_vpnConnected);
      // if the connection already works -> no vpn connection is required
      // and the ip and port are also saved already
      if (_connectionWorks == null) return LoadingScreen();
      if (_connectionWorks) {
        if (!doesSessionExist()) return AuthScreen();

        return HomeScreen();
      }

      if (_vpnConnected == null) {
        return LoadingScreen();
      }
      if (!_vpnConnected) {
        return ConnectVPN();
      }

      if (_ipPortExists == null) {
        return LoadingScreen();
      }
      if (!_ipPortExists) {
        return ConnectDeviceWizard();
      }

      if (!doesSessionExist()) {
        return AuthScreen();
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
                Text(
                  "Überprüfe Verbindung...",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
