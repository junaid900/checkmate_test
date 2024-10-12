import 'package:checkmate/modals/cmsupport.dart';
import 'package:flutter/cupertino.dart';
import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class SupportProvider extends ChangeNotifier{
  bool _isLoading = false;
  List<CMSupport> _list = [];
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
  List<CMSupport> get list => _list;
  set list(List<CMSupport> value) {
    _list = value;
    notifyListeners();
  }

  add({required title, required description}) async {
    isSending = true;
    JApiService apiService = JApiService();
    var response = await apiService.postRequest(JApi.ADD_SUPPORT, {
      "title": title,
      "description": description,
    });
    isSending = false;
    if(response != null){
      try{
        CMSupport newSupportItem = CMSupport.fromJson(response);
        if(newSupportItem.id != null){
          _list.insert(0, newSupportItem);
          notifyListeners();
          return true;
        }
      }catch(e){
        return;
      }
    }

  }

  Future<bool> load() async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.GET_SUPPORT);
    isLoading = false;
    list = [];
    notifyListeners();
    if(response  != null){
      if(response.length > 0){
        list = [];
        for(int i = 0 ; i <  response.length ; i++ ){
          list.add(CMSupport.fromJson(response[i]));
        }
        list = list;
        notifyListeners();
      }
    }else{
      // showToast("cannot load states");
    }
    return true;
  }
}