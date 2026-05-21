import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'web_security.dart';

/// Web-specific security implementation
class WebSecurityWeb {
  static void initialize() {
    if (WebSecurityConfig.disableRightClick) {
      _disableRightClick();
    }
    if (WebSecurityConfig.blurOnVisibilityChange) {
      _setupVisibilityListener();
    }
    _disablePrintAndSave();
    _disableTextSelection();
  }

  static void _disableRightClick() {
    html.window.document.onContextMenu.listen((e) {
      e.preventDefault();
    });
  }

  static void _setupVisibilityListener() {
    html.document.onVisibilityChange.listen((event) {
      // This will be handled by the widget tree via a global notifier
      _visibilityNotifier.value = html.document.visibilityState == 'visible';
    });
  }

  static void _disablePrintAndSave() {
    html.window.onKeyDown.listen((event) {
      if (event.ctrlKey || event.metaKey) {
        if (event.key == 'p' || event.key == 's') {
          event.preventDefault();
        }
      }
      if (event.key == 'F12') {
        event.preventDefault();
      }
    });
  }

  static void _disableTextSelection() {
    html.document.body?.style.setProperty('user-select', 'none');
    html.document.body?.style.setProperty('-webkit-user-select', 'none');
  }

  /// Notifier for visibility changes
  static final ValueNotifier<bool> _visibilityNotifier =
      ValueNotifier<bool>(true);
  static ValueNotifier<bool> get visibilityNotifier => _visibilityNotifier;
}
