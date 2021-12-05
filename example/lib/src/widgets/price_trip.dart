import 'package:example/src/models/trip_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home_vm.dart';

class PriceTrip extends StatelessWidget {
  const PriceTrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<HomeVM, TripInfo?>(
      selector: (ctx, vm) => vm.tripInfo,
      shouldRebuild: (n, o) => true,
      builder: (ctx, trip, child) {
        if (trip != null) {}
        return const Center(
          child: Text(""),
        );
      },
    );
  }
}
