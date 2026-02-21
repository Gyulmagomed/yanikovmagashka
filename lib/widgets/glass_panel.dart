import 'package:flutter/material.dart';
import 'package:telemost12_app/theme/app_theme.dart';

Widget buildGlassPanel(
  BuildContext context, {
  required Widget child,
  double borderRadius = 20,
  Color? color,
  bool withShadow = true,
}) {
  final c = AppTheme.of(context);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: color ?? c.surfaceElevated,
      border: Border.all(color: c.border, width: 1),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    ),
    child: child,
  );
}
