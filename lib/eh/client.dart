import 'package:flutter_eh/eh/cookie.dart';
import 'package:flutter_eh/http/http.dart';
import 'package:http/http.dart' as http;

class EHClient {
  static EHCookie cookie = EHCookie();
  static void setCookie(EHCookie ck){
    cookie = ck;
  }

  static Future<http.Response> get(String url,{
    Map<String,String>? headers,
  }) async {
    if(Uri.parse(url).path.contains('favorites.php')) EHCookie.validEhCookie(cookie);
    if(Uri.parse(url).host.contains('exhentai.org')) EHCookie.validExCookie(cookie);
    var tmpHeaders = headers ?? {};
    tmpHeaders.addAll({ 'Cookie': cookie.toString() });
    return await DynamicHttpRequest.get(url,headers: headers);
  }

  static Future<http.Response> post(String url,{
    Map<String,String>? headers,
    String? body
  }) async {
    var tmpHeaders = headers ?? {};
    tmpHeaders.addAll({ 'Cookie': cookie.toString() });
    return await DynamicHttpRequest.post(
      url,
      headers: tmpHeaders,
      body:body
    );
  }
}