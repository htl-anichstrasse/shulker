import 'package:doorlock_app/util/RegexHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final networkFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.phonelink_ring),
                    title: Text("Türschloss neu verbinden"),
                    trailing: SizedBox(
                        child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 15,
                    )),
                    onTap: () {
                      Navigator.pushNamed(context, "/pairDevice");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.vpn_lock),
                    title: Text("VPN neu verbinden"),
                    trailing: SizedBox(
                        child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 15,
                    )),
                    onTap: () {
                      Navigator.pushNamed(context, "/connectVPN");
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "Über die App",
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationVersion: "0.1",
                  );
                },
              ),
            )
          ],
        ));
  }
}
