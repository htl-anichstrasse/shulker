import 'package:shared_preferences/shared_preferences.dart';

Future<String> getIpPort() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final ip = prefs.getString("ip") ?? null;
  final port = prefs.getString("port") ?? null;

  if (ip != null && port != null) {
    return ip + ":" + port;
  }
  return null;
}

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

Future<bool> ipPortExist() async {
  bool keysExist = (await getIp()) != null && (await getPort()) != null;
  return keysExist;
}