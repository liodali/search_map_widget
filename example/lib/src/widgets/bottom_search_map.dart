import 'package:example/src/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'price_trip.dart';

class BottomSearchMap extends StatefulWidget {
  const BottomSearchMap({Key? key}) : super(key: key);

  @override
  _BottomSearchMapState createState() => _BottomSearchMapState();
}

class _BottomSearchMapState extends State<BottomSearchMap> {
  @override
  Widget build(BuildContext context) {
    return Selector<HomeVM, int>(
      selector: (ctx, vm) => vm.currentPage,
      shouldRebuild: (nP, oP) => nP != oP,
      builder: (ctx, index, child) {
        return IndexedStack(
          index: index,
          children: [
            ListView.builder(
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
            const PriceTrip(),
          ],
        );
      },
    );
  }
}
