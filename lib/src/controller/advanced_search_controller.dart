import '../advanced_search_map.dart';

class AdvancedSearchController {
  late AdvancedSearchMapState _advancedSearchMapState;

  void close() {
    _advancedSearchMapState.setInformationSearchToMinPos();
    _advancedSearchMapState.setTopSearchToMinPos();
  }

  void open() {
    _advancedSearchMapState.setInformationSearchToMaxPos();
    _advancedSearchMapState.setTopSearchToMaxPos();
  }
}

extension PrivateExt on AdvancedSearchController {
  void init(AdvancedSearchMapState searchMapState) {
    _advancedSearchMapState = searchMapState;
  }
}
