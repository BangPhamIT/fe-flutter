import 'package:flutter/material.dart';
import 'package:inventory_app/core/theme/themes.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    this.radius,
    required this.activeBackgroundColor,
    required this.deactiveBackgroundColor,
    required this.padding,
    this.minimumSize,
    required this.isActive,
    required this.onPressed,
    this.style,
    this.shadow,
    this.textColor,
  });
  final String title;
  final double? radius;
  final Color activeBackgroundColor;
  final Color deactiveBackgroundColor;
  final EdgeInsetsGeometry padding;
  final Size? minimumSize;
  final bool isActive;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final bool? shadow;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isActive ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: activeBackgroundColor,
        disabledBackgroundColor: deactiveBackgroundColor,
        minimumSize: minimumSize ?? const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 8),
          side: BorderSide(width: 1, color: AppColors.border),
        ),
        elevation: shadow == true ? 2 : 0,
      ),
      child: Padding(
        padding: padding,
        child: Text(
          title,
          style: style ??
              AppStyles.s16W600.copyWith(
                color: textColor ?? Colors.white,
              ),
        ),
      ),
    );
  }
}

extension AppPrimaryButton on BuildContext {
  Widget basicButton(
    String title, {
    Size minimumSize = const Size(double.infinity, 48),
    bool isActive = true,
    double radius = 8,
    required void Function() onPressed,
    Color? color,
    TextStyle? textStyle,
  }) =>
      PrimaryButton(
        title: title,
        radius: radius,
        activeBackgroundColor: color ?? AppColors.mainColor,
        deactiveBackgroundColor:
            (color ?? AppColors.mainColor).percentAlpha(50),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: minimumSize,
        isActive: isActive,
        onPressed: onPressed,
        style: textStyle,
      );
}
