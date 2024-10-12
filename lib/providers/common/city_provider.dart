import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:flutter/cupertino.dart';
import '../../modals/city.dart';
import '../../modals/states.dart';

class CityProvider extends ChangeNotifier{
  List<City> _list = [];
  bool _isLoading = false;


  List<City> get list => _list;
  set list(List<City> value) {
    _list = value;
    notifyListeners();
  }

  Future<bool> loadStateCities(stateId) async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.CITIES+"/${stateId}");
    isLoading = false;
    list = [];
    if(response  != null){
      if(response.length > 0){
        for(int i = 0 ; i <  response.length ; i++ ){
          _list.add(City.fromJson(response[i]));
        }
        notifyListeners();
      }
    }else{
      showToast("cannot load states");
    }
    return true;
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}