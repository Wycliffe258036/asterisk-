import 'package:flutter/material.dart';

import '../../../../models/user.dart';
import '../../../../theme/app_typography.dart';
import 'SuggestedUserCard.dart';

/// Horizontal "Suggested for you" shelf, dropped a few posts into the
/// feed. Dismissible as a whole via the header's close button — there's
/// no per-user "not interested" yet, matching the granularity of the
/// other not-yet-backed placeholder actions in this app.
class SuggestedUserRow extends StatelessWidget {
  final List<User> users;
  final ValueChanged<User>? onUserTap;
  final ValueChanged<User>? onFollowToggle;
  final VoidCallback? onDismiss;

  final EdgeInsetsGeometry margin;

  const SuggestedUserRow({
    super.key,
    required this.users,
    this.onUserTap,
    this.onFollowToggle,
    this.onDismiss,
    this.margin = const EdgeInsets.fromLTRB(14, 0, 14, 16),
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shelfColor =
        isDark ? const Color(0xFF1C1F27).withOpacity(0.82) : Colors.white.withOpacity(0.90);
    final titleColor = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final closeColor = isDark ? const Color(0xFF8A8FA3) : const Color(0xFF999999);

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: BoxDecoration(
        color: shelfColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(titleColor, closeColor),
          const SizedBox(height: 12),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 8),
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final user = users[index];
                return SuggestedUserCard(
                  user: user,
                  onTap: () => onUserTap?.call(user),
                  onFollowToggle: () => onFollowToggle?.call(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color closeColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Suggested for you',
              style: AppTypography.title(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
          if (onDismiss != null)
            Semantics(
              button: true,
              label: 'Dismiss suggestions',
              child: InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 18, color: closeColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
