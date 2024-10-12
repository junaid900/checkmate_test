import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';
import '../../modals/User.dart';
import '../../modals/cmpost.dart';

class SearchPostProvider extends ChangeNotifier{
  String _selectedAge = "";
  String _selectedGender = "";
  String _selectedEthnicity = "";
  String _selectedRace = "";
  String _selectedLocation = "";
  String _selectedLanguage = "";
  String _searchQuery = "";
  RefreshController refreshController = RefreshController();
  RefreshController refreshPeopleController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  int _maxPeoplePages = 0;
  int _currentPeoplePage = 0;

  int get maxPeoplePages => _maxPeoplePages;

  set maxPeoplePages(int value) {
    _maxPeoplePages = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool _isPeopleLoading = false;
  List<CMPost> _list = [];
  List<User> _peopleList = [];


  bool get isPeopleLoading => _isPeopleLoading;

  set isPeopleLoading(bool value) {
    _isPeopleLoading = value;
    notifyListeners();
  }

  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
  }

  String get selectedAge => _selectedAge;

  set selectedAge(String value) {
    _selectedAge = value;
    notifyListeners();
  }
  String get selectedGender => _selectedGender;

  set selectedGender(String value) {
    _selectedGender = value;
    notifyListeners();
  }

  String get selectedEthnicity => _selectedEthnicity;

  set selectedEthnicity(String value) {
    _selectedEthnicity = value;
    notifyListeners();
  }

  String get selectedRace => _selectedRace;

  set selectedRace(String value) {
    _selectedRace = value;
    notifyListeners();
  }

  String get selectedLocation => _selectedLocation;

  set selectedLocation(String value) {
    _selectedLocation = value;
    notifyListeners();
  }

  String get selectedLanguage => _selectedLanguage;

  set selectedLanguage(String value) {
    _selectedLanguage = value;
    notifyListeners();
  }

  // RefreshController get refreshController => _refreshController;
  //
  // set refreshController(RefreshController value) {
  //   _refreshController = value;
  //   notifyListeners();
  // }

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
  List<CMPost> get list => _list;
  set list(List<CMPost> value) {
    _list = value;
    notifyListeners();
  }

  removePost(CMPost post){
    int index = _list.indexWhere((element) => element.id == post.id);
    print(index);
    if(index > 0 && index < _list.length){
      _list.removeAt(index);
      notifyListeners();
    }
  }
  clearFilters(){
    _selectedRace = "";
    _selectedLocation = "";
    _selectedLanguage = "";
    _selectedAge = "";
    _selectedGender = "";
    _selectedEthnicity = "";
    notifyListeners();
    reset();
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
  peopleReset() async {
    currentPeoplePage = 0;
    maxPeoplePages = 0;
    refreshPeopleController.footerMode!.value = LoadStatus.idle;
    peopleList = [];
    isPeopleLoading = false;
    bool res2 = await loadPeople();

  }

  Future<bool> load() async {
    if(searchQuery.isEmpty){
      return false;
    }
    JApiService apiService = JApiService();
    isLoading = true;
    var query = "?time=${DateTime.now().millisecondsSinceEpoch}";
    if(selectedAge.isNotEmpty){
      query += "&age=${selectedAge}";
    }
    if(selectedEthnicity.isNotEmpty){
      query += "&ethnicity=${selectedEthnicity}";
    }
    if(selectedGender.isNotEmpty){
      query += "&gender=${selectedGender}";
    }
    if(selectedLanguage.isNotEmpty){
      query += "&location=${selectedLocation}";
    }
    if(selectedRace.isNotEmpty){
      query += "&race=${selectedRace}";
    }
    if(searchQuery.isNotEmpty){
      query += "&search_query=${searchQuery}";
    }
    var response = await apiService.getRequest(JApi.GET_POSTS+query);
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
  Future<bool> loadMoreData() async {
    if(searchQuery.isEmpty){
      return false;
    }
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var query = "";
    if(selectedAge.isNotEmpty){
      query += "&age=${selectedAge}";
    }
    if(selectedEthnicity.isNotEmpty){
      query += "&ethnicity=${selectedEthnicity}";
    }
    if(selectedGender.isNotEmpty){
      query += "&gender=${selectedGender}";
    }
    if(selectedLanguage.isNotEmpty){
      query += "&location=${selectedLocation}";
    }
    if(selectedRace.isNotEmpty){
      query += "&race=${selectedRace}";
    }
    if(searchQuery.isNotEmpty){
      query += "&search_query=${searchQuery}";
    }
    var response = await JApiService().getRequest(
        JApi.GET_POSTS + "?page=${page}"+query);
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

  Future<bool> loadPeople() async {
    if(searchQuery.isEmpty){
      return false;
    }
    JApiService apiService = JApiService();
    isPeopleLoading = true;
    var query = "?time=${DateTime.now().millisecondsSinceEpoch}";
    if(searchQuery.isNotEmpty){
      query += "&search_query=${searchQuery}";
    }
    var response = await apiService.getRequest(JApi.GET_USERS+query);
    isPeopleLoading = false;
    peopleList = [];
    notifyListeners();
    if(response  != null){
      if(response.length > 0){
        peopleList = [];
        for(int i = 0 ; i <  response['data'].length ; i++ ){
          peopleList.add(User.fromJson(response['data'][i]));
        }
        currentPeoplePage = response['current_page'];
        maxPeoplePages = response['last_page'];
        peopleList = peopleList;
        notifyListeners();
      }
    }else{
      // showToast("cannot load states");
    }
    return true;
  }
  Future<bool> loadMorePeopleData() async {
    if(searchQuery.isEmpty){
      return false;
    }
    refreshPeopleController.footerMode!.value = LoadStatus.loading;
    int page = currentPeoplePage + 1;
    if (page > maxPeoplePages) {
      refreshPeopleController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var query = "";
    if(searchQuery.isNotEmpty){
      query += "&search_query=${searchQuery}";
    }
    var response = await JApiService().getRequest(
        JApi.GET_USERS + "?page=${page}"+query);
    refreshPeopleController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<User> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(User.fromJson(response['data'][i]));
      }
      currentPeoplePage = response['current_page'];
      maxPeoplePages = response['last_page'];
      addMorePeople(moreList);
    }
    return true;
  }
  addMorePeople(List<User> moreList){
    peopleList.addAll(moreList);
    notifyListeners();
  }

  List<User> get peopleList => _peopleList;

  set peopleList(List<User> value) {
    _peopleList = value;
    notifyListeners();
  }

  int get currentPeoplePage => _currentPeoplePage;

  set currentPeoplePage(int value) {
    _currentPeoplePage = value;
    notifyListeners();
  }
}