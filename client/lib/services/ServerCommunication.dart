import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

Future<http.Response> changeDoorStateAsync(bool locked) async {
  final url = "http://10.0.2.2:63444/api/Lock/lockDoor";
  try {
    print("test");

    return await http
        .post(Uri.parse(url),
        body: jsonEncode(<String, bool>{
          "open": locked,
        }))
        .timeout(Duration(seconds: 5));
  } on TimeoutException {
    print("timeout");
  } catch (ex) {
    print(ex);
    print("catch");
  } finally {
    print("finally");
  }
}
