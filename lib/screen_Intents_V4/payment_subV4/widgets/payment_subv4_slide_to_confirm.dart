import 'package:flutter/material.dart';
import 'package:chaoperty_user/color.dart';

/// Slide-to-confirm control ใช้สำหรับยืนยัน/ยกเลิกรายการชำระเงิน
class PaymentSubV4SlideToConfirm extends StatefulWidget {
  const PaymentSubV4SlideToConfirm({
    super.key,
    required this.onConfirmation,
    required this.label,
    this.color = Colors.indigo,
    this.enabled = true,
  });

  final VoidCallback onConfirmation;
  final String label;
  final Color color;
  final bool enabled;

  @override
  State<PaymentSubV4SlideToConfirm> createState() =>
      _PaymentSubV4SlideToConfirmState();
}

class _PaymentSubV4SlideToConfirmState
    extends State<PaymentSubV4SlideToConfirm> {
  double _position = 0.0;
  bool _confirmed = false;
  bool _isDragging = false;

  static const double _height = 56.0;
  static const double _handleWidth = 48.0;
  static const double _pad = 4.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag =
            (constraints.maxWidth - _handleWidth - _pad * 2).clamp(1.0, 1e6);
        final double pct = (_position / maxDrag).clamp(0.0, 1.0);
        final Color base = widget.enabled ? widget.color : Colors.grey.shade500;
        final Color dark = widget.enabled
            ? Color.lerp(widget.color, Colors.black, 0.35)!
            : Colors.grey.shade700;

        return Container(
          height: _height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.lerp(base, dark, pct)!, dark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(_height / 2),
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: (1.0 - pct * 2).clamp(0.0, 1.0),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (!_confirmed)
                AnimatedPositioned(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  left: _pad + _position,
                  top: (_height - _handleWidth) / 2,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!widget.enabled) return;
                      setState(() {
                        _isDragging = true;
                        _position =
                            (_position + details.delta.dx).clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (!widget.enabled) return;
                      if (_position >= maxDrag * 0.72) {
                        setState(() {
                          _isDragging = false;
                          _position = maxDrag;
                          _confirmed = true;
                        });
                        widget.onConfirmation();
                      } else {
                        setState(() {
                          _isDragging = false;
                          _position = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: _handleWidth,
                      height: _handleWidth,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: widget.enabled ? widget.color : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              if (_confirmed)
                Positioned(
                  right: _pad,
                  top: (_height - _handleWidth) / 2,
                  child: Container(
                    width: _handleWidth,
                    height: _handleWidth,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: widget.color,
                      size: 26,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
