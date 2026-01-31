import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  static const _notificationChannelId = "default"; // Yes.. this is a string
  static const _notificationChannelName = "Default";
  static const _notificationChannelDescription = "Default Description";

  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _isInit = false;
  static int _notificationId = 1;

  static Future<void> initNotifications() async {
    if (!_isInit) {
      tz.initializeTimeZones();
      final TimezoneInfo timeZoneName =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));

      // TODO: For some reason currently broken
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: android);

      await _notificationsPlugin.initialize(settings: initSettings);
      _isInit = true;
    }

    // Request notification permissions (Android 13+, if lower version this is auto-accepted)
    // Will do nothing if permissions already given
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required String? title, // I guess may not be nullable
    required String? body, // I guess may not be nullable
    required String? payload,
    required DateTime showTime,
  }) async {
    // TODO: For rescheduling purposes...
    // ^^ required int id, ^^ // could be item.id
    // await _notificationsPlugin.cancel(id: id);

    // Fix tests, but I do not like this part
    if (!_isInit) await initNotifications();

    await _notificationsPlugin.zonedSchedule(
      id: _notificationId++,
      title: title,
      body: body,
      payload: payload,
      scheduledDate: tz.TZDateTime.from(showTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,

          // I am pretty sure this is optional
          channelDescription: _notificationChannelDescription,

          // importance: Importance.high,   // Should be fine for now
          // priority: Priority.high,       // Within app, so not important for now
        ),
      ),

      // Read docs if want to know more, but this should be fine for our purpose
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
