import 'package:flutter/foundation.dart';

class FancyBottomTabBarController extends ValueNotifier<bool> {
  FancyBottomTabBarController({bool initiallyExpanded = true}) : super(initiallyExpanded);

  void expand() {
    value = true;
  }

  void shrink() {
    value = false;
  }
}
