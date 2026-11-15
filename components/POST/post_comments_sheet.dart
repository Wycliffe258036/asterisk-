import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../models/user.dart';
import '../../theme/app_typography.dart';
import '../common/avatar.dart';

/// Shows the post's comments sheet: a title, a comment list area, a row
/// of quick-reaction emoji, and an "Add comment" composer — over a
/// dimmed backdrop, matching the treatment used for the options sheet.
///
/// There's no backend yet, so there are no real comments to show. The
/// list area shows a plain empty state instead of fabricated data, and
/// "posting" a comment shows a short placeholder confirmation rather
/// than actually adding anything.
Future<void> showPostCommentsSheet(
  BuildContext context, {
  required Post post,
  User? currentUser,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // Plain dim scrim, not BackdropFilter — same stability reasoning as
    // the options sheet.
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => _PostCommentsSheet(
      post: post,
      currentUser:
          currentUser ?? const User(id: '', username: '', displayName: 'You'),
    ),
  );
}

class _PostCommentsSheet extends StatefulWidget {
  final Post post;
  final User currentUser;

  const _PostCommentsSheet({
    required this.post,
    required this.currentUser,
  });

  @override
  State<_PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<_PostCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const _quickReactions = ['🎉', '👏', '🤣', '🙌', '💡', '🌟'];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertReaction(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;

    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, emoji);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );

    _focusNode.requestFocus();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    _controller.clear();
    FocusScope.of(context).unfocus();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Comments aren't available yet."),
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
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF888888);
    final dividerColor = isDark ? const Color(0xFF2B2F3A) : const Color(0xFFF0F0F0);
    final fieldColor = isDark ? const Color(0xFF262A34) : const Color(0xFFF3F3F3);
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.82;

    return Padding(
      // Keeps the composer above the keyboard when it opens.
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: sheetColor,
          child: SizedBox(
            height: sheetHeight,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildGrabHandle(),
                  const SizedBox(height: 14),
                  _buildTitle(primaryText),
                  Divider(height: 1, thickness: 1, color: dividerColor),
                  Expanded(child: _buildEmptyState(secondaryText)),
                  _buildQuickReactions(),
                  Divider(height: 1, thickness: 1, color: dividerColor),
                  _buildComposer(fieldColor, primaryText, secondaryText),
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
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF555B68) : const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildTitle(Color primaryText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        'Comments',
        style: AppTypography.title(fontSize: 16, fontWeight: FontWeight.w700, color: primaryText),
      ),
    );
  }

  Widget _buildEmptyState(Color secondaryText) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.mode_comment_outlined,
            size: 34,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 10),
          Text(
            'No comments for now',
            style: AppTypography.body(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final emoji in _quickReactions)
            InkWell(
              onTap: () => _insertReaction(emoji),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComposer(Color fieldColor, Color primaryText, Color secondaryText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Avatar(
            user: widget.currentUser,
            size: 34,
            showVerificationBadge: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
                style: AppTypography.body(fontSize: 14, color: primaryText),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: 'Add comment',
                  hintStyle: AppTypography.body(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: hasText
                    ? IconButton(
                        key: const ValueKey('send'),
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.send_rounded),
                        color: const Color(0xFF287BEA),
                        splashRadius: 20,
                      )
                    : const SizedBox(key: ValueKey('empty'), width: 0),
              );
            },
          ),
        ],
      ),
    );
  }
}