import '../advanced_search_map.dart';

class AdvancedSearchController{
  late AdvancedSearchMapState _advancedSearchMapState;
}

extension PrivateExt on AdvancedSearchController {
  void init(AdvancedSearchMapState searchMapState){
    _advancedSearchMapState = searchMapState;
  }
}