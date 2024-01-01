import 'package:flutter_eh/eh_error.dart';
import 'package:flutter_eh/http/cookie.dart';
import 'package:http/http.dart' as http;

class EHCookie {
  String? sk,ipb_member_id,ipb_pass_hash,igneous;

  void clear(){
    sk = null;
    ipb_member_id = null;
    ipb_pass_hash = null;
    igneous = null;
  }
  
  static void validExCookie(EHCookie cookie){
    if(cookie.ipb_member_id?.isEmpty ?? true) EHError.requireCookie();
    if(cookie.ipb_pass_hash?.isEmpty ?? true) EHError.requireCookie();
    if(cookie.igneous == 'mystery') EHError.mysteryCookie();
  }
  static void validEhCookie(EHCookie cookie){
    if(cookie.ipb_member_id?.isEmpty ?? true) EHError.requireCookie();
    if(cookie.ipb_pass_hash?.isEmpty ?? true) EHError.requireCookie();
  }

  @override
  String toString(){
    var cookie = '';
    if(sk?.trim().isNotEmpty ?? false) cookie += 'sk=${sk};';
    if(ipb_member_id?.trim().isNotEmpty ?? false) cookie += 'ipb_member_id=${ipb_member_id}';
    if(ipb_pass_hash?.trim().isNotEmpty ?? false) cookie += 'ipb_pass_hash=${ipb_pass_hash}';
    if(igneous?.trim().isNotEmpty ?? false) cookie += 'igneous=${igneous}';
    return cookie;
  }

  static EHCookie fromString(String stringCookie){
    Map<String,String> cookieMap = <String,String>{};
    stringCookie
      .split(';')
      .map((cookieKeyVal) => cookieKeyVal.trim())
      .where((cookieKeyVal) => cookieKeyVal.contains('='))
      .forEach((cookieKeyVal) {
        final cookieKey = cookieKeyVal.substring(0, cookieKeyVal.indexOf('=')).trim();
        final cookieVal = cookieKeyVal.substring(cookieKeyVal.indexOf('=') + 1).trim();
        cookieMap[cookieKey] = cookieVal;
      });
    EHCookie rtn = EHCookie();
    rtn.sk = cookieMap['sk'];
    rtn.ipb_member_id = cookieMap['ipb_member_id'];
    rtn.ipb_pass_hash = cookieMap['ipb_pass_hash'];
    rtn.igneous = cookieMap['igneous'];
    return rtn;
  }

  static EHCookie fromCookie(Cookie cookie){
    EHCookie rtn = EHCookie();
    rtn.sk = cookie.get('sk');
    rtn.ipb_member_id = cookie.get('ipb_member_id');
    rtn.ipb_pass_hash = cookie.get('ipb_pass_hash');
    rtn.igneous = cookie.get('igneous');
    return rtn;
  }
  static EHCookie fromResponse(http.Response response){
    Cookie rtncookie = Cookie.fromString(response.request?.headers['Cookie'] ?? '');
    rtncookie.addAll(SetCookie.fromResponse(response));
    return EHCookie.fromCookie(rtncookie);
  }
}