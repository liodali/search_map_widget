import 'dart:async';

enum DIRECTION {
  up,
  down,
  idle,
}

extension FnExt on FutureOr Function() {
  void delayed(Duration duration) {
    final fn = this;
    Future.delayed(duration, () {
      Future.microtask(fn);
    });
  }
}
