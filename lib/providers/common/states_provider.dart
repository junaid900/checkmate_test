import 'package:checkmate/api/japi.dart';
import 'package:checkmate/api/japi_service.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:flutter/cupertino.dart';
import '../../modals/states.dart';

class StatesProvider extends ChangeNotifier{
  List<States> _states = [];
  bool _isLoading = false;


  List<States> get states => _states;
  set states(List<States> value) {
    _states = value;
    notifyListeners();
  }

  Future<bool> load() async {
    JApiService apiService = JApiService();
    isLoading = true;
    var response = await apiService.getRequest(JApi.STATES);
    isLoading = false;
    states = [];
    notifyListeners();
    if(response  != null){
      if(response.length > 0){
        for(int i = 0 ; i <  response.length ; i++ ){
          _states.add(States.fromJson(response[i]));
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