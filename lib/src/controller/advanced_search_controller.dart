import 'package:flutter/widgets.dart';

import '../widget/advanced_search_map.dart';

/// AdvancedSearchController
/// this class is responsible to control [AdvancedSearchMap] by opened or closed programmatically,
/// and give current status,
/// this controller is required in [AdvancedSearchMap]
class AdvancedSearchController {
  late AdvancedSearchMapState _advancedSearchMapState;

  void close() {
    if (_advancedSearchMapState.context.mounted) {
      FocusScopeNode currentFocus =
          FocusScope.of(_advancedSearchMapState.context);
      if (currentFocus.hasFocus) {
        currentFocus.unfocus();
      }
    }
    _advancedSearchMapState.setInformationSearchToMinPos();
    _advancedSearchMapState.setTopSearchToMinPos();
  }

  void open() {
    _advancedSearchMapState.setInformationSearchToMaxPos();
    _advancedSearchMapState.setTopSearchToMaxPos();
  }

  void setMaxBottomWidgetSize(double size) {
    _advancedSearchMapState.setSizeBottomCard(size);
  }

  void hideTopCard() => _advancedSearchMapState.hideTopCard();

  void showTopCard() => _advancedSearchMapState.showTopCard();
  void hideBottomCard() => _advancedSearchMapState.showTopCard();
  void showBottomCard() => _advancedSearchMapState.showTopCard();

  bool get isOpened => _advancedSearchMapState.isOpened;

  void reset() => _advancedSearchMapState.reset();
}

extension PrivateExt on AdvancedSearchController {
  void init(AdvancedSearchMapState searchMapState) {
    _advancedSearchMapState = searchMapState;
  }
}
