import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:checkmate/constraints/enum_values.dart';
import 'package:checkmate/modals/common/send_notification_data.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../constraints/helpers/app_methods.dart';
import '../constraints/helpers/helper.dart';
import '../constraints/helpers/session_helper.dart';
import 'japi.dart';
import 'package:get/get.dart' as XGet;

class JApiService {
  getMultiPartHeaders() async {
    if (await isLogin()) {
      var token = (await getSession());
      print('token: $token');
      String? br = token;
      if (br == null) {
        showToast("Session Expired");
        // XGet.Get.offAll(AuthScreen());
        goToLogin();
        return null;
      }
      return <String, String>{
        "Authorization": "Bearer " + br,
        "Accept": "application/json"
      };
    } else {
      return {
        "Accept": "application/json",
      };
    }
  }

  getHeaders() async {
    String br = '';
    String? token = await getSession();
    Map<String, String> headers = {
      "Accept": "application/json",
    };

    if (await isLogin()) {
      if (token == null) {
        showToast("Session Expired");
        goToLogin();
        return null;
      }
      headers["Authorization"] = "Bearer " + token;
    }
    return headers;
  }

  temp() async {
    final Client client = http.Client();
    try {
      log('127.0.0.1:8000/api/websocket');
      final Response response = await client.get(
        Uri.parse('http://192.168.10.32:80/api/websocket'),
      );
      final hashMap = json.decode(response.body);
      log('MK: response: ${hashMap}');
    } catch (e) {
      log('error: ${e}');
    }
  }

  Future<dynamic> getRequest(String url) async {
    final Client client = http.Client();
    try {
      log('${JApi.BASE_URL}$url');
      final Response response = await client
          .get(Uri.parse('${JApi.BASE_URL}$url'), headers: await getHeaders());

      final hashMap = json.decode(response.body);
      print(hashMap.toString());
      if (hashMap['status'] == 1) {
        var decData = hashMap['response'];
        Map data = {};
        data["response"] = decData;
        return data["response"];
      }
      if (hashMap["status"].toString() == "-1") {
        goToLogin();
        return null;
      }
      showToast(hashMap['message'] ?? 'Unable to fetch server response');
      if (hashMap["status"].toString() == "0") {
        return null;
      }
      return null;
    } catch (e) {
      print(e.toString());
      log('error in getRequest $e');
      return null;
    } finally {
      client.close();
    }
  }

  Future<dynamic> postRequest(String url, Map<String, dynamic> data,
      {showMessage = false, returnMessage = false}) async {
    final Client client = http.Client();
    try {
      dynamic headers = await getHeaders();
      print('${JApi.BASE_URL}$url');
      log("==>MJ: here:$url ${data}");
      final Response response = await http.post(
          Uri.parse('${JApi.BASE_URL}$url'),
          body: data,
          headers: headers);
      print('hashmap: ${response.body.toString()}');
      final hashMap = json.decode(response.body);
      if (hashMap["extra_data"] != null) {
        handleExtraData(hashMap["extra_data"]);
      }
      if (hashMap['status'] == 1) {
        dynamic decData = hashMap['response'];
        Map data = {};
        data["response"] = decData;
        if (showMessage) {
          showToast(hashMap['message'] ?? 'Success');
        }
        return hashMap["response"];
      }
      if (hashMap["status"].toString() == "-1") {
        goToLogin();
        return null;
      }
      if (returnMessage) {
        if (hashMap['message'] != null) {
          return hashMap['message'];
        }
      }
      showToast(hashMap['message'] ?? 'Unable to fetch server response');
      // print(data["response"] + " res "+ hashMap["status"]);

      return null;
    } catch (e) {
      log(e.toString());
      return null;
      // return MJResource<R>(MJStatus.ERROR, e.toString(), null); //e.message ??
    } finally {
      client.close();
    }
  }

  Future<dynamic> postMultiPartRequest(url, Map<String, File> files,
      {Map<String, String>? data}) async {
    try {
      Uri uri = Uri.parse('${JApi.BASE_URL}$url');
      log('url: ${JApi.BASE_URL}$url');

      var request = MultipartRequest("POST", uri);

      for (int i = 0; i < files.length; i++) {
        request.files.add(await MultipartFile.fromPath(
            files.keys.elementAt(i), files[files.keys.elementAt(i)]!.path));
      }
      request.headers.addAll(await getHeaders());

      if (data != null) request.fields.addAll(data);
      var response = await request.send();

      var res = await http.Response.fromStream(response);
      log("MJ: response ${res.body.toString()}");

      final hashMap = json.decode(res.body);

      if (hashMap['status'] == 1) {
        print("\x1B[30m in if");
        dynamic decData = hashMap['response'];
        Map data = {};
        data["response"] = decData;
        data['message'] = hashMap['message'];
        data['status'] = hashMap['status'];
        log("${data}");
        return decData;
      }
      showToast(hashMap['message']);
      return null;
    } catch (exp) {
      print("MJ Error :" + exp.toString());
      showToast("Unfortunate Error");
      return null;
    }
  }

  Future<dynamic> multipartPostRequest(String url, Map data) async {
    try {
      print('${JApi.BASE_URL}$url');
      Uri uri = Uri.parse('${JApi.BASE_URL}$url');
      var request = http.MultipartRequest("POST", uri);

      request.fields['description'] = data['description'];
      request.headers.addAll(await getMultiPartHeaders());

      List<String?> imgPaths = data['image'];
      List<String?> videoPaths = data['video'];

      if (imgPaths.length >= 1) {
        for (var path in imgPaths) {
          request.files.add(await MultipartFile.fromPath('image[]', path!));
        }
      }
      if (videoPaths.length >= 1) {
        for (var path in videoPaths) {
          request.files.add(await MultipartFile.fromPath('video[]', path!));
        }
      }

      http.Response response =
          await http.Response.fromStream(await request.send());

      print('${JApi.BASE_URL}$url');
      print('myResponse ' + response.body.toString());

      final hashMap = json.decode(response.body);
      print('myHashmapStatus: ${hashMap['status']}');
      if (hashMap['status'] == 1) {
        // String decData = await decryptString(hashMap['response']);
        String decData = hashMap['response'];
        dynamic data = json.decode(decData);
        print('data is in if: ${data}');
        return data;
      }
      showToast(hashMap['message']);
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    } finally {}
  }

  handleExtraData(data) {
    try {
      if (data["notification"] != null) {
        print("notification_Data");
        var notification =
            CMSendNotificationData.fromJson(data['notification']);
        print(notification.toJson());
        postRequest(JApi.SEND_NOTIFICATION, notification.toJson())
            .then((value) {
          print("notification");
          print(value);
        });
      }
    } catch (e) {}
  }
}
