import 'package:flutter/material.dart';

import '../../models/user.dart';

/// The app's single default/fallback avatar: a plain circle showing the
/// user's initial. Used anywhere there's no avatar image to show yet —
/// no URL, still loading, or failed to load — so every avatar in the
/// app (story bubbles, post cards, comments, etc.) falls back to
/// exactly the same look instead of each place inventing its own.
class DefaultAvatar extends StatelessWidget {
  final User user;
  final double size;

  const DefaultAvatar({
    super.key,
    required this.user,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8E8E8),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF666666),
        ),
      ),
    );
  }
}
