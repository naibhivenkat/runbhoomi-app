import 'package:flutter/material.dart';
import '../core/colors.dart';

class AuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final bool border;
  final bool loading;
  final Widget? icon;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.border = false,
    this.loading = false,
    this.icon,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  double scale = 1.0;

  void onTapDown(_) {
    setState(() => scale = 0.97);
  }

  void onTapUp(_) {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.loading;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),

      child: SizedBox(
        height: 52,

        child: ElevatedButton(
          onPressed: disabled ? null : widget.onPressed,

          style: ElevatedButton.styleFrom(
            elevation: disabled ? 0 : 4,

            backgroundColor: disabled
                ? Colors.grey.shade300
                : (widget.color ?? AppColors.primary),

            foregroundColor:
                widget.textColor ?? Colors.white,

            shadowColor: Colors.black26,

            side: widget.border
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          onLongPress: () {},

          child: GestureDetector(
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onTapCancel: () => onTapUp(null),

            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}