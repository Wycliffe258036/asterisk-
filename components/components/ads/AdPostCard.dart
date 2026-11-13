import 'package:flutter/material.dart';

import '../../../../models/ad.dart';
import '../../../../theme/app_typography.dart';
import 'AdMedia.dart';
import 'ad_options_sheet.dart';

/// The sponsored-post card shown in the feed for
/// [FeedItemType.advertisement] items. Mirrors PostCard's card shell
/// (rounded corners, shadow, same outer margin) so ads sit visually
/// consistent with organic posts, while the header and disclosure
/// label make clear it's an ad.
class AdPostCard extends StatelessWidget {
  final Ad ad;

  /// Fired when the media, headline/body, or CTA button is tapped.
  final VoidCallback? onTap;

  /// Fired from the overflow ("...") button. UI-only for now — same
  /// "no backend yet" placeholder treatment as PostCard's own options
  /// sheet.
  final VoidCallback? onOptionsTap;

  final EdgeInsetsGeometry margin;

  const AdPostCard({
    super.key,
    required this.ad,
    this.onTap,
    this.onOptionsTap,
    this.margin = const EdgeInsets.fromLTRB(14, 0, 14, 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _AdCardColors.of(isDark);

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colors),
          const SizedBox(height: 12),
          _buildMedia(),
          const SizedBox(height: 12),
          _buildCopy(colors),
          const SizedBox(height: 12),
          _buildCta(colors),
        ],
      ),
    );
  }

  Widget _buildHeader(_AdCardColors colors) {
    return Row(
      children: [
        _buildLogo(colors),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad.advertiserName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.campaign_outlined, size: 12, color: colors.secondaryText),
                  const SizedBox(width: 4),
                  Text(
                    ad.disclosureLabel,
                    style: AppTypography.caption(
                      fontSize: 11,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                if (onOptionsTap != null) {
                  onOptionsTap!.call();
                } else {
                  showAdOptionsSheet(context, ad: ad);
                }
              },
              icon: Icon(Icons.more_horiz_rounded, size: 22, color: colors.mutedIcon),
              splashRadius: 20,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogo(_AdCardColors colors) {
    final logoUrl = ad.advertiserLogoUrl;

    return Container(
      width: 38,
      height: 38,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.logoBackground),
      child: logoUrl != null && logoUrl.isNotEmpty
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildLogoFallback(colors),
            )
          : _buildLogoFallback(colors),
    );
  }

  Widget _buildLogoFallback(_AdCardColors colors) {
    final initial = ad.advertiserName.isNotEmpty ? ad.advertiserName[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.secondaryText),
      ),
    );
  }

  Widget _buildMedia() {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AdMedia(ad: ad),
      ),
    );
  }

  Widget _buildCopy(_AdCardColors colors) {
    final headline = ad.headline;
    final body = ad.body;

    final hasHeadline = headline != null && headline.trim().isNotEmpty;
    final hasBody = body != null && body.trim().isNotEmpty;

    if (!hasHeadline && !hasBody) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeadline)
            Text(
              headline,
              style: AppTypography.body(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.primaryText,
              ),
            ),
          if (hasBody) ...[
            const SizedBox(height: 4),
            Text(
              body,
              style: AppTypography.body(fontSize: 13, color: colors.secondaryText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCta(_AdCardColors colors) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          ad.callToAction ?? _defaultCta(ad.action),
          style: AppTypography.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),
      ),
    );
  }

  String _defaultCta(AdAction action) {
    switch (action) {
      case AdAction.openWebsite:
        return 'Learn More';
      case AdAction.openApp:
        return 'Install';
      case AdAction.openProfile:
        return 'View Profile';
      case AdAction.openStore:
        return 'Shop Now';
      case AdAction.openDeepLink:
        return 'Open';
    }
  }
}

class _AdCardColors {
  final Color card;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedIcon;
  final Color logoBackground;

  const _AdCardColors({
    required this.card,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedIcon,
    required this.logoBackground,
  });

  static _AdCardColors of(bool isDark) {
    if (isDark) {
      return _AdCardColors(
        card: const Color(0xFF1C1F27).withOpacity(0.82),
        border: const Color(0xFF33384A),
        primaryText: const Color(0xFFF2F2F4),
        secondaryText: const Color(0xFFA6AAB8),
        mutedIcon: const Color(0xFFC7CAD6),
        logoBackground: const Color(0xFF2B2F3A),
      );
    }

    return _AdCardColors(
      card: Colors.white.withOpacity(0.90),
      border: const Color(0xFFEDEDED),
      primaryText: const Color(0xFF111111),
      secondaryText: const Color(0xFF777777),
      mutedIcon: const Color(0xFF555555),
      logoBackground: const Color(0xFFEDEDED),
    );
  }
}
