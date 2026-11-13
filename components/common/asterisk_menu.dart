import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

/// Shared grouped-menu surface used by overflow sheets and settings menus.
/// Matches SettingsPage cards and automatically follows the active theme.
class AsteriskMenuGroup extends StatelessWidget {
  final List<Widget> children;

  const AsteriskMenuGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: dark ? const Color(0xFF1C1F27).withOpacity(0.92) : Colors.white.withOpacity(0.96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 51,
                  color: dark ? const Color(0xFF2B2F3A) : const Color(0xFFF0F0F0),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Icon-led menu row with Settings typography, spacing and optional
/// destructive treatment. The callback receives the row's live context.
class AsteriskMenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool destructive;
  final VoidCallback? onTap;

  const AsteriskMenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = destructive
        ? const Color(0xFFE0453C)
        : (dark ? const Color(0xFFF2F2F4) : const Color(0xFF1A1A1A));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTypography.caption(
                      fontSize: 12,
                      color: dark ? const Color(0xFFA6AAB8) : const Color(0xFF888888),
                    )),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
