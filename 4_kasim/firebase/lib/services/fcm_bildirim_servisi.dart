// Firebase Cloud Messaging üzerinden push bildirim işlemlerini yapabilmek için kullanılır.
import 'package:firebase_messaging/firebase_messaging.dart';

// Flutter'ın temel widget ve uygulama özelliklerini kullanabilmek için eklenir.
import 'package:flutter/widgets.dart';

// Uygulama içerisinde yerel bildirim gösterebilmek için kullanılan pakettir.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Bu fonksiyonun uygulama arka plandayken de çalışabilmesini sağlar.
// Firebase'den arka planda gelen bildirimleri karşılamak için kullanılır.
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  // Uygulama arka plandayken gelen bildirim burada yakalanır.
}

// Firebase Cloud Messaging ile ilgili işlemleri yöneten servis sınıfıdır.
class FcmBildirimServisi {
  // Firebase Messaging nesnesini oluşturur.
  // Bu nesne üzerinden bildirim izni, token ve konu aboneliği işlemleri yapılır.
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Yerel bildirimleri yönetmek ve göstermek için plugin nesnesi oluşturur.
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  // Bildirim servisinin başlangıç ayarlarını yapan metottur.
  Future<void> baslat({
    // Yeni bir bildirim geldiğinde çalıştırılacak fonksiyonu dışarıdan alır.
    required Function(RemoteMessage mesagge) onMesajGeldi,
  }) async {
    // Kullanıcıdan bildirim gönderme izni ister.
    // Bildirim, uygulama simgesi üzerindeki rozet ve ses izinlerini talep eder.
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Android cihazlar için yerel bildirim simgesini belirler.
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS cihazlar için yerel bildirim ayarlarını oluşturur.
    const iosSettings = DarwinInitializationSettings();

    // Android ve iOS ayarlarını bir araya getirir.
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Yerel bildirim eklentisini hazırlanan ayarlarla başlatır.
    await _localPlugin.initialize(initSettings);

    // Uygulama ön plandayken gelen FCM bildirimlerini dinler.
    FirebaseMessaging.onMessage.listen((message) {
      // Gelen bildirimi yerel bildirim olarak ekranda gösterir.
      _yerelBildirimGoster(message);

      // Gelen bildirim bilgisini dışarıdan gönderilen callback fonksiyonuna iletir.
      onMesajGeldi(message);
    });

    // Uygulama arka plandayken gelen bildirimleri karşılayacak fonksiyonu kaydeder.
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  }

  // Kullanıcının belirli bir bildirim konusuna abone olmasını sağlar.
  Future<void> konuyaAboneOl(String konu) async {
    // Belirtilen konuya abone olarak o konuyla ilgili bildirimleri almasını sağlar.
    await _fcm.subscribeToTopic(konu);
  }

  // Kullanıcının daha önce abone olduğu bir konudan ayrılmasını sağlar.
  Future<void> konudanAyril(String konu) async {
    // Belirtilen konunun aboneliğini iptal eder.
    await _fcm.unsubscribeFromTopic(konu);
  }

  // Gelen FCM mesajını yerel bildirim olarak gösteren yardımcı metottur.
  // Başındaki _ işareti bu metodun sadece bu dosya içerisinde kullanılmasını sağlar.
  Future<void> _yerelBildirimGoster(RemoteMessage message) async {
    // Android cihazlarda gösterilecek bildirimin özelliklerini belirler.
    const androidDetails = AndroidNotificationDetails(
      // Bildirim kanalının benzersiz kimliğidir.
      'softito_fcm_chanell_id',

      // Bildirim kanalının kullanıcıya gösterilen adıdır.
      'softito bildirimleri',

      // Bildirim kanalının ne amaçla kullanıldığını açıklar.
      channelDescription: 'FCM Push Bildirimleri',

      // Bildirimin önem seviyesini en yüksek olarak ayarlar.
      importance: Importance.max,

      // Bildirimin yüksek öncelikli olmasını sağlar.
      priority: Priority.high,
    );

    // Android ve iOS için bildirim özelliklerini bir araya getirir.
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Gelen mesajın başlık ve içerik bilgilerini kullanarak
    // cihazda yerel bildirim oluşturur.
    await _localPlugin.show(
      // Her bildirim için kullanılacak kimlik numarasını belirler.
      message.hashCode,

      // Bildirimin başlığını alır.
      // Başlık yoksa varsayılan olarak 'Yeni Bildirim' gösterir.
      message.notification?.title ?? 'Yeni Bildirim',

      // Bildirimin içeriğini alır.
      // İçerik yoksa boş metin gösterir.
      message.notification?.body ?? '',

      // Bildirim için hazırlanan Android ve iOS ayarlarını kullanır.
      details,
    );
  }
}
