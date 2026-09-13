import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen_Intents_V4/payment_subV4/models/payment_subv4_models.dart';

abstract final class PaymentSubV4Theme {
  static const pageBackground = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const slateSoft = Color(0xFFF1F5F9);
  static const primaryOrange = Color(0xFFF97316);
  static const primaryOrangeDark = Color(0xFFEA580C);
  static const skyAction = Color(0xFF0284C7);
  static const skySoft = Color(0xFFF0F9FF);
  static const amberBackground = Color(0xFFFEF3C7);
  static const amberForeground = Color(0xFFB45309);
  static const amberBorder = Color(0xFFFDE68A);
  static const emerald = Color(0xFF10B981);

  static const double cardRadius = 20;
  static const double controlRadius = 12;
  static const EdgeInsets pageInsets = EdgeInsets.symmetric(horizontal: 12);

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static TextStyle text({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = textPrimary,
    double? height,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: Font_.Fonts_T,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      fontFeatures: tabular ? tabularFigures : null,
    );
  }

  static BoxDecoration cardDecoration({Color color = surface}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D0F172A),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  static String money(Money value) =>
      NumberFormat('#,##0.00', 'en_US').format(value.toDouble());

  static String countdown(int seconds) {
    final safe = seconds.clamp(0, 359999);
    final hours = (safe ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((safe % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (safe % 60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$secs' : '$hours:$minutes:$secs';
  }

  static String expiry(String? iso, {required bool isEn}) {
    final date = DateTime.tryParse((iso ?? '').trim())?.toLocal();
    if (date == null) return '-';

    if (isEn) {
      return DateFormat('d MMMM yyyy HH:mm', 'en_US').format(date);
    }

    const months = <String>[
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.day} ${months[date.month - 1]} ${date.year + 543} เวลา $time น.';
  }
}
