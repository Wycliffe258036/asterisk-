import 'package:flutter/material.dart';

import '../../models/ad.dart';
import '../../theme/app_typography.dart';
import '../common/asterisk_menu.dart';

/// Shows the ad's "..." options sheet: two rounded, grouped panels —
/// informational rows about the ad/account, then a feedback row
/// (interested / not interested / report) — mirroring the structure of
/// the regular post options sheet, but with ad-specific choices.
///
/// UI-only for now, same as the rest of the app's overflow menus.
Future<void> showAdOptionsSheet(
  BuildContext context, {
  required Ad ad,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => _AdOptionsSheet(ad: ad),
  );
}

class _AdOptionsSheet extends StatelessWidget {
  final Ad ad;

  const _AdOptionsSheet({required this.ad});

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

            _AdOptionGroup(
              options: [
                _AdSheetOption(
                  icon: Icons.person_outline_rounded,
                  label: 'About this account',
                  onTap: (context) => _handleTap(
                    context,
                    "Account details aren't available yet.",
                  ),
                ),
                _AdSheetOption(
                  icon: Icons.campaign_outlined,
                  label: 'About this ad',
                  onTap: (context) => _handleTap(
                    context,
                    "Ad details aren't available yet.",
                  ),
                ),
                _AdSheetOption(
                  icon: Icons.info_outline_rounded,
                  label: "Why you're seeing this ad",
                  onTap: (context) => _handleTap(
                    context,
                    "Ad targeting details aren't available yet.",
                  ),
                ),
                _AdSheetOption(
                  icon: Icons.campaign_outlined,
                  label: 'About Asterisk ads',
                  onTap: (context) => _handleTap(
                    context,
                    "This isn't available yet.",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _AdOptionGroup(
              options: [
                _AdSheetOption(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Interested',
                  onTap: (context) => _handleTap(
                    context,
                    "You'll see more ads like this.",
                  ),
                ),
                _AdSheetOption(
                  icon: Icons.cancel_outlined,
                  label: 'Not interested',
                  onTap: (context) => _handleTap(
                    context,
                    "You'll see fewer ads like this.",
                  ),
                ),
                _AdSheetOption(
                  icon: Icons.flag_outlined,
                  label: 'Report ad',
                  isDestructive: true,
                  onTap: (context) => _handleTap(
                    context,
                    'Ad reported. Thanks for letting us know.',
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

class _AdSheetOption {
  final IconData icon;
  final String label;
  final ValueChanged<BuildContext> onTap;
  final bool isDestructive;

  const _AdSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _AdOptionGroup extends StatelessWidget {
  final List<_AdSheetOption> options;
  const _AdOptionGroup({required this.options});

  @override
  Widget build(BuildContext context) {
    return AsteriskMenuGroup(
      children: options.map((option) => AsteriskMenuRow(
        icon: option.icon,
        title: option.label,
        destructive: option.isDestructive,
        onTap: () => option.onTap(context),
      )).toList(),
    );
  }
}
