import 'package:flutter/material.dart';

import '../../models/ad.dart';
import '../common/app_menu_components.dart';

Future<void> showAdOptionsSheet(BuildContext context, {required Ad ad}) {
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _MenuGrabHandle(),
          const SizedBox(height: 14),
          AppMenuGroup(children: [
            AppMenuRow(icon: Icons.person_outline_rounded, label: 'About this account', onTap: () => _handleTap(context, "Account details aren't available yet.")),
            AppMenuRow(icon: Icons.campaign_outlined, label: 'About this ad', onTap: () => _handleTap(context, "Ad details aren't available yet.")),
            AppMenuRow(icon: Icons.info_outline_rounded, label: "Why you're seeing this ad", onTap: () => _handleTap(context, "Ad targeting details aren't available yet.")),
            AppMenuRow(icon: Icons.campaign_outlined, label: 'About Asterisk ads', onTap: () => _handleTap(context, "This isn't available yet.")),
          ]),
          const SizedBox(height: 10),
          AppMenuGroup(children: [
            AppMenuRow(icon: Icons.check_circle_outline_rounded, label: 'Interested', onTap: () => _handleTap(context, "You'll see more ads like this.")),
            AppMenuRow(icon: Icons.cancel_outlined, label: 'Not interested', onTap: () => _handleTap(context, "You'll see fewer ads like this.")),
            AppMenuRow(icon: Icons.flag_outlined, label: 'Report ad', destructive: true, onTap: () => _handleTap(context, 'Ad reported. Thanks for letting us know.')),
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
