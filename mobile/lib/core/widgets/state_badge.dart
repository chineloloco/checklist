import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeTone { neutral, attention, success, danger }

class StateBadge extends StatelessWidget {
  const StateBadge({
    required this.label,
    required this.icon,
    this.tone = BadgeTone.neutral,
    super.key,
  });

  final String label;
  final IconData icon;
  final BadgeTone tone;

  (Color, Color) get _colors => switch (tone) {
        BadgeTone.neutral =>
          (FieldColors.notApplicableSoft, FieldColors.notApplicable),
        BadgeTone.attention => (FieldColors.amberSoft, const Color(0xFF805000)),
        BadgeTone.success =>
          (FieldColors.compliantSoft, FieldColors.compliant),
        BadgeTone.danger =>
          (FieldColors.nonCompliantSoft, FieldColors.nonCompliant),
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
