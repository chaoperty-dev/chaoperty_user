import 'package:flutter/material.dart';
import 'web_security.dart';

/// Watermark widget that overlays the entire screen
class WatermarkOverlay extends StatelessWidget {
  final String text;
  final Widget child;

  const WatermarkOverlay({
    Key? key,
    required this.text,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return child;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // ใช้ค่าจาก config
    final fontSize = WebSecurityConfig.watermarkFontSize;
    final opacity = WebSecurityConfig.watermarkOpacity;
    final rotation = WebSecurityConfig.watermarkRotation;
    final spacingX = WebSecurityConfig.watermarkSpacingX;
    final spacingY = WebSecurityConfig.watermarkSpacingY;
    final count = WebSecurityConfig.watermarkCount;

    return Stack(
      children: [
        child,
        IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  for (int i = 0; i < count; i++)
                    Positioned(
                      left: (i * spacingX * 1.37) % width,
                      top: (i * spacingY * 1.42) % height,
                      child: Transform.rotate(
                        angle: rotation,
                        child: Text(
                          '$text\n${DateTime.now().toString().substring(0, 16)}',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
