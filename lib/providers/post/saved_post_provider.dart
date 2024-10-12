import 'package:checkmate/modals/post_comment.dart';
import 'package:checkmate/modals/saved_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class SavedPostProvider extends ChangeNotifier{
  RefreshController refreshController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  List<SavedPost> _list = [];
  bool _isSending = false;


  bool get isSending => _isSending;

  set isSending(bool value) {
    _isSending = value;
    notifyListeners();
  }


  int get maxPages => _maxPages;

  set maxPages(int value) {
    _maxPages = value;
  }

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  List<SavedPost> get list => _list;
  set list(List<SavedPost> value) {
    _list = value;
    notifyListeners();
  }
  reset(user_id) async {
    currentPage = 0;
    maxPages = 0;
    list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load(user_id);
    return res;
  }

  Future<bool> load(user_id) async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.GET_SAVED_POSTS+"/${user_id}");
    isLoading = false;
    list = [];
    notifyListeners();
    if(response  != null){
      if(response.length > 0){
        list = [];
        for(int i = 0 ; i <  response['data'].length ; i++ ){
          list.add(SavedPost.fromJson(response['data'][i]));
        }
        currentPage = response['current_page'];
        maxPages = response['last_page'];
        list = list;
        notifyListeners();
      }
    }else{
      showToast("cannot load states");
    }
    return true;
  }
  Future<bool> loadMoreData(user_id) async {
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService().getRequest(
        JApi.GET_SAVED_POSTS +"/${user_id}" + "?page=${page}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<SavedPost> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(SavedPost.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }
  addMore(List<SavedPost> moreList){
    list.addAll(moreList);
    notifyListeners();
  }
}