import 'package:doorlock_app/models/Credential.dart';
import 'package:doorlock_app/util/SharedPrefsHelper.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:convert';

class ServerManager {
  Dio dio;

  // singleton
  static ServerManager _instance;

  ServerManager._() {
    var options = BaseOptions(
      connectTimeout: 1000,
      receiveTimeout: 1000,
    );
    dio = Dio(options);
  }

  static ServerManager getInstance() {
    if (_instance == null) {
      _instance = new ServerManager._();
    }
    return _instance;
  }

  var timeout = 500;
  String sessionToken;

  Future<String> getBaseUrl() async {
    return "http://" + await getIpPort();
  }

  Future<String> requestAndSaveSession(String secret) async {
    String url = await getBaseUrl() + "/api/Session/getToken/" + secret;
    print(url);
    try {
      var response = await dio.get(url);
      if (response.statusCode == 200) {
        sessionToken = response.data;
        return response.data;
      }
    } on DioError catch (ex) {
      if (ex.response.statusCode == 401){
        return "invalid";
      }
    } catch (e) {
      print(e);
    }
    return "error";
  }

  Future<bool> checkConnection(String ip, String port) async {
    String url = "http://" + ip + ":" + port + "/api/status";

    try {
      var response = await dio.get(url);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<String> changeLockStatus(bool closed) async {
    await Future.delayed(Duration(seconds: 1));
    if (sessionToken == null) {
      return "Keine session Aktiv";
    }
    String url = await getBaseUrl() +
        "/api/Lock/setLockState?session=" +
        sessionToken +
        "&closed=" +
        closed.toString();
    try {
      var response = await dio.post(url);
      if (response.statusCode == 200) {
        return "ok";
      }
    } catch (e) {
      print(e);
    }
    return "Fehler";
  }

  Future<bool> requestLockStatus() async {
    String url = await getBaseUrl() + "/api/Lock/isLocked?session=" + sessionToken;

    try {
      var response = await dio.get(url);
      if (response.statusCode == 200) {
        if (response.data == "true") {
          return true;
        }
        if (response.data == "false") {
          return false;
        }
      }
    } catch(e) {
      print(e);
    }
    return false;
  }

  Future<List<Credential>> getCredentials() async {
    String url = await getBaseUrl() + "/api/Credentials?session" + sessionToken;

    try {
      var response = await dio.get(url);
      if (response.statusCode == 200) {
        Map creds_raw = json.decode(response.data);
        creds_raw.forEach((key, value) {
          print(key + ":" + value);
        });
      }
    } catch(e) {
      print(e);
    }
  }


/*Future<bool> checkConnection(ip, port) async {
    String url = "http://" + ip + ":" + port + "/api/status";
    var client = new http.Client();
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (ex) {
      print(ex);
      return false;
    } finally {
      client.close();
    }
    return false;
  } */

}
