import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/post.dart';
import '../../models/user.dart';
import '../../theme/app_typography.dart';
import '../common/Avatar.dart';

/// Shows the post's share sheet: a grid of people to send it to, plus
/// a row of quick actions (add to story, send as a message, share
/// outside the app, copy link).
///
/// UI-only for now, same as the options and comments sheets — there's
/// no messaging backend or contacts list yet, so the grid below is a
/// placeholder and sending to a person just confirms with a snackbar.
/// "Copy link" is the one action that's for real, since it needs
/// nothing but the clipboard.
Future<void> showPostShareSheet(
  BuildContext context, {
  required Post post,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => _PostShareSheet(post: post),
  );
}

// Stands in for a real contacts/recent-chats backend — just enough to
// show the grid at a realistic size.
const _placeholderContacts = [
  User(id: 'contact_1', username: 'daniel.c', displayName: 'Daniel'),
  User(id: 'contact_2', username: 'kuzayet', displayName: 'Kuza'),
  User(id: 'contact_3', username: 'pronuncio', displayName: 'Pronuncio'),
  User(id: 'contact_4', username: 'destiny.j', displayName: 'Destiny'),
  User(id: 'contact_5', username: 'medad', displayName: 'Medad'),
  User(id: 'contact_6', username: 'amanda', displayName: 'Amanda'),
];

class _PostShareSheet extends StatelessWidget {
  final Post post;

  const _PostShareSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _ShareSheetColors.of(isDark);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        color: colors.sheet,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, bottomInset > 0 ? 4 : 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGrabHandle(colors),
                const SizedBox(height: 16),
                _buildSearchField(colors),
                const SizedBox(height: 18),
                _buildContactsGrid(colors),
                const SizedBox(height: 8),
                Divider(height: 1, thickness: 1, color: colors.divider),
                _buildQuickActions(context, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrabHandle(_ShareSheetColors colors) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: colors.handle,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSearchField(_ShareSheetColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.searchField,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20, color: colors.secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search',
                style: AppTypography.body(fontSize: 14, color: colors.secondaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsGrid(_ShareSheetColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _placeholderContacts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final contact = _placeholderContacts[index];
          return _ContactTile(user: contact, colors: colors);
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, _ShareSheetColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add to Story',
            colors: colors,
            onTap: () => _handleTap(
              context,
              "Adding to your story isn't available yet.",
            ),
          ),
          _QuickAction(
            icon: Icons.send_outlined,
            label: 'Message',
            colors: colors,
            onTap: () => _handleTap(
              context,
              "Sending messages isn't available yet.",
            ),
          ),
          _QuickAction(
            icon: Icons.ios_share_rounded,
            label: 'Share to...',
            colors: colors,
            onTap: () => _handleTap(
              context,
              "Sharing outside the app isn't available yet.",
            ),
          ),
          _QuickAction(
            icon: Icons.link_rounded,
            label: 'Copy Link',
            colors: colors,
            onTap: () => _handleCopyLink(context),
          ),
        ],
      ),
    );
  }

  static void _handleTap(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _handleCopyLink(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    // A real deep link would come from the backend; this stands in for
    // it so "copy" is genuinely functional rather than a placeholder.
    Clipboard.setData(ClipboardData(text: 'https://asterisk.app/p/${post.id}'));

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Link copied.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }
}

class _ContactTile extends StatelessWidget {
  final User user;
  final _ShareSheetColors colors;

  const _ContactTile({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _PostShareSheet._handleTap(
        context,
        "Sending to ${user.displayName} isn't available yet.",
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(user: user, size: 56, showVerificationBadge: false),
          const SizedBox(height: 6),
          Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.caption(fontSize: 11, color: colors.primaryText),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final _ShareSheetColors colors;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.actionBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: colors.primaryText),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.caption(fontSize: 11, color: colors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareSheetColors {
  final Color sheet;
  final Color handle;
  final Color searchField;
  final Color actionBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color divider;

  const _ShareSheetColors({
    required this.sheet,
    required this.handle,
    required this.searchField,
    required this.actionBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.divider,
  });

  static _ShareSheetColors of(bool isDark) {
    if (isDark) {
      return const _ShareSheetColors(
        sheet: Color(0xFF1C1F27),
        handle: Color(0xFF3A3F4C),
        searchField: Color(0xFF262A34),
        actionBackground: Color(0xFF262A34),
        primaryText: Color(0xFFF2F2F4),
        secondaryText: Color(0xFFA6AAB8),
        divider: Color(0xFF2B2F3A),
      );
    }

    return const _ShareSheetColors(
      sheet: Colors.white,
      handle: Color(0xFFDDDDDD),
      searchField: Color(0xFFF3F3F3),
      actionBackground: Color(0xFFF3F3F3),
      primaryText: Color(0xFF1A1A1A),
      secondaryText: Color(0xFF888888),
      divider: Color(0xFFF0F0F0),
    );
  }
}
