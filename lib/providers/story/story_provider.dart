import 'package:checkmate/modals/story.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class StoryProvider extends ChangeNotifier {
  bool _isPosting = false;

  bool get isPosting => _isPosting;

  RefreshController refreshController = RefreshController();

  int _maxPages = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  List<Story> _list = [];
  bool _isSaving = false;
  bool _isLiking = false;
  RefreshController foRefreshController = RefreshController();
  int _foMaxPages = 0;
  int _foCurrentPage = 0;
  bool _foIsLoading = false;
  List<Story> _foList = [];

  int get foMaxPages => _foMaxPages;

  set foMaxPages(int value) {
    _foMaxPages = value;
    notifyListeners();
  }

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

  List<Story> get list => _list;

  set list(List<Story> value) {
    _list = value;
    notifyListeners();
  }

  Future<bool> postStory(Map<String, dynamic> payload) async {
    try {
      isPosting = false;
      var response = await JApiService()
          .postRequest(JApi.CREAT_STORY, payload, showMessage: true);
      isPosting = true;
      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  reset({currentTab = ""}) async {
    currentPage = 0;
    maxPages = 0;
    list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load(currentTab: currentTab);
    return res;
  }

  int getStoryIndexById(storyId) {
    try {
      int index =
          list.indexOf(list.where((element) => element.id == storyId).first);
      return index;
    } catch (e) {
      return -1;
    }
  }

  Future<bool> load({String currentTab = ""}) async {
    JApiService apiService = JApiService();
    isLoading = true;
    var query = "?time=q8q9e89";
    if (currentTab.isNotEmpty) {
      query += "&type=$currentTab";
    }
    var response = await apiService.getRequest(JApi.GET_STORIES + query);
    isLoading = false;
    list = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response['data'].length; i++) {
          list.add(Story.fromJson(response['data'][i]));
        }
        currentPage = response['current_page'];
        maxPages = response['last_page'];
        list = list;
        notifyListeners();
      }
    } else {
      // showToast("cannot load states");
    }
    return true;
  }

  Future<bool> loadMoreData({String currentTab = ""}) async {
    var query = "";
    if (currentTab.isNotEmpty) {
      query += "&type=$currentTab";
    }
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService()
        .getRequest(JApi.GET_STORIES + "?page=${page}$query");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<Story> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(Story.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }

  addMore(List<Story> moreList) {
    list.addAll(moreList);
    notifyListeners();
  }

  //
  foReset() async {
    foCurrentPage = 0;
    foMaxPages = 0;
    foList = [];
    foIsLoading = false;
    foRefreshController.footerMode!.value = LoadStatus.idle;
    bool res = await foLoad();
    return res;
  }

  Future<bool> foLoad() async {
    JApiService apiService = JApiService();
    foIsLoading = true;
    var response =
        await apiService.getRequest(JApi.GET_STORIES + "?type=following");
    foIsLoading = false;
    foList = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        foList = [];
        for (int i = 0; i < response['data'].length; i++) {
          foList.add(Story.fromJson(response['data'][i]));
        }
        foCurrentPage = response['current_page'];
        foMaxPages = response['last_page'];
        foList = foList;
        notifyListeners();
      }
    } else {
      // showToast("cannot load states");
    }
    return true;
  }

  Future<bool> foLoadMoreData() async {
    foRefreshController.footerMode!.value = LoadStatus.loading;
    int page = foCurrentPage + 1;
    if (page > foMaxPages) {
      foRefreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService()
        .getRequest(JApi.GET_STORIES + "?page=${page}&type=following");
    foRefreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<Story> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(Story.fromJson(response['data'][i]));
      }
      foCurrentPage = response['current_page'];
      foMaxPages = response['last_page'];
      foAddMore(moreList);
    }
    return true;
  }

  foAddMore(List<Story> moreList) {
    foList.addAll(moreList);
    notifyListeners();
  }

  //
  setSaved(int index, bool isSaved, {update= false}) {
    if (index > -1) {
      _list[index].isSaved = isSaved;
      if(update) if (isSaved) {
        _list[index].saveCount = _list[index].saveCount! + 1;
      } else {
        _list[index].saveCount = _list[index].saveCount! - 1;
      }
      notifyListeners();
    }
  }

  setLiked(int index, bool isSaved, {update = false}) {
    if (index > -1) {
      _list[index].isLiked = isSaved;
      if (update) if (isSaved) {
        _list[index].likeCount = _list[index].likeCount! + 1;
      } else {
        _list[index].likeCount = _list[index].likeCount! - 1;
      }
      notifyListeners();
    }
  }
  setCommentCount(String storyId, {decrease = false}) {
    int index = _list.indexWhere((element) => element.id == storyId);
    if (index > -1) {
      if(decrease){
        _list[index].commentsCount = (_list[index].commentsCount ?? 0) - 1;
      }else{
        _list[index].commentsCount = (_list[index].commentsCount ?? 0) + 1;
      }
      notifyListeners();
    }
  }

  Future<int> save(storyId) async {
    JApiService apiService = JApiService();
    isSaving = true;
    int index = getStoryIndexById(storyId);
    setSaved(index, !_list[index].isSaved);
    var response = await apiService.postRequest(
        JApi.SAVE_STORY,
        {
          "story_id": storyId.toString(),
        });
    isSaving = false;
    if (response != null) {
      try {
        if (response["saved"] == 1) {
          setSaved(index, true, update: true);
          return 1;
        }
        setSaved(index, false, update: true);
        return 2;
      } catch (e) {
        setSaved(index, !_list[index].isSaved,update: true);
        return -1;
      }
    }
    setSaved(index, !_list[index].isSaved,update: true);
    return -1;
  }

  Future<int> like(storyId) async {
    JApiService apiService = JApiService();
    isLiking = true;
    int index = getStoryIndexById(storyId);
    setLiked(index, !_list[index].isLiked);
    var response = await apiService.postRequest(
        JApi.LIKE_STORY,
        {
          "story_id": storyId.toString(),
        },
        showMessage: false);
    isLiking = false;
    if (response != null) {
      try {
        if (response["saved"] == 1) {
          setLiked(index, true, update: true);
          return 1;
        }
        setLiked(index, false, update: true);
        return 2;
      } catch (e) {
        setLiked(index, !_list[index].isLiked);
        return -1;
      }
    }
    setLiked(index, !_list[index].isLiked);
    return -1;
  }
  Future<List<Story>?> getStoryById(postId) async {
    JApiService apiService = JApiService();

    var query = "?time=${DateTime.now().millisecondsSinceEpoch}";
    if(postId.isNotEmpty){
      query += "&story_id=${postId}";
    }
    var response = await apiService.getRequest(JApi.GET_STORIES+query);
    if(response != null){
      if(response.length > 0){
        List<Story> list = [];
        for(int i = 0 ; i <  response['data'].length ; i++ ){
          list.add(Story.fromJson(response['data'][i]));
        }
        return list;
      }
    }
    return null;
  }

  int get foCurrentPage => _foCurrentPage;

  set foCurrentPage(int value) {
    _foCurrentPage = value;
    notifyListeners();
  }

  bool get foIsLoading => _foIsLoading;

  set foIsLoading(bool value) {
    _foIsLoading = value;
    notifyListeners();
  }

  List<Story> get foList => _foList;

  set foList(List<Story> value) {
    _foList = value;
    notifyListeners();
  }
}
