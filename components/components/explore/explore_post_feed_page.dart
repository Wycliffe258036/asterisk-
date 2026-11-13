import 'package:flutter/material.dart';

import '../../../../models/ad.dart';
import '../../../../models/post.dart';
import '../../../../theme/sky_gradient_background.dart';
import '../POST/PostCard.dart';
import '../ads/AdPostCard.dart';

/// Full-screen, scrollable feed opened by tapping an Explore grid
/// tile. [items] is reordered so the tapped post plays first, followed
/// by the rest of the grid in its original order — the same idea as
/// Instagram's explore feed, without needing exact scroll-to-index
/// positioning on a list of variable-height cards.
class ExplorePostFeedPage extends StatelessWidget {
  final List<FeedItem> items;
  final int initialIndex;

  const ExplorePostFeedPage({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = _reordered();
    final topSafeArea = MediaQuery.of(context).padding.top;

    return SkyGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, topSafeArea + 56, 0, 24),
              itemCount: ordered.length,
              itemBuilder: (context, index) => _buildItem(context, ordered[index]),
            ),
            Positioned(
              left: 10,
              top: topSafeArea + 8,
              child: _BackButton(onTap: () => Navigator.of(context).maybePop()),
            ),
          ],
        ),
      ),
    );
  }

  List<FeedItem> _reordered() {
    if (items.isEmpty) return items;

    final start = initialIndex.clamp(0, items.length - 1);
    return [
      ...items.sublist(start),
      ...items.sublist(0, start),
    ];
  }

  Widget _buildItem(BuildContext context, FeedItem item) {
    if (item.type == FeedItemType.advertisement && item.ad != null) {
      final ad = item.ad!;
      return AdPostCard(
        key: ValueKey(item.id),
        ad: ad,
        onTap: () => _showAdPlaceholder(context, ad),
      );
    }

    final post = item.post;
    if (post == null) return const SizedBox.shrink();

    return PostCard(key: ValueKey(item.id), post: post);
  }

  void _showAdPlaceholder(BuildContext context, Ad ad) {
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
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: Colors.black.withOpacity(0.35),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
