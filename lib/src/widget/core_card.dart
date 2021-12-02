import 'package:flutter/material.dart';

class CoreCard extends StatelessWidget {
  final Color backgroundColor;
  final double elevation;
  final double radius;
  final bool isScrollable;
  final Widget child;
  final ScrollController scrollController;

  const CoreCard({
    Key? key,
    required this.backgroundColor,
    required this.radius,
    required this.isScrollable,
    required this.child,
    required this.scrollController,
    required this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: elevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
      ),
      child: SizedBox(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior(),
          child: SingleChildScrollView(
            physics: isScrollable ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
            controller: scrollController,
            child: child,
          ),
        ),
      ),
    );
  }
}
