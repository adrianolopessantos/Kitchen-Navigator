import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    this.onTap,
    this.wide = false,
    this.accentColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;
  final VoidCallback? onTap;
  final bool wide;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: wide ? _wideLayout() : _compactLayout(),
        ),
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        _IconBadge(icon: icon, color: accentColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _TextBlock()),
        const SizedBox(width: AppSpacing.xs),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.subtle,
        ),
      ],
    );
  }

  Widget _compactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBadge(icon: icon, color: accentColor),
        const Spacer(),
        _TextBlock(),
      ],
    );
  }

  Widget _TextBlock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accentColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          note,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: .22),
        ),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}
