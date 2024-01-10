import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:map_search_widget/src/common/utils.dart';
import 'package:map_search_widget/src/controller/advanced_search_controller.dart';
import 'package:map_search_widget/src/widget/core_card.dart';

class AdvancedSearchMap extends StatefulWidget {
  final Widget backgroundWidget;
  final Widget bottomSearchInformationWidget;
  final Widget topSearchInformationWidget;
  final double maxBottomSearchSize;
  final double minBottomSearchSize;
  final double closeBottomSearchSize;
  final double bottomElevation;
  final double topElevation;
  final double bottomSearchRadius;
  final double topSearchRadius;
  final Color backgroundColorBottomSearchInformation;
  final Color backgroundColorTopSearchInformation;
  final AdvancedSearchController controller;

  const AdvancedSearchMap({
    Key? key,
    required this.controller,
    required this.backgroundWidget,
    required this.bottomSearchInformationWidget,
    required this.topSearchInformationWidget,
    this.maxBottomSearchSize = 0.75,
    this.minBottomSearchSize = 0.35,
    this.closeBottomSearchSize = 0.25,
    this.bottomElevation = 2.0,
    this.topElevation = 2.0,
    this.bottomSearchRadius = 3.0,
    this.topSearchRadius = 3.0,
    this.backgroundColorBottomSearchInformation = Colors.white,
    this.backgroundColorTopSearchInformation = Colors.white,
  })  : assert(maxBottomSearchSize > 0.65),
        //assert(minBottomSearchSize >= 0.35 && minBottomSearchSize < 0.60),
        assert(bottomSearchRadius > 0.0),
        assert(topSearchRadius > 0.0),
        super(key: key);

  @override
  AdvancedSearchMapState createState() => AdvancedSearchMapState();
}

class AdvancedSearchMapState extends State<AdvancedSearchMap>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<AdvancedSearchMap> {
  final double positionTopSearch = 156.0;
  final double positionInformationSearch = 450.0;
  late ValueNotifier<bool> isDown;
  late ValueNotifier<double> lastY;
  late ValueNotifier<double> diffY;
  late ValueNotifier<DIRECTION> directionNotifier;
  late ValueNotifier<double>? topSearchPosition =
      ValueNotifier(minTopThresholdHeight);
  ValueNotifier<double> normalizedScrolling = ValueNotifier(0);
  GlobalKey topKeyWidget = GlobalKey();

  var freezeScrollNotifier = ValueNotifier(false);
  var hideTopCardNotifier = ValueNotifier(false);

  double get maxThresholdHeight => _maxHeight - (_maxHeight * _maxThreshold);

  double get minThresholdHeight => _maxHeight - (_maxHeight * _minThreshold);
  double get minThresholdHeightToClose =>
      _maxHeight - (_maxHeight * _minThresholdToClose);

  double get maxTopThresholdHeight => (_maxHeight / _transformThreshold);

  double get _maxHeight => MediaQuery.of(context).size.height;

  double get _transformThreshold => (1 - _maxThreshold) * 10;

  double get _alphaThreshold =>
      _transformThreshold > 2 ? 0.0 : 3 - _transformThreshold;

  double _maxThreshold = 0.85;
  double _minThreshold = 0.45;
  late final _initMaxThreshold = widget.maxBottomSearchSize;
  double _minThresholdToClose = 0.25;

  late double minTopThresholdHeight = -(_maxHeight / _transformThreshold);
  late final draggableController = DraggableScrollableController();
  late double currentHeight = _minThreshold;
  bool stickToTop = false;
  @override
  void initState() {
    super.initState();
    widget.controller.init(this);
    diffY = ValueNotifier(0.0);
    lastY = ValueNotifier(0.0);
    isDown = ValueNotifier(false);
    _maxThreshold = widget.maxBottomSearchSize;
    _minThreshold = widget.minBottomSearchSize;
    _minThresholdToClose = widget.closeBottomSearchSize;
    currentHeight = _minThreshold;
    draggableController.addListener(draggableListener);
  }

