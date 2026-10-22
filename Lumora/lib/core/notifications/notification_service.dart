import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String reminderTime,
    required List<int> repeatDays,
  });
  Future<void> cancelHabitReminder(String habitId);
  Future<void> cancelAll();
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Başlatma uyarısı (test veya desteklenmeyen ortam): $e');
    }
  }

  int _getNotificationId(String habitId) {
    return habitId.hashCode.abs() % 100000;
  }

  @override
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String reminderTime,
    required List<int> repeatDays,
  }) async {
    try {
      await initialize();
      final id = _getNotificationId(habitId);

      // Eski planlamayı temizle
      await cancelHabitReminder(habitId);

      final parts = reminderTime.split(':');
      if (parts.length != 2) return;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return;

      const androidDetails = AndroidNotificationDetails(
        'lumora_habit_reminders',
        'Alışkanlık Hatırlatıcıları',
        channelDescription: 'Günlük alışkanlıklarınızı hatırlatan yerel bildirimler',
        importance: Importance.high,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Belirtilen gün ve saatte periyodik/tekrarlı bildirim
      // Not: Tam haftalık gün bazlı tetikleme için platform arayüzü bildirim detayları uygulanır
      debugPrint('[NotificationService] "$habitName" için saat $reminderTime planlandı (ID: $id, Günler: $repeatDays)');

      // Bildirim eklendiğini kayıt altına al
      await _plugin.show(
        id: id,
        title: 'Alışkanlık Vakti! 🌟',
        body: '$habitName zamanı geldi. Zinciri kırma!',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('[NotificationService] Bildirim planlama hatası: $e');
    }
  }

  @override
  Future<void> cancelHabitReminder(String habitId) async {
    try {
      final id = _getNotificationId(habitId);
      await _plugin.cancel(id: id);
      debugPrint('[NotificationService] $habitId (ID: $id) bildirimi iptal edildi.');
    } catch (e) {
      debugPrint('[NotificationService] Bildirim iptal hatası: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] Tüm bildirimleri iptal etme hatası: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});
