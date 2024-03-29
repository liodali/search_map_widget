import 'package:example/src/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:map_search_widget/map_search_widget.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:provider/provider.dart';

import 'src/common/utils.dart';
import 'src/widgets/bottom_search_map.dart';
import 'src/widgets/top_search_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(
          create: (ctx) => HomeVM(
            maximumBottomPages: 2,
          ),
        ),
      ],
      child: GestureDetector(
        onTap: () {},
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with OSMMixinObserver {
  AdvancedSearchController controller = AdvancedSearchController();
  late MapController mapController;
  @override
  void initState() {
    mapController = MapController(
      initMapWithUserPosition: const UserTrackingOption(),
    );
    super.initState();
    mapController.addObserver(this);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<AdvancedSearchNotification>(
      onNotification: (notification) {
        //print(notification.offset);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AdvancedSearchMap(
          controller: controller,
          backgroundWidget: OSMFlutter(
            controller: mapController,
            osmOption: OSMOption(
              userLocationMarker: UserLocationMaker(
                personMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.gps_fixed,
                    color: Colors.green,
                  ),
                ),
                directionArrowMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.gps_fixed,
                    color: Colors.green,
                  ),
                ),
              ),
              zoomOption: const ZoomOption(
                initZoom: 12,
                minZoomLevel: 8,
                maxZoomLevel: 14,
                stepZoom: 1.0,
              ),
              showDefaultInfoWindow: false,
              showZoomController: false,
            ),
          ),
          bottomSearchInformationWidget: const BottomSearchMap(),
          topSearchInformationWidget: TopSearchMap(
            searchController: controller,
          ),
          bottomElevation: 8.0,
          bottomSearchRadius: 12.0,
          maxBottomSearchSize: 0.80,
          minBottomSearchSize: 0.05,
        ),
      ),
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      final homeVM = context.read<HomeVM>();
      await mapController.currentLocation();
      await mapController.enableTracking();
      final myLocation = await mapController.myLocation();
      final reverseSearchResult = await Nominatim.reverseSearch(
        lat: myLocation.latitude,
        lon: myLocation.longitude,
        addressDetails: true,
        nameDetails: true,
      );
      homeVM.setUserAdr(fromPlaceToAddress(reverseSearchResult));
    }
  }
}
