import 'package:checkmate/modals/story.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class TodayStoryProvider extends ChangeNotifier {

  bool _isLoading = false;
  List<Story> _list = [];
  Story? myStory = null;
  List<Story> singlePersonList = [];
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


  reset(user_id) async {
    list = [];
    isLoading = false;
    myStory = null;
    bool res = await load(user_id);
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

  Future<bool> load(user_id) async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.GET_TODAT_STORIES);
    isLoading = false;
    list = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response.length; i++) {
          list.add(Story.fromJson(response[i]));
        }
        list = list;
        singlePersonList = [];
        for(Story story in list){
          if(story.userId == user_id){
            myStory = story;
            continue;
          }
          if(singlePersonList.where((element) => element.userId == story.userId).length < 1){
            singlePersonList.add(story);
          }
        }
        list.sort((a, b) => a.userId!.compareTo(b.userId!));
        list = list;
        notifyListeners();
      }
    } else {
      // showToast("cannot load states");
    }
    return true;
  }

  setSaved(int index,bool isSaved){
    if (index > -1) {
      _list[index].isSaved = isSaved;
      if(isSaved){
        _list[index].saveCount =  _list[index].saveCount! + 1;
      }else{
        _list[index].saveCount =  _list[index].saveCount! - 1;
      }
      notifyListeners();
    }
  }
  setLiked(int index,bool isSaved){
    if (index > -1) {
      _list[index].isLiked = isSaved;
      if(isSaved){
        _list[index].likeCount =  _list[index].likeCount! + 1;
      }else{
        _list[index].likeCount =  _list[index].likeCount! - 1;
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
        },
        showMessage: true);
    isSaving = false;
    if (response != null) {
      try {
        if (response["saved"] == 1) {
          setSaved(index, true);
          return 1;
        }
        setSaved(index, false);
        return 2;
      } catch (e) {
        setSaved(index, !_list[index].isSaved);
        return -1;
      }
    }
    setSaved(index, !_list[index].isSaved);
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
        showMessage: true);
    isLiking = false;
    if (response != null) {
      try {
        if (response["saved"] == 1) {
          setLiked(index, true);
          return 1;
        }
        setLiked(index, false);
        return 2;
      } catch (e) {
        setLiked(index, !_list[index].isLiked);
        return -1;
      }
    }
    setLiked(index, !_list[index].isLiked);
    return -1;
  }
}
