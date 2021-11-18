import 'package:flutter/material.dart';

import 'common/utils.dart';

class AdvancedSearchMap extends StatefulWidget {
  final Widget map;
  final Widget bottomSearchInformationWidget;
  final Widget topSearchInformationWidget;
  final double maxBottomSearchSize;
  final double minBottomSearchSize;
  final double bottomElevation;
  final double topElevation;
  final double bottomSearchRadius;
  final double topSearchRadius;
  final Color backgroundColorBottomSearchInformation;
  final Color backgroundColorTopSearchInformation;

  const AdvancedSearchMap({
    Key? key,
    required this.map,
    required this.bottomSearchInformationWidget,
    required this.topSearchInformationWidget,
    this.maxBottomSearchSize = 0.75,
    this.minBottomSearchSize = 0.45,
    this.bottomElevation = 2.0,
    this.topElevation = 2.0,
    this.bottomSearchRadius = 3.0,
    this.topSearchRadius = 3.0,
    this.backgroundColorBottomSearchInformation = Colors.white,
    this.backgroundColorTopSearchInformation = Colors.white,
  })  : assert(maxBottomSearchSize > 0.65),
        assert(minBottomSearchSize >= 0.45 && minBottomSearchSize < 0.60),
        assert(bottomSearchRadius > 0.0),
        assert(topSearchRadius > 0.0),
        super(key: key);

  @override
  AdvancedSearchMapState createState() => AdvancedSearchMapState();
}

class AdvancedSearchMapState extends State<AdvancedSearchMap> with SingleTickerProviderStateMixin {
  final double positionTopSearch = 128.0;
  final double positionInformationSearch = 450.0;
  late ValueNotifier<bool> isDown;
  late ValueNotifier<double> lastY;
  late ValueNotifier<double> diffY;
  late ValueNotifier<DIRECTION> directionNotifier;
  ValueNotifier<double>? topSearchPosition;
  ValueNotifier<double>? informationPositionSearch;

  late ScrollController _scrollController;

  double get maxThresholdHeight => _maxHeight - (_maxHeight * _maxThreshold);

  double get minThresholdHeight => _maxHeight - (_maxHeight * _minThreshold);

  double get maxTopThresholdHeight => (_maxHeight / _transformThreshold);

  double get minTopThresholdHeight => -(_maxHeight / _transformThreshold);

  double get _maxHeight => MediaQuery.of(context).size.height;

  double get _transformThreshold => (1 - _maxThreshold) * 10;

  double get _alphaThreshold => _transformThreshold > 2 ? 0.0 : 3 - _transformThreshold;

  double _maxThreshold = 0.85;
  double _minThreshold = 0.45;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    diffY = ValueNotifier(0.0);
    lastY = ValueNotifier(0.0);
    isDown = ValueNotifier(false);
    directionNotifier = ValueNotifier(DIRECTION.idle);
    _maxThreshold = widget.maxBottomSearchSize;
    _minThreshold = widget.minBottomSearchSize;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    informationPositionSearch ??= ValueNotifier(minThresholdHeight);

    topSearchPosition ??= ValueNotifier(minTopThresholdHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          widget.map,
          ValueListenableBuilder<double>(
            valueListenable: informationPositionSearch!,
            builder: (ctx, value, child) {
              return AnimatedPositioned(
                top: value,
                left: 0,
                right: 0,
                bottom: -5,
                child: GestureDetector(
                  onVerticalDragStart: (drag) {
                    lastY.value = drag.globalPosition.dy;
                  },
                  onVerticalDragDown: (drag) {
                    if (drag.localPosition.dy > 0) {
                      lastY.value = drag.globalPosition.dy;
                    }
                    isDown.value = true;
                  },
                  onVerticalDragUpdate: (drag) {
                    if (isDown.value) {
                      if (drag.globalPosition.dy > 0) {
                        final y = drag.globalPosition.dy;
                        var diff = 0.0;
                        if (lastY.value > y) {
                          diff = lastY.value - y;
                          directionNotifier.value = DIRECTION.up;
                          if (informationPositionSearch!.value > maxThresholdHeight) {
                            informationPositionSearch!.value -= diff;
                            topSearchPosition!.value += diff;
                          }
                        }
                        if (lastY.value < y) {
                          diff = y - lastY.value;
                          directionNotifier.value = DIRECTION.down;
                          if (informationPositionSearch!.value <= minThresholdHeight) {
                            informationPositionSearch!.value += diff;
                            topSearchPosition!.value -= diff;
                          }
                        }
                        if (lastY.value == y) {
                          directionNotifier.value = DIRECTION.idle;
                        }
                        diffY.value = diff;
                        lastY.value = y;
                        final vP = informationPositionSearch!.value;
                        if (directionNotifier.value == DIRECTION.up &&
                            vP.toInt() <= maxThresholdHeight.toInt() &&
                            _scrollController.offset <
                                (_scrollController.position.maxScrollExtent + 100)) {
                          _scrollController.jumpTo(_scrollController.offset - drag.delta.dy);
                        }
                        if (directionNotifier.value == DIRECTION.down &&
                            informationPositionSearch!.value.toInt() ==
                                minThresholdHeight.toInt() &&
                            _scrollController.offset >
                                (_scrollController.position.minScrollExtent - 100)) {
                          _scrollController.jumpTo(_scrollController.offset - drag.delta.dy);
                        }
                      }
                    }
                  },
                  onVerticalDragEnd: (drag) {
                    var thresholdHeight = _maxHeight * 0.60;
                    final currentPosition = informationPositionSearch!.value;
                    if (directionNotifier.value == DIRECTION.up) {
                      if (currentPosition - diffY.value <= thresholdHeight) {
                        informationPositionSearch!.value = maxThresholdHeight;
                        topSearchPosition!.value = 0;
                      }
                    }
                    if (directionNotifier.value == DIRECTION.down) {
                      thresholdHeight = _maxHeight * 0.60;
                      if (currentPosition + diffY.value <= thresholdHeight) {
                        informationPositionSearch!.value = minThresholdHeight;
                        topSearchPosition!.value = minTopThresholdHeight;
                      }
                    }
                    isDown.value = false;
                  },
                  child: AbsorbPointer(
                    child: Card(
                      color: widget.backgroundColorBottomSearchInformation,
                      elevation: widget.bottomElevation,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.bottomSearchRadius),
                          topRight: Radius.circular(widget.bottomSearchRadius),
                        ),
                      ),
                      child: SizedBox(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _scrollController,
                          child: widget.bottomSearchInformationWidget,
                        ),
                      ),
                    ),
                  ),
                ),
                duration: const Duration(
                  milliseconds: 100,
                ),
              );
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: topSearchPosition!,
            builder: (ctx, value, child) {
              return AnimatedPositioned(
                top: value,
                left: 0,
                right: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _maxHeight / (_transformThreshold + _alphaThreshold),
                  ),
                  child: LayoutBuilder(
                    builder: (ctx, constraint) {
                      return Card(
                        color: widget.backgroundColorTopSearchInformation,
                        elevation: widget.topElevation,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(widget.topSearchRadius),
                            bottomRight: Radius.circular(widget.topSearchRadius),
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
        ],
      ),
    );
  }
}
