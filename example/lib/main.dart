import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:map_search_widget/map_search_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AdvancedSearchController controller = AdvancedSearchController();
  MapController mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(
      latitude: 47.4358055,
      longitude: 8.4737324,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return NotificationListener<AdvancedSearchNotification>(
      onNotification: (notification) {
        //print(notification.offset);
        return true;
      },
      child: AdvancedSearchMap(
        controller: controller,
        // backgroundWidget: const Center(
        //   child: Text("map"),
        // ),
        backgroundWidget: OSMFlutter(
          controller: mapController,
          trackMyPosition: false,
          initZoom: 12,
          minZoomLevel: 8,
          maxZoomLevel: 14,
          stepZoom: 1.0,
          showDefaultInfoWindow: false,
          showZoomController: false,
        ),
        bottomSearchInformationWidget: ListView.builder(
          shrinkWrap: true,
          itemExtent: 50,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return ListTile(
              title: Text("item $index"),
            );
          },
          itemCount: 20,
        ),
        topSearchInformationWidget: TopSearchMap(
          searchController: controller,
        ),
        bottomElevation: 8.0,
        bottomSearchRadius: 24.0,
        maxBottomSearchSize: 0.80,
      ),
    );
  }
}

class TopSearchMap extends StatefulWidget {
  final AdvancedSearchController searchController;

  const TopSearchMap({
    Key? key,
    required this.searchController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateTopSearchMap();
}

class _StateTopSearchMap extends State<TopSearchMap> {
  final ValueNotifier<bool> showApplyBt = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: TextButton(
            onPressed: () {
              widget.searchController.close();
            },
            child: const Icon(Icons.close),
          ),
          title: const Text("Search"),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: showApplyBt,
              builder: (ctx, isVisible, child) {
                if(isVisible){
                  return child!;
                }
                return const SizedBox.shrink();
              },
              child: IconButton(
                onPressed: () {
                  widget.searchController.freezeScrollToMinSize();
                },
                icon: const Icon(
                  Icons.done,
                  color: Colors.green,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 16,
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 96,
              ),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      onChanged: (destination) {},
                      decoration: const InputDecoration(
                        label: Text("start"),
                      ),
                    ),
                    TextField(
                      onChanged: (destination) {
                        showApplyBt.value = destination.isNotEmpty && destination.length > 4;
                      },
                      decoration: const InputDecoration(
                        label: Text("destination"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
