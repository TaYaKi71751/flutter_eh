library flutter_eh;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class EHash {
  static Map<String,String> cacheEHashFromEhentai = <String, String>{};
  static Map<String,String> cacheEHashFromExhentai = <String, String>{};

  static Map<String,bool> notInEhentai = <String,bool>{};
  static Map<String,bool> notInExhentai = <String,bool>{};

  static Map<String,bool> lockEHash = <String,bool>{};
  static bool lockRequest = false;
  
  static bool asyncRequest = false;

  static String cookie = '';

  static void setCookie(String cookieToSet){
    cookie = cookieToSet;
  }

  static void handleNotInEhentai(String gid) async {
    notInEhentai[gid] = true;
    throw 'EHASH_NOT_FOUND_IN_EHENTAI';
  }
  static void handleNotInExhentai(String gid) {
    notInExhentai[gid] = true;
    throw 'EHASH_NOT_FOUND_IN_EXHENTAI';
  }

  static Future<String> fromEhentai(String gid) async {
    if(asyncRequest == true) {
      await waitEHashLock(gid);
    } else {
      await waitRequestLock();
    }
    try { 
      lockEHash[gid] = true;
      lockRequest = true;
      if(notInEhentai[gid] == true) handleNotInEhentai(gid);
      if(cacheEHashFromEhentai[gid] != null){
        return cacheEHashFromEhentai[gid]!;
      }
      http.Response res = await http.get(
        Uri.parse('https://e-hentai.org/?next=${int.parse(gid) + 1}'),
        headers: { 'Cookie': cookie }
      );
      String? url = parse(res.body)
        .querySelector('[href*="/g/$gid"]')?.attributes['href'];
      if(url?.isEmpty ?? true) handleNotInEhentai(gid);
      String ehash = Uri.parse(url ?? '').path.split('/').lastWhere((e) => e.trim().isNotEmpty);
      if(ehash.isEmpty) handleNotInEhentai(gid);
      cacheEHashFromEhentai[gid] = ehash;
      cacheEHashFromExhentai[gid] = ehash;
      notInEhentai[gid] = false;
      notInExhentai[gid] = false;
      return ehash;
    } catch(e) {
      notInEhentai[gid] = true;
      lockEHash[gid] = false;
      lockRequest = false;
      rethrow;
    } finally {
      lockEHash[gid] = false;
      lockRequest = false;
    }
  }

  static Future<String> fromExhentai(String gid) async {
    if(asyncRequest == true) {
      await waitEHashLock(gid);
    } else {
      await waitRequestLock();
    }
    try {
      lockEHash[gid] = true;
      lockRequest = true;
      if(notInExhentai[gid] == true) handleNotInExhentai(gid);
      if(cacheEHashFromExhentai[gid] != null){
        return cacheEHashFromExhentai[gid]!;
      }
      http.Response res = await http.get(
        Uri.parse('https://exhentai.org/?next=${int.parse(gid) + 1}'),
        headers: { 'Cookie': cookie }
      );
      String? url = parse(res.body)
        .querySelector('[href*="/g/$gid"]')?.attributes['href'];
      if(url?.isEmpty ?? true) handleNotInExhentai(gid);
      String ehash = Uri.parse(url ?? '').path.split('/').lastWhere((e) => e.trim().isNotEmpty);
      if(ehash.isEmpty) handleNotInExhentai(gid);
      cacheEHashFromExhentai[gid] = ehash;
      notInExhentai[gid] = false;
      return ehash;
    } catch(e) {
      notInExhentai[gid] = true;
      lockEHash[gid] = false;
      lockRequest = false;
      rethrow;
    } finally {
      lockEHash[gid] = false;
      lockRequest = false;
    }
  }
  
  static Future<void> waitRequestLock() async {
    bool isLocked = true;
    do {
      await Future.delayed(Duration.zero,(){
        isLocked = lockRequest;
      });
    }while(isLocked == true);
    return;
  }

  static Future<void> waitEHashLock(String gid) async {
    bool isLocked = true;
    do {
      await Future.delayed(Duration.zero,(){
        isLocked = lockEHash[gid] ?? false;
      });
    }while(isLocked == true);
    return;
  }
}