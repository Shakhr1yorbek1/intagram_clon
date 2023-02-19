
import 'dart:convert';

import 'package:http/http.dart';

import '../model/member_model.dart';

class  Network {

  static String BASE = "fcm.googleapis.com";
  static String api = "/fcm/send";
  static Map<String , String> headers = {
    "Authorization" : "key=AAAAHPMzdWw:APA91bFxF8rS9ow1YsTLvY5NAHS2FK7B9N551aBb09hE59Y8WqMmhiZov0eFKHzCbpBmq7H04XPLzmemX3aKJt-8XtHQJ4bUzINXZBL179EDB79Shc31tHEA2-c7tWXAsnilwq9b3Wvz",
    "Content-Type" : "application/json"
  };




  static Future<String?> POST(Map<String, dynamic> params) async {
    var uri = Uri.https(BASE, api);
    var response = await post(uri, headers : headers, body: jsonEncode(params));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future sendNotification(String name, Member someone) async {
    Map<String, dynamic> params = {
      "notification":
      {
        "body": name + " is your new subscriber",
        "title": "😎 New Followers 😎"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": someone.device_token
    };
    POST(params);
  }

}