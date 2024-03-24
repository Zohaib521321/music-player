import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';

void showNotification(String? title, String? content) async {
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    "notifications-youtube",
    "YouTube Notifications",
    importance: Importance.min, // Set importance to min for a silent notification
    priority: Priority.low, // Set priority to low for a silent notification
    playSound: false,
    styleInformation: BigTextStyleInformation(content!),
    enableVibration: true,
    actions: [
      AndroidNotificationAction(
        'Close',
        'Close',
      ),
    ],
  );

  DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: false,
    presentBadge: false,
    presentSound: false,
  );

  NotificationDetails notiDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails
  );


  await notificationsPlugin.show(
    0,
    title,
    content,
    notiDetails,
  );
}