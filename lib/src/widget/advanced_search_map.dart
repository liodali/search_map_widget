import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';

import '../common/utils.dart';
import '../controller/advanced_search_controller.dart';
import '../notification/advanced_search_notification.dart';

class AdvancedSearchMap extends StatefulWidget {
  final Widget backgroundWidget;
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
  final AdvancedSearchController controller;

  const AdvancedSearchMap({
    Key? key,
    required this.controller,
    required this.backgroundWidget,
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

class AdvancedSearchMapState extends State<AdvancedSearchMap>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<AdvancedSearchMap> {
  final double positionTopSearch = 128.0;
  final double positionInformationSearch = 450.0;
  late ValueNotifier<bool> isDown;
  late ValueNotifier<double> lastY;
  late ValueNotifier<double> diffY;
  late ValueNotifier<DIRECTION> directionNotifier;
  ValueNotifier<double>? topSearchPosition;
  ValueNotifier<double>? informationPositionSearch;
  ValueNotifier<double> normalizedScrolling = ValueNotifier(0);
  GlobalKey topKeyWidget = GlobalKey();
  late ScrollController _scrollController;

  var freezeScrollNotifier = ValueNotifier(false);

  double get maxThresholdHeight => _maxHeight - (_maxHeight * _maxThreshold);

  double get minThresholdHeight => _maxHeight - (_maxHeight * _minThreshold);

  double get maxTopThresholdHeight => (_maxHeight / _transformThreshold);

  double get _maxHeight => MediaQuery.of(context).size.height;

  double get _transformThreshold => (1 - _maxThreshold) * 10;

  double get _alphaThreshold => _transformThreshold > 2 ? 0.0 : 3 - _transformThreshold;

  double _maxThreshold = 0.85;
  double _minThreshold = 0.45;
  late double minTopThresholdHeight = -(_maxHeight / _transformThreshold);

  @override
  void initState() {
    super.initState();
    widget.controller.init(this);
    _scrollController = ScrollController();
    diffY = ValueNotifier(0.0);
    lastY = ValueNotifier(0.0);
    isDown = ValueNotifier(false);
    directionNotifier = ValueNotifier(DIRECTION.idle);
    _maxThreshold = widget.maxBottomSearchSize;
    _minThreshold = widget.minBottomSearchSize;
  }

  @override
  void dispose() {
    informationPositionSearch!.removeListener(dispatchAdvSearchNotif);
    super.dispose();
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
      body: NotificationListener<OverscrollNotification>(
        onNotification: (overScrollNotification) {
          print("overscroll : ${overScrollNotification.overscroll}");
          return true;
        },
        child: Stack(
          children: [
            Positioned(
              top: 0.0,
              left: 0,
              right: 0,
              bottom: _minThreshold * _maxHeight - 56,
              child: widget.backgroundWidget,
            ),
            ValueListenableBuilder<double>(
              valueListenable: informationPositionSearch!,
              builder: (ctx, value, child) {
                return AnimatedPositioned(
                  top: value,
                  left: 0,
                  right: 0,
                  bottom: -5,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: freezeScrollNotifier,
                    builder: (ctx, freeze, child) {
                      return AbsorbPointer(
                        absorbing: freeze,
                        child: child!,
                      );
                    },
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
                              print("diff up:$diff}");
                              directionNotifier.value = DIRECTION.up;
                              if (informationPositionSearch!.value > maxThresholdHeight) {
                                informationPositionSearch!.value -= diff;
                                topSearchPosition!.value += diff;
                                switch (topSearchPosition!.value + diff < 0) {
                                  case true:
                                    var topDiff = diff;
                                    if (topDiff > 6) {
                                      topDiff -= topDiff/2;
                                    }
                                    topSearchPosition!.value += topDiff;
                                    break;
                                  default:
                                    topSearchPosition!.value = 0;
                                }
                              }
                            }
                            if (lastY.value < y) {
                              diff = y - lastY.value;
                              print("diff down:$diff}");
                              directionNotifier.value = DIRECTION.down;
                              if (informationPositionSearch!.value <= minThresholdHeight) {
                                informationPositionSearch!.value += diff;
                                var topDiff = diff;
                                if (diff > 6) {
                                  topDiff += 3.0;
                                }
                                topSearchPosition!.value -= topDiff;
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
                                vP.toInt() >= minThresholdHeight.toInt() &&
                                _scrollController.offset >
                                    (_scrollController.position.minScrollExtent - 100)) {
                              _scrollController.jumpTo(_scrollController.offset - drag.delta.dy);
                            }
                          }
                        }
                      },
                      onVerticalDragEnd: (drag) {
                        dragEnd();
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
                          key: topKeyWidget,
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
      ),
    );
  }

  double _normalizeInformationPositionSearch() {
    var normalized = ((informationPositionSearch!.value - minThresholdHeight) /
            (maxThresholdHeight - minThresholdHeight))
        .abs();
    if (normalized > 1.0) {
      return 1.0;
    }

    return normalized;
  }

  void dragEnd() {
    var thresholdHeight = _maxHeight * 0.60;
    final currentPosition = informationPositionSearch!.value;
    if (directionNotifier.value == DIRECTION.up) {
      if (currentPosition - diffY.value <= thresholdHeight) {
        setInformationSearchToMaxPos();
        setTopSearchToMaxPos();
      } else {
        setInformationSearchToMinPos();
        setTopSearchToMinPos();
      }
    }
    if (directionNotifier.value == DIRECTION.down) {
      thresholdHeight = _maxHeight * 0.60;
      if (currentPosition + diffY.value <= thresholdHeight) {
        setInformationSearchToMinPos();
        setTopSearchToMinPos();
      } else {
        setInformationSearchToMaxPos();
        setTopSearchToMaxPos();
      }
    }
    isDown.value = false;
  }

  void setInformationSearchToMinPos() {
    informationPositionSearch!.value = minThresholdHeight;
  }

  void setInformationSearchToMaxPos() {
    informationPositionSearch!.value = maxThresholdHeight;
  }

  void setTopSearchToMaxPos() {
    topSearchPosition!.value = 0;
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
    informationPositionSearch!.addListener(dispatchAdvSearchNotif);
  }

  void dispatchAdvSearchNotif() {
    normalizedScrolling.value = _normalizeInformationPositionSearch();
    AdvancedSearchNotification(
      offset: normalizedScrolling.value,
      context: context,
    ).dispatch(context);
  }

  bool isOpened() {
    return topSearchPosition!.value == 0;
  }

  void freezeScrollToMinSize() {
    setTopSearchToMinPos();
    setInformationSearchToMinPos();
    freezeScrollNotifier.value = true;
  }

  void freeScroll() {
    freezeScrollNotifier.value = false;
  }
}
