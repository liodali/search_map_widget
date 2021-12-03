import '../widget/advanced_search_map.dart';

/// AdvancedSearchController
/// this class is responsible to control [AdvancedSearchMap] by opened or closed programmatically,
/// and give current status,
/// this controller is required in [AdvancedSearchMap]
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

  void freezeScrollToMinSize() => _advancedSearchMapState.freezeScrollToMinSize();

  void freeScroll() => _advancedSearchMapState.freeScroll();

  void hideTopCard() => _advancedSearchMapState.hideTopCard();
  void showTopCard() => _advancedSearchMapState.showTopCard();

  bool get isOpened => _advancedSearchMapState.isOpened();
}

extension PrivateExt on AdvancedSearchController {
  void init(AdvancedSearchMapState searchMapState) {
    _advancedSearchMapState = searchMapState;
  }
}
