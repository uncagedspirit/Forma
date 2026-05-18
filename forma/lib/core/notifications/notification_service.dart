import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Manages local notifications for habit reminders and streak alerts.
///
/// Uses flutter_local_notifications to schedule exact daily alarms
/// for habit reminders and a daily 8 PM streak-at-risk check.
class NotificationService {
  /// Creates a [NotificationService] that uses the given [repository]
  /// to evaluate streak state for the at-risk notification.
  NotificationService({required HabitRepository repository})
      : _repository = repository,
        _logger = Logger('NotificationService');

  final HabitRepository _repository;
  final Logger _logger;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'habit_reminders';
  static const String _channelName = 'Habit Reminders';
  static const String _channelDescription =
      'Daily reminders for your habits and streak alerts';

  static const int _streakAtRiskNotificationId = -1;

  /// Initializes notification channels and requests permission.
  Future<void> init() async {
    try {
      tz_data.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(initializationSettings);

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
          ),
        );

        await androidPlugin.requestNotificationsPermission();
      }

      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _logger.info('NotificationService initialized');
    } catch (e, st) {
      _logger.severe('Failed to initialize NotificationService', e, st);
    }
  }

  /// Schedules a daily reminder for a habit at its reminderTime.
  Future<void> scheduleHabitReminder(Habit habit) async {
    try {
      if (habit.reminderTime == null || habit.reminderTime!.isEmpty) {
        _logger.warning(
          'Habit ${habit.id} has no reminderTime, skipping schedule',
        );
        return;
      }

      final timeParts = habit.reminderTime!.split(':');
      if (timeParts.length != 2) {
        _logger.warning(
          'Invalid reminderTime format for habit ${habit.id}: '
          '${habit.reminderTime}',
        );
        return;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) {
        _logger.warning(
          'Invalid reminderTime format for habit ${habit.id}: '
          '${habit.reminderTime}',
        );
        return;
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime.local(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        _habitReminderId(habit.id),
        habit.name,
        habit.reminderMessage ?? 'Time to complete your habit!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logger.info(
        'Scheduled reminder for habit ${habit.id} at '
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
    } catch (e, st) {
      _logger.severe(
        'Failed to schedule reminder for habit ${habit.id}',
        e,
        st,
      );
    }
  }

  /// Cancels a habit's reminder by ID.
  Future<void> cancelHabitReminder(String habitId) async {
    try {
      await _notificationsPlugin.cancel(_habitReminderId(habitId));
      _logger.info('Cancelled reminder for habit $habitId');
    } catch (e, st) {
      _logger.severe('Failed to cancel reminder for habit $habitId', e, st);
    }
  }

  /// Schedules daily 8 PM check for streak at risk.
  ///
  /// Evaluates all habits. If any non-archived habit has not been completed
  /// today but has a streak greater than zero, a daily 8 PM notification is
  /// scheduled (or kept). Otherwise the notification is cancelled.
  Future<void> scheduleStreakAtRisk() async {
    try {
      final habits = await _repository.getAll();
      final now = DateTime.now();
      final today = DateTime.utc(now.year, now.month, now.day);

      var hasRisk = false;

      for (final habit in habits) {
        if (habit.isArchived) continue;

        final logs = await _repository.getLogsForHabit(habit.id);
        final completedToday = logs.any(
          (log) =>
              DateTime.utc(log.date.year, log.date.month, log.date.day) ==
              today,
        );

        if (!completedToday) {
          final streak = _computeStreak(logs, today);
          if (streak > 0) {
            hasRisk = true;
            break;
          }
        }
      }

      if (hasRisk) {
        final scheduledDate = _nextOccurrenceAt(20, 0);

        const androidDetails = AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        );
        const darwinDetails = DarwinNotificationDetails();
        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _notificationsPlugin.zonedSchedule(
          _streakAtRiskNotificationId,
          'Your streak is at risk!',
          'Complete your habits today to keep your streak alive.',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        _logger.info('Scheduled streak-at-risk notification for 8 PM');
      } else {
        await _notificationsPlugin.cancel(_streakAtRiskNotificationId);
        _logger.info('Cancelled streak-at-risk notification');
      }
    } catch (e, st) {
      _logger.severe('Failed to schedule streak-at-risk notification', e, st);
    }
  }

  int _habitReminderId(String habitId) => habitId.hashCode;

  tz.TZDateTime _nextOccurrenceAt(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

int _computeStreak(List<HabitLog> logs, DateTime referenceDate) {
  final normalizedReference = DateTime.utc(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  final completedDates = logs
      .map((log) => DateTime.utc(log.date.year, log.date.month, log.date.day))
      .toSet();

  var streak = 0;
  var current = normalizedReference;

  if (completedDates.contains(current)) {
    streak++;
    current = current.subtract(const Duration(days: 1));
  }

  while (completedDates.contains(current)) {
    streak++;
    current = current.subtract(const Duration(days: 1));
  }

  return streak;
}
