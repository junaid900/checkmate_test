import 'package:checkmate/modals/cmnotification.dart';
import 'package:checkmate/modals/post_comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class NotificationProvider extends ChangeNotifier {
  RefreshController refreshController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  List<CMNotification> _list = [];
  int _currentPost = 0;

  int get currentPost => _currentPost;

  set currentPost(int value) {
    _currentPost = value;
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

  List<CMNotification> get list => _list;

  set list(List<CMNotification> value) {
    _list = value;
    notifyListeners();
  }

  reset() async {
    currentPage = 0;
    maxPages = 0;
    list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load();
    return res;
  }

  Future<bool> load() async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response =
        await apiService.getRequest(JApi.GET_NOTIFICATIONS);
    isLoading = false;
    list = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response['data'].length; i++) {
          list.add(CMNotification.fromJson(response['data'][i]));
        }
        currentPage = response['current_page'];
        maxPages = response['last_page'];
        list = list;
        notifyListeners();
      }
    } else {
      showToast("cannot load states");
    }
    return true;
  }

  Future<bool> loadMoreData() async {
    // if (currentPost < 1) {
    //   return false;
    // }
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService()
        .getRequest(JApi.GET_NOTIFICATIONS + "?page=${page}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<CMNotification> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(CMNotification.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }

  addMore(List<CMNotification> moreList) {
    list.addAll(moreList);
    notifyListeners();
  }
}
