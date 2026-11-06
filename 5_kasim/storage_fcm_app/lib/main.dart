import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:storage_fcm_app/services/fcm_bildirim_servisi.dart';

import 'firebase_options.dart';
import 'screens/storage_fcm_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Firebase başarıyla başlatıldı.');
  } catch (e, stackTrace) {
    debugPrint('Firebase başlatma hatası: $e');
    debugPrint('$stackTrace');
  }
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  // Firebase başlatılsa da hata oluşsa da uygulamayı aç.
  runApp(const SoftitoFcmDemoApplication());
}

class SoftitoFcmDemoApplication extends StatelessWidget {
  const SoftitoFcmDemoApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Softito FCM Demo Applications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 83),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const StorageFcmEkrani(),
    );
  }
}
