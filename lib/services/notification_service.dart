import 'package:flutter/foundation.dart' show kIsWeb;
// detect whether the app is running on the web
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// the local notifications plugin
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
// scheduled notifications need timezone aware dates

class NotificationService {
// additional feature: local notifications
// schedules a reminder 15 minutes before each booked session
//
// notifications only exist on mobile - every method quietly does nothing
// on web (kIsWeb check) so the web build still runs without errors

  NotificationService._();
  // private constructor so no one else can create instances

  static final NotificationService instance = NotificationService._();
  // one shared instance for the whole app (singleton pattern),
  // because the underlying plugin must only be initialised once

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  // true once init() has finished, so we never schedule before setup

  // sets up the plugin - called once in main() before the app starts
  Future<void> init() async {
    if (kIsWeb) return;
    // no local notifications on web

    tz_data.initializeTimeZones();
    // load the timezone database
    tz.setLocalLocation(tz.getLocation('Asia/Singapore'));
    // the app is for TP students so Singapore time is always correct

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // use the app icon as the notification icon
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: initSettings);

    // Android 13+ needs the user to allow notifications (a system popup)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _ready = true;
  }

  // every notification needs a number id - turn the firestore document id
  // into a stable positive number so the same session always maps to the
  // same notification (lets us replace or cancel it later)
  int _idFor(String sessionId) => sessionId.hashCode & 0x7fffffff;

  // schedules the reminder 15 minutes before the session starts
  // calling it again for the same session replaces the old reminder
  // (used when rescheduling)
  Future<void> scheduleSessionReminder({
    required String sessionId,
    required String title,
    required String mentorName,
    required DateTime sessionTime,
  }) async {
    if (kIsWeb || !_ready) return;
    // web, or init failed - skip quietly

    final reminderTime = sessionTime.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;
    // the reminder moment already passed, nothing to schedule

    await _plugin.zonedSchedule(
      id: _idFor(sessionId),
      title: 'Upcoming session: $title',
      body: 'Your session with $mentorName starts in 15 minutes!',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      // convert to a timezone aware date as the plugin requires
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_reminders',
          'Session Reminders',
          channelDescription: 'Reminders before booked mentoring sessions',
          importance: Importance.high,
          priority: Priority.high,
          // high importance = pops up on screen with sound
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // inexact = fires around the right time without needing the special
      // exact-alarm permission from Android 12+
    );
  }

  // removes the reminder for a session (used when cancelling)
  Future<void> cancelSessionReminder(String sessionId) async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancel(id: _idFor(sessionId));
  }

  // fires a notification immediately - used to demo the feature live
  // without waiting for a real session to come up
  Future<void> showTestNotification() async {
    if (kIsWeb || !_ready) return;
    await _plugin.show(
      id: 0,
      title: 'TP Mentorship',
      body:
          'Notifications are working! Session reminders will look like this.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_reminders',
          'Session Reminders',
          channelDescription: 'Reminders before booked mentoring sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
