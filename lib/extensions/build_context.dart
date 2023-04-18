import 'dart:ui';

import 'package:flutter/widgets.dart';

extension DarkMode on BuildContext {
  bool isDarkMode() {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  bool isRtl() {
    final directionality = Directionality.of(this);
    return directionality == TextDirection.rtl;
  }
}
