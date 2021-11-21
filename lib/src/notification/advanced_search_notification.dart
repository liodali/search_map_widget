import 'package:flutter/widgets.dart';

class AdvancedSearchNotification extends Notification with ViewportNotificationMixin {
  /// Initializes fields for subclasses.
  AdvancedSearchNotification({
    required this.offset,
    required this.context,
  });

  /// The fraction to scale the child's position value.
  /// between maxChildSize and minChildSize
  /// this value is normalized between 0 and 1
  /// where 0 is minChildSize and 1 is maxChildSize
  final double offset;

  /// The build context of the widget that fired this notification.
  final BuildContext? context;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('$offset');
  }
}
