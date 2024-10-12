import 'package:checkmate/modals/cmpost.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';
import '../../modals/User.dart';

class ProfileProvider extends ChangeNotifier{
  User _profile = User();
  User get profile => _profile;
  bool _isLoading = false;

  RefreshController refreshController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  bool _postLoading = false;
  bool _isFollowLoading = false;
  bool _isUpdatingProfile = false;
  List<CMPost> _list = [];
  List<User> followersList = [];


  bool get isUpdatingProfile => _isUpdatingProfile;

  set isUpdatingProfile(bool value) {
    _isUpdatingProfile = value;
    notifyListeners();
  }

  bool get isFollowLoading => _isFollowLoading;

  set isFollowLoading(bool value) {
    _isFollowLoading = value;
    notifyListeners();
  }
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set profile(User value) {
    _profile = value;
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

  bool get postLoading => _postLoading;

  set postLoading(bool value) {
    _postLoading = value;
  }

  List<CMPost> get list => _list;

  set list(List<CMPost> value) {
    _list = value;
  }



  Future<User?> getProfileData(userId) async {
    try{
      JApiService apiService = JApiService();
      isLoading = true;
      var response = await apiService.getRequest(JApi.GET_PROFILE+"/${userId}");
      isLoading = false;
      if(response != null){
        var user = User.fromJson(response);
        return user;
      }
    }catch(e){}
    return null;
  }
  Future<bool> follow(type, other_user_id) async {
    try{
      JApiService apiService = JApiService();
      isFollowLoading = true;
      var response = await apiService.postRequest(JApi.FOLLOW+"/${profile.id}",{
        "type": type,
        "other_user_id": other_user_id
      }, showMessage: false);
      isFollowLoading = false;
      if(response != null) {
        return true;
      }
    }catch(e){}
    return false;
  }
  Future<bool> updateProfile(payload,{showToast = true}) async {
    try{
      JApiService apiService = JApiService();
      isUpdatingProfile = true;
      var response = await apiService.postRequest(JApi.UPDATE_PROFILE,payload, showMessage: showToast);
      isUpdatingProfile = false;
      if(response != null) {
        profile = User.fromJson(response);
        return true;
      }
    }catch(e){}
    return false;
  }

  reset(userId) async {
    currentPage = 0;
    maxPages = 0;
    list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load(userId);
    return res;
  }

  Future<List<User>?> loadFollowers(type, userId) async {
    try{
      JApiService apiService = JApiService();
      var response = await apiService.getRequest(JApi.GET_FOLLOWERS+"/$type/$userId");
      followersList = [];
      notifyListeners();
      if(response  != null){
        if(response.length > 0){
          for(int i = 0 ; i <  response.length ; i++ ){
            followersList.add(User.fromJson(response[i]));
          }
          followersList = followersList;
          notifyListeners();
        }
        return followersList;
      }else{
        // showToast("cannot load states");
      }
    }catch(e){

    }

    return null;
  }

  Future<bool> load(userId) async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.GET_POSTS+"?user_id=${userId}");
    isLoading = false;
    list = [];
    notifyListeners();
    if(response  != null){
      if(response.length > 0){
        list = [];
        for(int i = 0 ; i <  response['data'].length ; i++ ){
          list.add(CMPost.fromJson(response['data'][i]));
        }
        currentPage = response['current_page'];
        maxPages = response['last_page'];
        list = list;
        notifyListeners();
      }
    }else{
      // showToast("cannot load states");
    }
    return true;
  }
  Future<bool> loadMoreData(userId) async {
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService().getRequest(
        JApi.GET_POSTS + "?page=${page}&user_id=${userId}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<CMPost> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(CMPost.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }
  addMore(List<CMPost> moreList){
    list.addAll(moreList);
    notifyListeners();
  }


}