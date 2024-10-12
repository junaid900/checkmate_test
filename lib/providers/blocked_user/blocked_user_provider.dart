import 'package:checkmate/modals/blocked_user.dart';
import 'package:checkmate/modals/cmsupport.dart';
import 'package:flutter/cupertino.dart';
import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class BlockedUserProvider extends ChangeNotifier{
  bool _isLoading = false;
  List<BlockedUser> _list = [];
  int _currentPost = 0;
  bool _isSending = false;


  bool get isSending => _isSending;

  set isSending(bool value) {
    _isSending = value;
    notifyListeners();
  }

  int get currentPost => _currentPost;

  set currentPost(int value) {
    _currentPost = value;
    notifyListeners();
  }
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  List<BlockedUser> get list => _list;
  set list(List<BlockedUser> value) {
    _list = value;
    notifyListeners();
  }

  block({required userId, type = "block"}) async {
    isSending = true;
    JApiService apiService = JApiService();
    var response = await apiService.getRequest(JApi.BLOCK_UNBLOCK_USER + "/${userId}/${type}");
    isSending = false;
    if(response != null){
      if(type == "block"){
        showToast("User Blocked Successfully");
      }else{
        showToast("User unblocked successfully");
      }
      return true;
    }else{
      
    }
  }

  Future<bool> load() async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.GET_BLOCKED_USERS);
    isLoading = false;
    list = [];
    notifyListeners();
    if(response  != null){
      list = [];
      if(response.length > 0){
        for(int i = 0 ; i <  response.length ; i++ ){
          list.add(BlockedUser.fromJson(response[i]));
        }
        list = list;
        notifyListeners();
      }
    }else{
      // showToast("cannot ");
    }
    return true;
  }
}