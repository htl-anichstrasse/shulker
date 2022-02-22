import 'package:doorlock_app/util/Themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// https://www.youtube.com/watch?v=n2wtljWWnpU

class Sidenav extends StatelessWidget {
  final Function onIndexChanged;
  final int selectedIndex;

  Sidenav(this.onIndexChanged, this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
              _NavigationItem(
                selected: selectedIndex == 0,
                onPressed: () { onIndexChanged(0); },
                icon: Icons.lock,
                text: "Schloss",
              ),
              _NavigationItem(
                selected: selectedIndex ==1,
                onPressed: () { onIndexChanged(1); },
                icon: Icons.insert_link,
                text: "Pin verwaltung"
              ),
            ]),
          ),
          Container(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                child: Column(
                  children: [
                    Divider(
                      color: Colors.grey.shade400,
                    ),
                    _NavigationItem(
                      selected: selectedIndex == 2,
                      onPressed: () { onIndexChanged(2); },
                      icon: Icons.settings,
                      text: "Einstellungen",
                    ),
                  ],
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final bool selected;
  final Function onPressed;
  final String text;
  final IconData icon;

  _NavigationItem({
    this.selected,
    this.onPressed,
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? PrimaryMaterialColor.shade300 : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        title: Text(text, style: TextStyle(color: Colors.black),),
        selected: selected,
        onTap: () {
          Navigator.of(context).pop();
          onPressed();
        },
      ),
    );
  }
}
