import 'package:flutter/foundation.dart';

class HomeController {
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  void select(int index) => currentIndex.value = index;

  void dispose() {
    currentIndex.dispose();
  }
}
