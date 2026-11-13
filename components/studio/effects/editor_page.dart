import 'package:flutter/material.dart';

import '/theme/app_typography.dart';
import '/./theme/sky_gradient_background.dart';

/// Landing spot for the Editor flow. Drill-down page, no floating nav
/// bar — same pattern as Notifications and Settings. Crop/color/trim
/// tools and the non-destructive operation stack replace this
/// placeholder in a later pass, after Effects.
class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SkyGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildComingSoon(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = SkyGradientBackground.paletteOf(context);
    final isDarkSurface = palette.contentBrightness == Brightness.dark;
    final contentColor = isDarkSurface ? Colors.white : const Color(0xFF151515);

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: contentColor),
            ),
            Expanded(
              child: Text(
                'Editor',
                style: AppTypography.title(fontSize: 18, fontWeight: FontWeight.w700, color: contentColor),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF111111);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF777777);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: const Color(0xFF287BEA), borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              'Editor, coming later',
              textAlign: TextAlign.center,
              style: AppTypography.title(fontSize: 18, fontWeight: FontWeight.w700, color: primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Crop, color, trim and caption your photos and videos, with an AI co-pilot for suggestions.',
              textAlign: TextAlign.center,
              style: AppTypography.body(fontSize: 14, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
