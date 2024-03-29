import 'package:flutter/material.dart';
import 'package:map_search_widget/map_search_widget.dart';

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
                if (isVisible) {
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
            right: 24,
            left: 72,
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (destination) {},
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("start"),
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                onChanged: (destination) {
                  showApplyBt.value =
                      destination.isNotEmpty && destination.length > 4;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  label: Text("destination"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
