import 'package:dio/dio.dart';
import 'package:doorlock_app/models/Credential.dart';
import 'package:doorlock_app/util/SharedPrefsHelper.dart';
import 'dart:async';

import 'CustomException.dart';

class ServerManager {
  Dio _dio;

  // singleton
  static ServerManager _instance;

  ServerManager._() {
    var options = BaseOptions(
      connectTimeout: 3000,
      receiveTimeout: 2000,
    );
    _dio = Dio(options);
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
      var response = await _dio.get(url);
      if (response.statusCode == 200) {
        sessionToken = response.data;
        return response.data;
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        return "error";
      }
      if (ex.response.statusCode == 401) {
        return "invalid"; // user provided an invalid
      }
    } catch (e) {
      print(e);
    }
    return "error";
  }

  Future<bool> checkConnection(String ip, String port) async {
    String url = "http://" + ip + ":" + port + "/api/status";

    try {
      var response = await _dio.get(url);
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
      var response = await _dio.post(url);
      if (response.statusCode == 200) {
        return "ok";
      }
    } catch (e) {
      print(e);
    }
    return "Fehler";
  }

  Future<bool> isLockLocked() async {
    String url =
        await getBaseUrl() + "/api/Lock/isLocked?session=" + sessionToken;

    try {
      var response = await _dio.get(url);
      if (response.statusCode == 200) {
        if (response.data.toString() == "true") {
          print("true");
          return true;
        }
        if (response.data.toString() == "false") {
          print("false");
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<String> uploadCredential(Credential credential) async {
    String url = await getBaseUrl() + "/api/Credentials/createPin?session=" + sessionToken;
    String cred_json = credential.toJson();

    try {
      var response = await _dio.post(url, data: cred_json);
      if (response.statusCode == 200) {
        return "ok";
      }
    } catch (e) {
      print(e);
    }

    return "error";
  }

  Future<String> deleteCredential(String uuid) async {
    String url =
        await getBaseUrl() + "/api/Credentials/deletePin/" + uuid + "?session=" + sessionToken;
    try {
      var response = await _dio.delete(url);
      if (response.statusCode == 200) {
        return "ok";
      }
    } catch (ex) {
      print(ex);
    }
    return "error";
  }

  Future<List<Credential>> getCredentials() async {
    String url =
        await getBaseUrl() + "/api/Credentials?session=" + sessionToken;
    List<Credential> creds = [];
    try {
      var response = await _dio.get(url);
      if (response.statusCode == 200) {
        response.data.forEach((pin) {
          creds.add(Credential.fromJson(pin));
        });
      }
      return creds;
    } catch (e) {
      print(e);
    }
    throw FetchDataException();
  }
}
