import 'package:firebase/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/storage_fcm_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    runApp(const SoftitoFcmDemoApplication());
  }
}

class SoftitoFcmDemoApplication extends StatelessWidget {
  const SoftitoFcmDemoApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Softito FCM Demo Applications",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(0, 0, 0, 83),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const StorageFcmEkrani(),
    );
  }
}
