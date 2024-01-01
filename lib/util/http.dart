library flutter_eh;

import 'package:http/http.dart' as http;

class DynamicHttpRequest {
  static bool lockRequest = false;

  static bool asyncRequest = false;

  static Future<http.Response> get(String url,
      {Map<String, String>? headers}) async {
    if (asyncRequest == false) await waitRequestLock();
    http.Response? res;
    try {
      lockRequest = true;
      res = await http.get(Uri.parse(url), headers: headers);
    } catch (e) {
      lockRequest = false;
      rethrow;
    } finally {
      lockRequest = false;
    }
    return res;
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async {
    if (asyncRequest == false) await waitRequestLock();
    http.Response? res;
    try {
      lockRequest = true;
      res = await http.post(Uri.parse(url), headers: headers, body: body);
    } catch (e) {
      lockRequest = false;
      rethrow;
    } finally {
      lockRequest = false;
    }
    return res;
  }

  static Future<void> waitRequestLock() async {
    bool isLocked = true;
    do {
      await Future.delayed(Duration.zero, () {
        isLocked = lockRequest;
      });
    } while (isLocked == true);
    return;
  }
}
