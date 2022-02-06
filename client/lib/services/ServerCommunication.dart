import 'dart:convert';
import 'package:doorlock_app/services/ServerWrapper.dart';
import 'package:doorlock_app/util/SharedPrefsHelper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'CustomException.dart';

class ServerManager {
  var timeout = 500;

  Future<String> getBaseUrl() async {
    return "http://" + await getIpPort();
  }

  Future<String> sendRequest(url, {body = null}) async {
    print(url);
    try {
      if (body == null) {
        return _response(await http
            .get(Uri.parse(url))
            .timeout(Duration(milliseconds: timeout)));
      } else {
        return _response(await http
            .post(Uri.parse(url), body: body)
            .timeout(Duration(milliseconds: timeout)));
      }
    } on TimeoutException {
      throw TimeoutException("Timeout on request");
      return null;
    } catch (ex) {
      print(ex);
    }

    return null;
  }


  Future<String> sendPostRequest(url, {body = null}) async {
    print(url);
    try {
        return _response(await http
            .post(Uri.parse(url), body: body)
            .timeout(Duration(milliseconds: timeout)));
    } on TimeoutException {
      throw TimeoutException("Timeout on request");
      return null;
    } catch (ex) {
      print(ex);
    }

    return null;
  }



  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return response.body.toString();
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }
}

Future<http.Response> changeDoorStateAsync(bool locked) async {
  ServerWrapper.getInstance().setLockState(!locked);
}
