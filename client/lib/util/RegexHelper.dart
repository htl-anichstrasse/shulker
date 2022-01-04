class RegexHelper {

  static const Pattern ipv4 =
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';

  static bool isIpV4(String input){
    return RegExp(ipv4).hasMatch(input);
  }

}