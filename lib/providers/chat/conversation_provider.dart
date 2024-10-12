import 'dart:convert';
import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../constraints/helpers/helper.dart';
import '../../modals/conversation.dart';

class ConversationProvider extends ChangeNotifier{
  int _currentPage = 0;
  int _maxPages = 0;
  List<Conversation> _list = [];
  bool _isLoading = false;

  int get currentPage => _currentPage;
  int get maxPages => _maxPages;
  bool get isLoading => _isLoading;
  List<Conversation> get list => _list;
  RefreshController refreshController = RefreshController();

  set isLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  set maxPages(int value) {
    _maxPages = value;
    notifyListeners();
  }
  set list(List<Conversation> value) {
    _list = value;
    notifyListeners();
  }

  updateChat(Conversation conversation){
    int index = _list.indexWhere((element) => element.id == conversation.id);
    if(index>=0) {
      _list[index] = conversation;
      notifyListeners();
    }
  }
  Future<Conversation?> checkChat({context, userId,otherUserId, selfId}) async {
    try {
      if(userId == null){
        showToast("cannot get your details");
        return null;
      }
      if(otherUserId == null){
        showToast("cannot get user details");
        return null;
      }
      List list = [userId, otherUserId.toString()];
      var payload = {"user_ids": jsonEncode(list)};
      showProgressDialog(context, "Please wait");
      var response = await JApiService()
          .postRequest(JApi.CHECK_CHAT + "/${selfId}", payload);
      hideProgressDialog(context);
      if (response != null) {
        // Conversation conversation;
        // otherUserProfile = UserProfile.fromJson(response);
        if (response.isNotEmpty) {
          return Conversation.fromJson(response);
        } else {
          return Conversation();
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
  reset({loading = true}) async {
    currentPage = 0;
    maxPages = 0;
    if(loading)  list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load();
    return res;
  }

  Future<bool> load() async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.CHAT_LIST);
    isLoading = false;
    // list = [];
    notifyListeners();
    if(response  != null){
      if(response.length > 0){
        list = [];
        for(int i = 0 ; i <  response['data'].length ; i++ ){
          list.add(Conversation.fromJson(response['data'][i]));
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
  Future<bool> loadMoreData() async {
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService().getRequest(
        JApi.CHAT_LIST + "?page=${page}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<Conversation> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(Conversation.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }
  addMore(List<Conversation> moreList){
    list.addAll(moreList);
    notifyListeners();
  }

}