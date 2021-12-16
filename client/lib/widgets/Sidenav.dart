import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// https://www.youtube.com/watch?v=n2wtljWWnpU

class Sidenav extends StatelessWidget {

  final Function onIndexChanged;
  Sidenav(this.onIndexChanged);

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
          leading: Icon(Icons.lock, color: Colors.black,),
          title: Text(
            "Schloss",
            style: TextStyle(fontSize: 15),
          ),
          onTap: () {
            onIndexChanged(0);
          },
        ),
        Divider(
          color: Colors.grey.shade400,
        ),
        ListTile(
          leading: Icon(Icons.insert_link, color: Colors.black,),
          title: Text(
            "Verwaltung",
            style: TextStyle(fontSize: 15),
          ),
          onTap: () {
            onIndexChanged(1);
          },
        ),
      ]),
    );
  }
}
