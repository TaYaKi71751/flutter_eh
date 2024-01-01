library flutter_eh;

import 'package:flutter_eh/eh/client.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class EHash {
  static Map<String, String> cacheEHashFromEhentai = <String, String>{};
  static Map<String, String> cacheEHashFromExhentai = <String, String>{};

  static Map<String, bool> notInEhentai = <String, bool>{};
  static Map<String, bool> notInExhentai = <String, bool>{};

  static Map<String, bool> lockEHash = <String, bool>{};

  static void handleNotInEhentai(String gid) async {
    notInEhentai[gid] = true;
    throw 'EHASH_NOT_FOUND_IN_EHENTAI';
  }

  static void handleNotInExhentai(String gid) {
    notInExhentai[gid] = true;
    throw 'EHASH_NOT_FOUND_IN_EXHENTAI';
  }

  static String fromHtml(String html,String gid){
    final url = parse(html)
      .querySelector('[href*="/g/${gid}"]')
      ?.attributes['href'];
    if(url?.isEmpty ?? true) throw 'EHASH_NOT_FOUND';
    return Uri.parse(url ?? '').path.split('/').lastWhere((e) => e.isNotEmpty);
  }

  static Future<String> fromEhentaiList(String gid) async {
    try {
      lockEHash[gid] = true;
      if (notInEhentai[gid] == true) handleNotInEhentai(gid);
      if (cacheEHashFromEhentai[gid]?.isNotEmpty ?? false) {
        return cacheEHashFromEhentai[gid]!;
      }
      http.Response res = await EHClient.get('https://e-hentai.org/?next=${int.parse(gid) + 1}');
      String ehash = fromHtml(res.body, gid);
      if (ehash.isEmpty) handleNotInEhentai(gid);
      cacheEHashFromEhentai[gid] = ehash;
      cacheEHashFromExhentai[gid] = ehash;
      notInEhentai[gid] = false;
      notInExhentai[gid] = false;
      return ehash;
    } catch (e) {
      notInEhentai[gid] = true;
      lockEHash[gid] = false;
      rethrow;
    } finally {
      lockEHash[gid] = false;
    }
  }

  static Future<String> fromExhentaiList(String gid) async {
    await waitEHashLock(gid);
    try {
      lockEHash[gid] = true;
      if (notInExhentai[gid] == true) handleNotInExhentai(gid);
      if (cacheEHashFromExhentai[gid]?.isNotEmpty ?? false) {
        return cacheEHashFromExhentai[gid]!;
      }
      http.Response res = await EHClient.get('https://exhentai.org/?next=${int.parse(gid) + 1}');
      String ehash = fromHtml(res.body, gid);
      if (ehash.isEmpty) handleNotInExhentai(gid);
      cacheEHashFromExhentai[gid] = ehash;
      notInExhentai[gid] = false;
      return ehash;
    } catch (e) {
      notInExhentai[gid] = true;
      lockEHash[gid] = false;
      rethrow;
    } finally {
      lockEHash[gid] = false;
    }
  }
  static Future<void> waitEHashLock(String gid) async {
    bool isLocked = true;
    do {
      await Future.delayed(Duration.zero, () {
        isLocked = lockEHash[gid] ?? false;
      });
    } while (isLocked == true);
    return;
  }
}
