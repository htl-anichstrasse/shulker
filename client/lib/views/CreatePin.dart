import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatePin extends StatefulWidget {
  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  bool validForever = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pin hinzufügen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Name",
                hintText: "Wie soll der Pin gennant werden?"
              ),
            ),
            SizedBox(
              height: 15,
            ),

            Text("Gültigkeitsdauer:"),

            Row(
              children: [
                SizedBox(
                  width: 300,
                  height: 30,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Verbleibende Verwendungen',
                      hintText: 'Wie oft darf der Pin verwendet werden?',
                    ),
                  ),
                ),
                Checkbox(
                  checkColor: Colors.white,
                  value: validForever,
                  onChanged: (bool value) {
                    setState(() {
                      validForever = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
class DateTimeDisplayAndPicker extends StatefulWidget {
  DateTime date;

  @override
  State<DateTimeDisplayAndPicker> createState() =>
      _DateTimeDisplayAndPickerState();
}

class _DateTimeDisplayAndPickerState extends State<DateTimeDisplayAndPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Anfangs Datum: "),
        Text(widget.date.toString()),
        SizedBox(
          width: 10,
        ),
        ElevatedButton(
            onPressed: () {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime(9999, 1, 1))
                  .then((value) {
                    setState(() {
                      widget.date = value;
                    });
              });
            },
            child: Text("bearbeiten"))
      ],
    );
  }
}
*/
