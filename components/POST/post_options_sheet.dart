import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../theme/app_typography.dart';

/// Shows the post's "..." options sheet: two rounded, grouped panels of
/// icon-led actions over a dimmed backdrop, with a destructive "Report"
/// row at the end.
///
/// UI-only for now — there's no backend yet, so every option just
/// dismisses the sheet and shows a short confirmation, the same
/// placeholder approach used for the avatar "view profile" tap.
Future<void> showPostOptionsSheet(
  BuildContext context, {
  required Post post,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    // A plain dim scrim, not a BackdropFilter blur — this app already hit
    // real stability issues (broken hit-testing, a semantics assertion)
    // from BackdropFilter over the scrolling feed, and some browsers are
    // especially sensitive to it. This gets a similar "dimmed" feel with
    // none of that risk. Tune the opacity to taste.
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => _PostOptionsSheet(post: post),
  );
}

class _PostOptionsSheet extends StatelessWidget {
  final Post post;

  const _PostOptionsSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 8, 10, bottomInset + 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGrabHandle(),

            const SizedBox(height: 14),

            _OptionGroup(
              options: [
                _SheetOption(
                  icon: Icons.person_outline_rounded,
                  label: 'About this account',
                  onTap: (context) => _handleTap(
                    context,
                    'About this account isn\'t available yet.',
                  ),
                ),
                _SheetOption(
                  icon: Icons.link_rounded,
                  label: 'Copy link',
                  onTap: (context) => _handleTap(context, 'Link copied.'),
                ),
                _SheetOption(
                  icon: Icons.ios_share_rounded,
                  label: 'Share to...',
                  onTap: (context) => _handleTap(
                    context,
                    'Sharing isn\'t available yet.',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _OptionGroup(
              options: [
                _SheetOption(
                  icon: Icons.visibility_off_outlined,
                  label: 'Not interested',
                  onTap: (context) => _handleTap(
                    context,
                    'You\'ll see fewer posts like this.',
                  ),
                ),
                _SheetOption(
                  icon: Icons.volume_off_outlined,
                  label: 'Mute ${post.author.displayName}',
                  onTap: (context) => _handleTap(
                    context,
                    '${post.author.displayName} muted.',
                  ),
                ),
                _SheetOption(
                  icon: Icons.flag_outlined,
                  label: 'Report post',
                  isDestructive: true,
                  onTap: (context) => _handleTap(
                    context,
                    'Post reported. Thanks for letting us know.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  static void _handleTap(BuildContext context, String message) {
    // Grab the messenger BEFORE popping — using `context` again after the
    // sheet is dismissed can hit a deactivated-widget lookup.
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
}

class _SheetOption {
  final IconData icon;
  final String label;
  final ValueChanged<BuildContext> onTap;
  final bool isDestructive;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _OptionGroup extends StatelessWidget {
  final List<_SheetOption> options;

  const _OptionGroup({required this.options});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              _buildRow(options[i]),
              if (i != options.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F0),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(_SheetOption option) {
    final color =
        option.isDestructive ? const Color(0xFFE0453C) : const Color(0xFF1A1A1A);

    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => option.onTap(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(option.icon, size: 21, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option.label,
                    style: AppTypography.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}