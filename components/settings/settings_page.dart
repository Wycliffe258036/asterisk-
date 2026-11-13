import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/app_theme_controller.dart';
import '../../theme/app_typography.dart';
import '../../theme/sky_gradient_background.dart';
import '../common/Avatar.dart';
import '../profile/edit_profile_sheet.dart';

/// Settings screen, reached from the Profile page's gear icon.
/// Structured like the reference (grouped rows, an account card up
/// top, Log Out at the bottom) but in this app's own card language —
/// translucent rounded panels over the sky background instead of a
/// flat dark theme. A few rows beyond the reference: Private Account
/// and Blocked Accounts, since this is a social app and the data model
/// already has `User.isPrivate` to back the first one for real.
class SettingsPage extends StatefulWidget {
  final User user;
  final ValueChanged<User> onUserUpdated;

  const SettingsPage({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late User _user;

  // Local-only — there's no OS notification-permission plumbing wired
  // up, just the in-app preference toggle itself.
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _updateUser(User updated) {
    setState(() => _user = updated);
    widget.onUserUpdated(updated);
  }

  void _handleEditProfile() {
    showEditProfileSheet(context, user: _user, onSave: _updateUser);
  }

  void _handlePrivateAccountChanged(bool value) {
    _updateUser(_user.copyWith(isPrivate: value));
  }

  void _showAppearanceSheet(AppThemeController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) => _AppearanceSheet(controller: controller),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Asterisk'),
          content: const Text(
            'Version 1.0.0 (build 1)\n\nA space to share moments, stories and ideas.',
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

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("$label isn't available yet."),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _handleLogOutTap() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text("You'll need to sign back in to use Asterisk again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showComingSoon('Logging out');
              },
              child: const Text('Log Out', style: TextStyle(color: Color(0xFFE0453C))),
            ),
          ],
        );
      },
    );
  }

  Color get _primaryText {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFF2F2F4) : const Color(0xFF1A1A1A);
  }

  Color get _secondaryText {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);
  }

  Widget get _chevronIcon {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: isDark ? const Color(0xFF8A8FA3) : const Color(0xFFBBBBBB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);

    return SkyGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 6, bottom: 32),
                  children: [
                    _buildAccountCard(),
                    _SettingsGroup(children: [
                      _buildRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push Notifications',
                        subtitle: 'Stay updated with activity',
                        trailing: Switch(
                          value: _pushNotificationsEnabled,
                          onChanged: (value) => setState(() => _pushNotificationsEnabled = value),
                          activeThumbColor: const Color(0xFF32CD72),
                        ),
                      ),
                      _buildRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Private Account',
                        subtitle: _user.isPrivate
                            ? 'Only approved followers can see your posts'
                            : 'Anyone can see your posts',
                        trailing: Switch(
                          value: _user.isPrivate,
                          onChanged: _handlePrivateAccountChanged,
                          activeThumbColor: const Color(0xFF32CD72),
                        ),
                      ),
                      _buildRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Security',
                        subtitle: 'Manage your privacy',
                        trailing: _chevronIcon,
                        onTap: () => _showComingSoon('Privacy & Security'),
                      ),
                      _buildRow(
                        icon: Icons.block_rounded,
                        title: 'Blocked Accounts',
                        subtitle: "Manage who you've blocked",
                        trailing: _chevronIcon,
                        onTap: () => _showComingSoon('Blocked accounts'),
                      ),
                    ]),
                    _SettingsGroup(children: [
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          return _buildRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Appearance',
                            subtitle: _appearanceLabel(controller.themeMode),
                            trailing: _chevronIcon,
                            onTap: () => _showAppearanceSheet(controller),
                          );
                        },
                      ),
                      _buildRow(
                        icon: Icons.translate_rounded,
                        title: 'App Language',
                        subtitle: 'English (US)',
                        trailing: _chevronIcon,
                        onTap: () => _showComingSoon('App language'),
                      ),
                      _buildRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Contact Details',
                        subtitle: 'Manage email & phone',
                        trailing: _chevronIcon,
                        onTap: () => _showComingSoon('Contact details'),
                      ),
                    ]),
                    _SettingsGroup(children: [
                      _buildRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        trailing: _chevronIcon,
                        onTap: () => _showComingSoon('Help center'),
                      ),
                      _buildRow(
                        icon: Icons.forum_outlined,
                        title: 'Community Guidelines',
                        subtitle: 'Learn about our community rules',
                        trailing: _chevronIcon,
                        onTap: () => _showComingSoon('Community guidelines'),
                      ),
                      _buildRow(
                        icon: Icons.info_outline_rounded,
                        title: 'About Asterisk',
                        subtitle: 'Discover more about our app',
                        trailing: _chevronIcon,
                        onTap: _showAboutDialog,
                      ),
                    ]),
                    _buildLogOutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _appearanceLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Matching system';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
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
                'Settings',
                style: AppTypography.title(fontSize: 18, fontWeight: FontWeight.w700, color: contentColor),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F27).withOpacity(0.82) : Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.35 : 0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _handleEditProfile,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Avatar(user: _user, size: 48, showVerificationBadge: false),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Info', style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w700, color: _primaryText)),
                    const SizedBox(height: 2),
                    Text('Update your personal details', style: AppTypography.caption(fontSize: 12, color: _secondaryText)),
                  ],
                ),
              ),
              _chevronIcon,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 21, color: _primaryText),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w600, color: _primaryText)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.caption(fontSize: 12, color: _secondaryText)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _handleLogOutTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1C1F27) : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE0453C)),
              SizedBox(width: 8),
              Text('Log Out', style: TextStyle(color: Color(0xFFE0453C), fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F27).withOpacity(0.82) : Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.35 : 0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 51,
                color: isDark ? const Color(0xFF2B2F3A) : const Color(0xFFF0F0F0),
              ),
          ],
        ],
      ),
    );
  }
}

class _AppearanceSheet extends StatelessWidget {
  final AppThemeController controller;

  const _AppearanceSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 8, 10, bottomInset + 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGrabHandle(),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Material(
                    color: isDark ? const Color(0xFF1C1F27) : Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildOption(context, ThemeMode.system, 'Match System', Icons.brightness_auto_rounded, isDark),
                        _buildDivider(isDark),
                        _buildOption(context, ThemeMode.light, 'Light', Icons.light_mode_rounded, isDark),
                        _buildDivider(isDark),
                        _buildOption(context, ThemeMode.dark, 'Dark', Icons.dark_mode_rounded, isDark),
                      ],
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

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, thickness: 1, color: isDark ? const Color(0xFF2B2F3A) : const Color(0xFFF0F0F0));
  }

  Widget _buildGrabHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(3)),
    );
  }

  Widget _buildOption(BuildContext context, ThemeMode mode, String label, IconData icon, bool isDark) {
    final selected = controller.themeMode == mode;
    final color = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF1A1A1A);

    return InkWell(
      onTap: () {
        controller.setThemeMode(mode);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w500, color: color))),
            if (selected) const Icon(Icons.check_rounded, color: Color(0xFF287BEA), size: 20),
          ],
        ),
      ),
    );
  }
}
