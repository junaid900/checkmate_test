import 'package:checkmate/modals/cmpost.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';

class PostProvider extends ChangeNotifier{
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
  Future<int> save(postId) async {
    JApiService apiService = JApiService();
    isSaving = true;
    var response = await apiService.postRequest(JApi.SAVE_POST, {
      "post_id": postId.toString(),
    }, showMessage: true);
    isSaving = false;
    if(response != null){
      try{
        if(response["saved"] == 1){
          return 1;
        }
       return 2;
      }catch(e){
        return -1;
      }
    }
    return -1;
  }

  Future<List<CMPost>?> getPostById(postId) async {
      JApiService apiService = JApiService();

      var query = "?time=${DateTime.now().millisecondsSinceEpoch}";
      if(postId.isNotEmpty){
        query += "&post_id=${postId}";
      }
      var response = await apiService.getRequest(JApi.GET_POSTS+query);
      if(response != null){
        if(response.length > 0){
          List<CMPost> list = [];
          for(int i = 0 ; i <  response['data'].length ; i++ ){
            list.add(CMPost.fromJson(response['data'][i]));
          }
          return list;
        }
      }
      return null;
  }

}