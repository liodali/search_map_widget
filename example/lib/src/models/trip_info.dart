import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

enum TripType { normal, lux, group }

extension on TripType {
  static const namesTripTypes = ["normal", "lux", "group"];

  String get value => namesTripTypes[index];
}

class Trip {
  final TripType tripType;
  final double price;

  Trip({
    required this.tripType,
    required this.price,
  });
}

class TripInfo {
  late RoadInfo roadInfo;
  List<Trip> trips = [];

  TripInfo({
    required this.roadInfo,
  });

  void setRoad(RoadInfo roadInfo) {
    this.roadInfo = roadInfo;
    trips = buildTrip();
  }

  List<Trip> buildTrip() {
    double distanceKm = roadInfo.distance! / 1000;
    double duration = roadInfo.duration! / 60;
    return [
      Trip(
        tripType: TripType.normal,
        price: 20 * distanceKm * duration,
      ),
      Trip(
        tripType: TripType.lux,
        price: 35 * distanceKm * duration,
      ),
      Trip(
        tripType: TripType.group,
        price: 15 * distanceKm * duration,
      ),
    ];
  }
}
