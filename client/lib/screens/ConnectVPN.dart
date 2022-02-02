import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:doorlock_app/util/SnackBarHelper.dart';

class ConnectVPN extends StatefulWidget {
  @override
  _ConnectVPNState createState() => _ConnectVPNState();
}


class _ConnectVPNState extends State<ConnectVPN> {


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "VPN Verbindung erforderlich",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Bitte verbinden Sie sich in den Einstellungen mit einem VPN in Ihr Heimnetzwerk",
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(onPressed: () {
                  OpenSettings.openVPNSetting();
                }, child: Text("Einstellungen öffnen"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
