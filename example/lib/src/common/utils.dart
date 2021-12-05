import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:osm_nominatim/osm_nominatim.dart';


Address fromPlaceToAddress(Place place) {
  return Address(
    name: place.displayName,
  );
}