  void draggableListener() {
    final fractionalSize =
        draggableController.pixelsToSize(draggableController.pixels);
    if (!stickToTop) {
      if (fractionalSize >= _minThreshold &&
          fractionalSize > currentHeight &&
          (topSearchPosition != null && topSearchPosition!.value + 25 < 0)) {
        topSearchPosition?.value += 25;
      } else if (fractionalSize >= _minThreshold &&
          fractionalSize < currentHeight) {
        topSearchPosition?.value -= 25;
      }
      if (fractionalSize == _maxThreshold) {
        topSearchPosition?.value = 0;
      }
      if (fractionalSize == _minThreshold) {
        topSearchPosition?.value = -topKeyWidget.currentContext!.size!.height;
      }
      debugPrint("fraction : $fractionalSize, current $currentHeight");
      if ((topSearchPosition != null && topSearchPosition!.value == 0)) {
        setState(() {
          _minThreshold = _maxThreshold;
          stickToTop = true;
        });
      }
      currentHeight = fractionalSize;
    }
  }

  @override
  void dispose() {
    draggableController.removeListener(draggableListener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0.0,
          left: 0,
          right: 0,
          bottom: widget.minBottomSearchSize * _maxHeight - 56,
          child: widget.backgroundWidget,
        ),
        Positioned.fill(
          child: PointerInterceptor(
            child: DraggableScrollableSheet(
              minChildSize: _minThreshold,
              initialChildSize: _minThreshold,
              maxChildSize: _maxThreshold,
              controller: draggableController,
              builder: (context, scrollController) {
                return CoreCard(
                  backgroundColor:
                      widget.backgroundColorBottomSearchInformation,
                  elevation: widget.bottomElevation,
                  isScrollable: true,
                  scrollController: scrollController,
                  child: widget.bottomSearchInformationWidget,
                  radius: widget.bottomSearchRadius,
                );
              },
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: hideTopCardNotifier,
          builder: (ctx, hiding, child) {
            if (hiding) {
              return const SizedBox.shrink();
            }
            return child!;
          },
          child: ValueListenableBuilder<double>(
            valueListenable: topSearchPosition!,
            builder: (ctx, value, child) {
              return AnimatedPositioned(
                top: value,
                left: 0,
                right: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (_maxHeight - _maxHeight * _maxThreshold) + 24,
                  ),
                  child: LayoutBuilder(
                    builder: (ctx, constraint) {
                      return Card(
                        key: topKeyWidget,
                        color: widget.backgroundColorTopSearchInformation,
                        elevation: widget.topElevation,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(widget.topSearchRadius),
                            bottomRight:
                                Radius.circular(widget.topSearchRadius),
                          ),
                        ),
                        child: Container(
                          constraints: constraint,
                          child: widget.topSearchInformationWidget,
                        ),
                      );
                    },
                  ),
                ),
                duration: const Duration(
                  milliseconds: 100,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void setInformationSearchToMinPos() {
    setState(() {
      _minThreshold = widget.minBottomSearchSize;
      stickToTop = false;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      draggableController.animateTo(
        _minThreshold,
        duration: const Duration(milliseconds: 350),
        curve: Curves.linear,
      );
    });
  }

  void setInformationSearchToMaxPos() {}

  void setTopSearchToMaxPos() {
    if (!hideTopCardNotifier.value) topSearchPosition!.value = 0;
  }

  void setTopSearchToMinPos() {
    topSearchPosition!.value = minTopThresholdHeight;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (topKeyWidget.currentContext?.size?.height != null) {
      minTopThresholdHeight = -topKeyWidget.currentContext!.size!.height;
      topSearchPosition!.value = -topKeyWidget.currentContext!.size!.height;
    }
  }

  bool get isOpened => topSearchPosition!.value == 0;

  void reset() {
    topSearchPosition!.value = -topKeyWidget.currentContext!.size!.height;
    setInformationSearchToMinPos();
    setTopSearchToMinPos();
    setState(() {
      _maxThreshold = _initMaxThreshold;
    });
  }

  void setSizeBottomCard(double size) {
    assert(size >= widget.minBottomSearchSize &&
        size <= widget.maxBottomSearchSize);

    Future.microtask(() async {
      await draggableController.animateTo(
        _maxThreshold,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      setState(() {
        _maxThreshold = size;
        _minThreshold = size;
      });
    });
  }

  void hideTopCard() {
    setTopSearchToMinPos();
    hideTopCardNotifier.value = true;
  }

  void showTopCard() {
    hideTopCardNotifier.value = false;
  }

  void hideBottomCard() {
    setState(() {
      _minThreshold = 0;
    });
    (() => draggableController.animateTo(
          0,
          duration: Duration.zero,
          curve: Curves.linear,
        )).delayed(Duration.zero);
  }

  void showBottomCard() {
    setState(() {
      _minThreshold = widget.minBottomSearchSize;
    });
  }
}
