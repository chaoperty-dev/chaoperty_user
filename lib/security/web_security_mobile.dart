import 'package:flutter/material.dart';

/// Mobile stub for web security (does nothing on mobile)
class WebSecurityWeb {
  static void initialize() {
    // No-op on mobile
  }

  static final ValueNotifier<bool> _visibilityNotifier =
      ValueNotifier<bool>(true);
  static ValueNotifier<bool> get visibilityNotifier => _visibilityNotifier;
}
