import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';
import '../../modals/cmpost.dart';

class HomePostProvider extends ChangeNotifier {
  String _selectedAge = "";
  String _selectedGender = "";
  String _selectedEthnicity = "";
  String _selectedRace = "";
  String _selectedLocation = "";
  String _selectedLanguage = "";
  String _searchQuery = "";
  RefreshController refreshController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  String type = 'For You';
  bool _isLoading = false;
  List<CMPost> _list = [];

  RefreshController folRefreshController = RefreshController();
  int _folingMaxPages = 0;
  int _folCurrentPage = 0;
  bool _folUsLoading = false;
  List<CMPost> _folList = [];

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

  removePost(CMPost post) {
    int index = _list.indexWhere((element) => element.id == post.id);
    print(index);
    if (index > 0 && index < _list.length) {
      _list.removeAt(index);
      notifyListeners();
    }
  }

  clearFilters() {
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

  folReset() async {
    folCurrentPage = 0;
    folingMaxPages = 0;
    folList = [];
    folUsLoading = false;
    folRefreshController.footerMode!.value = LoadStatus.idle;
    bool res = await folLoad();
    return res;
  }

  Future<bool> load() async {
    JApiService apiService = JApiService();
    isLoading = true;
    var query = "?time=${DateTime.now().millisecondsSinceEpoch}";
    if (selectedAge.isNotEmpty) {
      query += "&age=${selectedAge}";
    }
    if (selectedEthnicity.isNotEmpty) {
      query += "&ethnicity=${selectedEthnicity}";
    }
    if (selectedGender.isNotEmpty) {
      query += "&gender=${selectedGender}";
    }
    if (selectedLanguage.isNotEmpty) {
      query += "&location=${selectedLocation}";
    }
    if (selectedRace.isNotEmpty) {
      query += "&race=${selectedRace}";
    }
    if (searchQuery.isNotEmpty) {
      query += "&search_query=${searchQuery}";
    }
    var response = await apiService.getRequest(JApi.GET_POSTS + query);
    isLoading = false;
    list = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response['data'].length; i++) {
          list.add(CMPost.fromJson(response['data'][i]));
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

  Future<bool> loadMoreData() async {
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var query = "";
    if (selectedAge.isNotEmpty) {
      query += "&age=${selectedAge}";
    }
    if (selectedEthnicity.isNotEmpty) {
      query += "&ethnicity=${selectedEthnicity}";
    }
    if (selectedGender.isNotEmpty) {
      query += "&gender=${selectedGender}";
    }
    if (selectedLanguage.isNotEmpty) {
      query += "&location=${selectedLocation}";
    }
    if (selectedRace.isNotEmpty) {
      query += "&race=${selectedRace}";
    }
    if (searchQuery.isNotEmpty) {
      query += "&search_query=${searchQuery}";
    }
    var response = await JApiService()
        .getRequest(JApi.GET_POSTS + "?page=${page}" + query);
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

  addMore(List<CMPost> moreList) {
    list.addAll(moreList);
    notifyListeners();
  }
  // FOLLOWING


  Future<bool> folLoad() async {
    JApiService apiService = JApiService();
    folUsLoading = true;
    var query = "?time=${DateTime.now().millisecondsSinceEpoch}&type=following";
    if (selectedAge.isNotEmpty) {
      query += "&age=${selectedAge}";
    }
    if (selectedEthnicity.isNotEmpty) {
      query += "&ethnicity=${selectedEthnicity}";
    }
    if (selectedGender.isNotEmpty) {
      query += "&gender=${selectedGender}";
    }
    if (selectedLanguage.isNotEmpty) {
      query += "&location=${selectedLocation}";
    }
    if (selectedRace.isNotEmpty) {
      query += "&race=${selectedRace}";
    }
    if (searchQuery.isNotEmpty) {
      query += "&search_query=${searchQuery}";
    }
    var response = await apiService.getRequest(JApi.GET_POSTS + query);
    folUsLoading = false;
    folList = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        folList = [];
        for (int i = 0; i < response['data'].length; i++) {
          folList.add(CMPost.fromJson(response['data'][i]));
        }
        folCurrentPage = response['current_page'];
        folingMaxPages = response['last_page'];
        folList = folList;
        notifyListeners();
      }
    } else {
      // showToast("cannot load states");
    }
    return true;
  }

  Future<bool> loadFolMoreData() async {
    folRefreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      folRefreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var query = "";
    if (selectedAge.isNotEmpty) {
      query += "&age=${selectedAge}";
    }
    if (selectedEthnicity.isNotEmpty) {
      query += "&ethnicity=${selectedEthnicity}";
    }
    if (selectedGender.isNotEmpty) {
      query += "&gender=${selectedGender}";
    }
    if (selectedLanguage.isNotEmpty) {
      query += "&location=${selectedLocation}";
    }
    if (selectedRace.isNotEmpty) {
      query += "&race=${selectedRace}";
    }
    if (searchQuery.isNotEmpty) {
      query += "&search_query=${searchQuery}";
    }
    var response = await JApiService()
        .getRequest(JApi.GET_POSTS + "?page=${page}&type=following" + query);
    folRefreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<CMPost> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(CMPost.fromJson(response['data'][i]));
      }
      folCurrentPage = response['current_page'];
      folingMaxPages = response['last_page'];
      addFolMore(moreList);
    }
    return true;
  }

  addFolMore(List<CMPost> moreList) {
    folList.addAll(moreList);
    notifyListeners();
  }

  int get folCurrentPage => _folCurrentPage;

  set folCurrentPage(int value) {
    _folCurrentPage = value;
    notifyListeners();
  }

  int get folingMaxPages => _folingMaxPages;

  set folingMaxPages(int value) {
    _folingMaxPages = value;
  }

  bool get folUsLoading => _folUsLoading;

  set folUsLoading(bool value) {
    _folUsLoading = value;
    notifyListeners();
  }

  List<CMPost> get folList => _folList;

  set folList(List<CMPost> value) {
    _folList = value;
    notifyListeners();
  }
}
