import 'package:http/http.dart' as http;
class Cookie {
  Map<String,String> cookieMap = <String,String>{};

  void clear(){
    cookieMap.clear();
  }

  @override
  String toString() {
    List<String> cookies = [];
    cookieMap
      .forEach((key,val) => cookies.add('${key.trim()}=${val.trim()}'));
    return cookies
      .map((cookie) => cookie.trim())
      .where((cookie) => cookie.isNotEmpty).join(';');
  }

  void addAllFromMap(Map<String,String> map){
    cookieMap.addAll(map);
  }

  void addAll(Cookie cookie){
    cookieMap.addAll(cookie.cookieMap);
  }

  static Cookie fromString(String cookieString){
    Cookie rtn = Cookie();
    cookieString
      .split(';')
      .map((cookieKeyVal) => cookieKeyVal.trim())
      .where((cookieKeyVal) => cookieKeyVal.contains('='))
      .forEach((cookieKeyVal) {
        final cookieKey = cookieKeyVal.substring(0, cookieKeyVal.indexOf('=')).trim();
        final cookieVal = cookieKeyVal.substring(cookieKeyVal.indexOf('=') + 1).trim();
        rtn.cookieMap[cookieKey] = cookieVal;
      });
    return rtn;
  }

  String? get(String key){
    return cookieMap[key];
  }
}

class SetCookie {
  static Cookie fromResponse(http.Response response){
    return SetCookie.fromString(response.headers['set-cookie'] ?? '');
  }
  static Cookie fromString(String setCookieString){
    Cookie rtn = Cookie();
    setCookieString
      .split(',')
      .map((setcookie) => setcookie.trim())
      .where((setcookie) => setcookie.contains(';'))
      .where((setcookie) => setcookie.contains('='))
      .forEach((setcookie) {
        final cookieKeyVal = setcookie.trim().split(';').map((e) => e.trim()).firstWhere((e) => e.contains('=')).trim();
        final cookieKey = cookieKeyVal.substring(0,cookieKeyVal.indexOf('=') + 1).trim();
        final cookieVal = cookieKeyVal.substring(cookieKeyVal.indexOf('=') + 1).trim();
        rtn.cookieMap[cookieKey] = cookieVal;
      });
    return rtn;
  }
}