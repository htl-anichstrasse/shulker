import 'dart:convert';

import 'package:doorlock_app/services/ServerCommunication.dart';

import 'CustomException.dart';

class ServerWrapper {
  ServerManager sm;

  static ServerWrapper _instance;
  static String token;

  ServerWrapper._() {
    sm = new ServerManager();
  }

  static ServerWrapper getInstance() {
    if (_instance == null) {
      _instance = new ServerWrapper._();
    }
    return _instance;
  }
  void setToken(String t) {
    token = t;
  }

  Future<bool> checkConnection(ip, port) async {
    String url = "http://" + ip + ":" + port + "/api/status";
    try {
      String res = await sm.sendRequest(url);
    } catch (ex) {
      print(ex);
      return false;
    }
    return true;
  }

  Future<String> getSession(pin) async {
    String url = await sm.getBaseUrl() + "/api/Session/getToken/" + pin;
    try {
      String session = await sm.sendRequest(url);
      return session;
    } catch (ex) {}
    throw FetchDataException("Error on fetching");
  }

  Future<String> setLockState(open) async {
    String url = await sm.getBaseUrl() + "/api/Lock/setLockState";

    url += "?closed=" + (open ? "true" : "false");
    try {
      await sm.sendPostRequest(url);
    } catch (ex) {

    }
  }
}
