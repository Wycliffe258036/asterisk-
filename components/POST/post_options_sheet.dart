import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../common/app_menu_components.dart';

Future<void> showPostOptionsSheet(BuildContext context, {required Post post}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _MenuGrabHandle(),
          const SizedBox(height: 14),
          AppMenuGroup(children: [
            AppMenuRow(icon: Icons.person_outline_rounded, label: 'About this account', onTap: () => _handleTap(context, "About this account isn't available yet.")),
            AppMenuRow(icon: Icons.link_rounded, label: 'Copy link', onTap: () => _handleTap(context, 'Link copied.')),
            AppMenuRow(icon: Icons.ios_share_rounded, label: 'Share to...', onTap: () => _handleTap(context, "Sharing isn't available yet.")),
          ]),
          const SizedBox(height: 10),
          AppMenuGroup(children: [
            AppMenuRow(icon: Icons.visibility_off_outlined, label: 'Not interested', onTap: () => _handleTap(context, "You'll see fewer posts like this.")),
            AppMenuRow(icon: Icons.volume_off_outlined, label: 'Mute ${post.author.displayName}', onTap: () => _handleTap(context, '${post.author.displayName} muted.')),
            AppMenuRow(icon: Icons.flag_outlined, label: 'Report post', destructive: true, onTap: () => _handleTap(context, 'Post reported. Thanks for letting us know.')),
          ]),
        ]),
      ),
    );
  }

  static void _handleTap(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}

class _MenuGrabHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(width: 36, height: 4, decoration: BoxDecoration(color: isDark ? const Color(0xFF555B68) : const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(3)));
  }
}
