import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

/// Shared grouped-menu surface matching the Settings screen in both themes.
class AppMenuGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const AppMenuGroup({super.key, required this.children, this.margin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F27).withOpacity(0.94) : Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF2B2F3A) : const Color(0xFFEDEEF0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.20 : 0.045), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            Divider(height: 1, thickness: 1, indent: 51, color: isDark ? const Color(0xFF2B2F3A) : const Color(0xFFF0F0F0)),
        ],
      ]),
    );
  }
}

/// A consistent icon-led row for menus, option sheets and settings lists.
class AppMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;

  const AppMenuRow({super.key, required this.icon, required this.label, required this.onTap, this.destructive = false, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = destructive ? const Color(0xFFE0453C) : (isDark ? const Color(0xFFF2F2F4) : const Color(0xFF1A1A1A));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w500, color: color))),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}
