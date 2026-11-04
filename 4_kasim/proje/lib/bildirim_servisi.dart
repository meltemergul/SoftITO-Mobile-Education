import 'package:firebase_messaging/firebase_messaging.dart';

//en üstte olmak zorunda
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //yakalama fonksiyonu
  print("Arka planda bildirim geldi:${message.notification?.title}");
}

class BildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> baslat() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Kullanıcı bildirim iznini verdi");
    }
    final token = await _fcm.getToken();
    print('cihazın FCM tokenı:$token');
  }
}
