import 'package:shared_preferences/shared_preferences.dart';

Future<String> getIp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final ip = prefs.getString("ip") ?? null;
  return ip;
}

saveIp(String ip) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("ip", ip);
}

Future<String> getPort() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final port = prefs.getString("port") ?? null;
  return port;
}

savePort(String port) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("port", port);
}

deleteData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("ip");
  prefs.remove("port");
}

Future<bool> keysExist() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool toReturn = prefs.containsKey("ip") && prefs.containsKey("port");
  return toReturn;
}