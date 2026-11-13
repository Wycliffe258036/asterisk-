import 'package:flutter/material.dart';

import '../../../../models/user.dart';
import '../../../../theme/app_typography.dart';
import '../../../../components/common/Avatar.dart';

/// Shows a lightweight profile editor: display name and bio. Editing
/// those is just local state, so saving genuinely updates the user —
/// changing the avatar photo would need an image picker/upload
/// pipeline, so that stays a placeholder.
Future<void> showEditProfileSheet(
  BuildContext context, {
  required User user,
  required ValueChanged<User> onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => _EditProfileSheet(user: user, onSave: onSave),
  );
}

class _EditProfileSheet extends StatefulWidget {
  final User user;
  final ValueChanged<User> onSave;

  const _EditProfileSheet({required this.user, required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final trimmedName = _nameController.text.trim();

    final updated = widget.user.copyWith(
      displayName: trimmedName.isEmpty ? widget.user.displayName : trimmedName,
      bio: _bioController.text.trim(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  void _handleChangePhoto() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Changing your photo isn't available yet."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1C1F27) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF1A1A1A);
    final fieldColor = isDark ? const Color(0xFF262A34) : const Color(0xFFF3F3F3);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: sheetColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildGrabHandle()),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Edit Profile',
                        style: AppTypography.title(fontSize: 17, fontWeight: FontWeight.w700, color: primaryText),
                      ),
                      const Spacer(),
                      TextButton(onPressed: _handleSave, child: const Text('Save')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: _handleChangePhoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Avatar(user: widget.user, size: 84, showVerificationBadge: false),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Color(0xFF111111), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Name', style: AppTypography.caption(fontSize: 12, fontWeight: FontWeight.w600, color: primaryText)),
                  const SizedBox(height: 6),
                  _buildField(_nameController, fieldColor, primaryText, 'Your name'),
                  const SizedBox(height: 16),
                  Text('Bio', style: AppTypography.caption(fontSize: 12, fontWeight: FontWeight.w600, color: primaryText)),
                  const SizedBox(height: 6),
                  _buildField(_bioController, fieldColor, primaryText, 'Tell people about yourself', maxLines: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrabHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(3)),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    Color fieldColor,
    Color textColor,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.body(fontSize: 14, color: textColor),
        decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: hint),
      ),
    );
  }
}
