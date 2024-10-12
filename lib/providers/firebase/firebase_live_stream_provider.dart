import 'dart:async';

import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../../modals/User.dart';
import '../../modals/live_stream.dart';

class FirebaseLiveStreamProvider extends ChangeNotifier {
  List<LiveStream> _list = [];
  StreamSubscription<DatabaseEvent>? liveStreamRef = null;
  StreamSubscription<DatabaseEvent>? viewerRef = null;
  final database = FirebaseDatabase.instance;
  int _viewersCount = 0;

  int get viewersCount => _viewersCount;

  set viewersCount(int value) {
    _viewersCount = value;
    notifyListeners();
  }

  List<LiveStream> get list => _list;

  // Proxy Provider
  // final User? profile;
  // FirebaseLiveStreamProvider(this.profile) {
  //   if (this.profile != null) {
  //     // if (profile) fetchMessages();
  //   }
  // }
  set list(List<LiveStream> value) {
    _list = value;
    notifyListeners();
  }

  Future<bool> startStream(LiveStream liveStream) async {
    Map liveStreamMap = liveStream.toJson();
    liveStreamMap["viewers"] = "";
    await database.ref('livestreams/${liveStream.id}').set(liveStreamMap);
    return true;
  }

  Future<bool> setSteamStatus(LiveStream stream, String status) async {
    if (status == "Ended") {
      deleteStream(stream.id);
      return false;
    }
    await database.ref('livestreams/${stream.id}').update({"status": status});
    return true;
  }

  Future<bool> updateStreamValue(streamId, data) async {
    if (data["uid"] != null) {
      data["agora_uid"] = data["uid"];
    }
    if (data["status"] == "Ended") {
      deleteStream(streamId);
      return false;
    }
    await database.ref('livestreams/${streamId}').update(data);
    return true;
  }

  initLoadStreams(User user) {
    if (liveStreamRef != null) {
      liveStreamRef = null;
    }
    liveStreamRef = database
        .ref('livestreams')
        .orderByChild('status')
        .equalTo("Live")
        .onValue
        .listen((event) {
      var dataSnapshot = event.snapshot;
      print("here");
      if (dataSnapshot.value == null) {
        list = [];
        return;
      }
      print("here2");
      // print(dataSnapshot.value);
      Map _values = dataSnapshot.value as Map;
      if (_values.length > 0) {
        list = [];
      }
      print(_values);

      _values.forEach((key, values) {
        if (values["user_id"].toString() != user.id.toString()) {
          var val = values as Map;
          print(val["user"]);
          if (val["agora_uid"] == null) {
            deleteStream(key);
            return;
          }
          if (val["user"] == null) {
            return;
          }
          var userVal = val["user"] as Map;
          _list.add(LiveStream.fromJson({
            "end_time": val["end_time"] ?? '',
            "status": val["status"] ?? '',
            "channel_name": val["channel_name"] ?? '',
            "agora_uid": val["agora_uid"] ?? '',
            "created_at": val["created_at"] ?? '',
            "id": val["id"] ?? '',
            "start_time": val["start_time"] ?? '',
            "title": val["title"] ?? '',
            "user_id": val["user_id"] ?? '',
            "agora": val["user_id"] ?? '',
            "description": val["description"] ?? '',
            "user": {
              "id": userVal["id"] ?? '',
              "fname": userVal["fname"] ?? '',
              "profile_image": userVal["profile_image"] ?? '',
              "email": userVal["email"] ?? '',
            },
          }));
        }
        print('Key: $key');
        // print('Name: ${values['name']}');
        // print('Email: ${values['email']}');
        // print('Age: ${values['age']}');
      });
      list = _list;
    });
  }

  deleteStream(streamId) async {
    await database.ref('livestreams/${streamId}').remove();
  }

// Stream Viewers
  Future<bool> insertViewer(
      {required user_id,
      required uid,
      required status,
      required streamId}) async {
    await database
        .ref('livestreams/${streamId}/viewers/${user_id}')
        .set({"user_id": user_id, "agora_uid": uid, "status": status});
    return true;
  }

  Future<bool> removeViewer({required streamId, required user_id}) async {
    await database.ref('livestreams/${streamId}/viewers/${user_id}').remove();
    return true;
  }

  initViewers({required streamId, required user_id}) async {
    // initLoadStreams(User user) {
    if (viewerRef != null) {
      viewerRef!.cancel();
      viewerRef = null;
    }
    print("livestreams/${streamId}/viewers");
    viewerRef = database
        .ref('livestreams/${streamId}/viewers')
        .orderByChild('status')
        .equalTo("Online")
        .onValue
        .listen((event) {
      var dataSnapshot = event.snapshot;
      print("here in viewer");
      print(dataSnapshot.value);
      if (dataSnapshot.value == null) {
        viewersCount = 0;
        return;
      }
      print("here2");
      print(dataSnapshot.value);
      Map _values = dataSnapshot.value as Map;
      viewersCount = convertNumber(_values.length.toString());
    });
  }
// }
}
