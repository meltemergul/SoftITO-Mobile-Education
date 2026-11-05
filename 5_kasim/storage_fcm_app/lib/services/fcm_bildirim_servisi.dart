import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Uygulama arka plandayken gelen FCM mesajlarını karşılar.
/// Bu fonksiyon üst seviyede (top-level) olmalıdır.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('Arka planda bildirim alındı: ${message.messageId}');

  // Burada uygulamanın UI durumunu güncelleyemeyiz.
  // Firebase servisleri kullanılacaksa arka plan için
  // Firebase.initializeApp() çağrılmalıdır.
}

class FcmBildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _mesajDinleyicisi;
  StreamSubscription<String>? _tokenDinleyicisi;

  bool _baslatildi = false;

  /// Bildirim servisinin başlangıç ayarlarını yapar.
  Future<void> baslat({
    required Function(RemoteMessage message) onMesajGeldi,
  }) async {
    if (_baslatildi) return;

    // 1. Bildirim izni iste.
    final izin = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Bildirim izin durumu: ${izin.authorizationStatus}');

    // 2. Android bildirim ayarları.
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // 3. Apple platformları için bildirim ayarları.
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. Platform ayarlarını birleştir.
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    // 5. Yerel bildirim servisini başlat.
    await _localPlugin.initialize(initSettings);

    // 6. Uygulama açıkken gelen mesajları dinle.
    _mesajDinleyicisi = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        debugPrint('Ön planda bildirim alındı.');

        await _yerelBildirimGoster(message);

        // Gelen mesajı ekranın bildirim listesine aktar.
        onMesajGeldi(message);
      },
      onError: (error) {
        debugPrint('Bildirim dinleme hatası: $error');
      },
    );

    // 7. FCM token yenilendiğinde yeni tokenı takip et.
    _tokenDinleyicisi = _fcm.onTokenRefresh.listen(
      (token) {
        debugPrint('Yeni FCM Token: $token');
      },
      onError: (error) {
        debugPrint('Token yenileme hatası: $error');
      },
    );

    _baslatildi = true;
  }

  /// Cihazın FCM token değerini alır.
  Future<String?> tokenAl() async {
    try {
      // Apple platformlarında önce APNs token kontrol edilir.
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final apnsToken = await _fcm.getAPNSToken();

        if (apnsToken == null) {
          debugPrint('APNs token henüz alınamadı.');
          return null;
        }

        debugPrint('APNs token başarıyla alındı.');
      }

      final token = await _fcm.getToken();

      debugPrint('FCM Token: $token');

      return token;
    } catch (e) {
      debugPrint('FCM token alma hatası: $e');
      return null;
    }
  }

  /// Belirtilen bildirim konusuna abone olur.
  Future<void> konuyaAboneOl(String konu) async {
    try {
      await _fcm.subscribeToTopic(konu);
      debugPrint('$konu konusuna abone olundu.');
    } catch (e) {
      debugPrint('Konuya abone olma hatası: $e');
      rethrow;
    }
  }

  /// Belirtilen bildirim konusundan ayrılır.
  Future<void> konudanAyril(String konu) async {
    try {
      await _fcm.unsubscribeFromTopic(konu);
      debugPrint('$konu konusundan ayrılındı.');
    } catch (e) {
      debugPrint('Konudan ayrılma hatası: $e');
      rethrow;
    }
  }

  /// Gelen FCM mesajını yerel bildirim olarak gösterir.
  Future<void> _yerelBildirimGoster(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'softito_fcm_channel',
      'SoftITO Bildirimleri',
      channelDescription: 'FCM push bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Yeni Bildirim';

    final body =
        message.notification?.body ??
        message.data['body']?.toString() ??
        'Yeni bir mesajınız var.';

    await _localPlugin.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      notificationDetails,
    );
  }

  /// Servis dinleyicilerini kapatır.
  Future<void> dispose() async {
    await _mesajDinleyicisi?.cancel();
    await _tokenDinleyicisi?.cancel();

    _baslatildi = false;
  }
}
