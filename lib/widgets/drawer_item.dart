import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A navigation row used in the app drawer.
///
/// Previously this widget was copy-pasted (as a private `_DrawerItem`) into
/// both the dashboard and home screens. It now lives here so the two drawers
/// share one implementation.
class AppDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Optional pill on the right showing a count (e.g. number of projects).
  final String? trailing;

  /// Optional highlighted badge (e.g. "NEW").
  final String? badge;
  final bool isDark;
  final VoidCallback onTap;

  const AppDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.badge,
    this.isDark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget? _buildTrailing() {
    if (badge != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          badge!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (trailing != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          trailing!,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return null;
  }
}
