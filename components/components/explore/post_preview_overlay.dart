import 'package:flutter/material.dart';

import '../../../../models/ad.dart';
import '../../../../models/post.dart';
import '../POST/PostCard.dart';
import '../ads/AdPostCard.dart';

/// Shows a single post or ad "spotlighted" over a dimmed backdrop —
/// the long-press preview triggered from an Explore grid tile. Tapping
/// outside dismisses it; nothing here is wired to navigate anywhere
/// else, it's purely a peek.
Future<void> showPostPreview(
  BuildContext context, {
  required FeedItem item,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Post preview',
    barrierColor: Colors.black.withOpacity(0.72),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            // showGeneralDialog's pageBuilder content is inserted
            // straight into the Navigator's Overlay — outside
            // ExplorePage's Scaffold, so there's no Material ancestor
            // for PostCard's InkWells to find without this. `showDialog`
            // avoids the issue because AlertDialog/Dialog already wraps
            // its content in one; a raw pageBuilder doesn't.
            child: Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _buildCard(context, item),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Widget _buildCard(BuildContext context, FeedItem item) {
  if (item.type == FeedItemType.advertisement && item.ad != null) {
    final ad = item.ad!;
    return AdPostCard(
      ad: ad,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      onTap: () => _showAdPlaceholder(context, ad),
    );
  }

  final post = item.post;
  if (post == null) return const SizedBox.shrink();

  return PostCard(
    post: post,
    margin: const EdgeInsets.symmetric(horizontal: 18),
  );
}

void _showAdPlaceholder(BuildContext context, Ad ad) {
  // Same placeholder treatment as the home feed's ad tap — there's no
  // browser/deep-link handling wired up yet.
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        content: Text(
          'This would open ${ad.destinationUrl} for "${ad.advertiserName}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
