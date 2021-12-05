import 'package:example/src/models/trip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class HomeVM extends ChangeNotifier {
  int _indexPageBottom = 0;
  final int _maxPages;

  int get currentPage => _indexPageBottom;

  TripInfo? tripInfo;
  Address? _userAdr;
  Address? _destAdr;

  Address? get currentUserAddress => _userAdr;

  Address? get destinationAddress => _destAdr;

  HomeVM({
    required int maximumBottomPages,
  }) : _maxPages = maximumBottomPages;

  void setUserAdr(Address address) {
    _userAdr = address;
    notifyListeners();
  }

  void changeDestAdr(Address address) {
    _destAdr = address;
    notifyListeners();
  }

  void setTrip(RoadInfo roadInfo) {
    switch (tripInfo == null) {
      case true:
        tripInfo = TripInfo(roadInfo: roadInfo);
        tripInfo!.trips = tripInfo!.buildTrip();
        break;
      default:
        tripInfo!.setRoad(roadInfo);
    }
    notifyListeners();
  }

  void jumpTo(int index) {
    if (index >= 0 && index < _maxPages) {
      _indexPageBottom = index;
      notifyListeners();
    }
  }

  void toNextPage() {
    if (_indexPageBottom < _maxPages - 1) {
      _indexPageBottom++;
      notifyListeners();
    }
  }

  void backPage() {
    if (_indexPageBottom > 0) {
      _indexPageBottom--;
      notifyListeners();
    }
  }
}
