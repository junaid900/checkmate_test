import 'package:checkmate/modals/live_stream.dart';
import 'package:checkmate/modals/story.dart';
import 'package:checkmate/providers/firebase/firebase_live_stream_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class LiveStreamProvider extends ChangeNotifier {
  bool _isPosting = false;

  bool get isPosting => _isPosting;

  RefreshController refreshController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  List<LiveStream> _list = [];
  bool _isSaving = false;
  bool _isLiking = false;

  bool get isSaving => _isSaving;

  bool get isLiking => _isLiking;

  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  set isLiking(bool value) {
    _isLiking = value;
    notifyListeners();
  }

  set isPosting(bool value) {
    _isPosting = value;
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

  List<LiveStream> get list => _list;

  set list(List<LiveStream> value) {
    _list = value;
    notifyListeners();
  }

  Future<LiveStream?> createLiveStream(Map<String, dynamic> payload) async {
    try {
      isPosting = false;
      var response = await JApiService()
          .postRequest(JApi.CREAT_LIVE_STREAM, payload, showMessage: true);
      isPosting = true;
      if (response != null) {
        return LiveStream.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<LiveStream?> updateLiveStream(streamId,
      Map<String, dynamic> payload) async {
    try {
      FirebaseLiveStreamProvider().updateStreamValue(streamId, payload);
      var response = await JApiService()
          .postRequest(JApi.UPDATE_LIVE_STREAM + "/${streamId}", payload);
      if (response != null) {
        return LiveStream.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
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
    var response = await apiService.getRequest(JApi.GET_LIVESTREAMS);
    isLoading = false;
    list = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response.length; i++) {
          list.add(LiveStream.fromJson(response[i]));
        }
        // currentPage = response['current_page'];
        // maxPages = response['last_page'];
        list = list;
      }
    } else {
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
    var response =
    await JApiService().getRequest(JApi.GET_STORIES + "?page=${page}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<LiveStream> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(LiveStream.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }

  addMore(List<LiveStream> moreList) {
    list.addAll(moreList);
    notifyListeners();
  }

}