import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sidenav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Shulker",
            style: TextStyle(
              fontSize: 21,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Divider(
          color: Colors.grey.shade400,
        ),
        ListTile(
          leading: Icon(Icons.lock),
          title: Text(
            "Schloss",
            style: TextStyle(fontSize: 15),
          ),
          onTap: () {},
        ),
        Divider(
          color: Colors.grey.shade400,
        ),
        ListTile(
          leading: Icon(Icons.insert_link),
          title: Text(
            "Verwaltung",
            style: TextStyle(fontSize: 15),
          ),
          onTap: () {},
        ),
      ]),
    );
  }
}
