import 'package:flutter/material.dart';

import '../../../../../theme/app_typography.dart';

/// The "Create with AI" entry point from the Effects PRD: describe an
/// effect in plain language. Generating one needs the AI backend
/// (prompt → effect spec → assets), which isn't built yet, so
/// submitting is an honest placeholder — but the entry point and the
/// shape of the flow are here for when it is.
Future<void> showCreateEffectSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (sheetContext) => _CreateEffectSheet(pageContext: context),
  );
}

class _CreateEffectSheet extends StatefulWidget {
  const _CreateEffectSheet({required this.pageContext});

  /// The context of the page that opened the sheet, used to show the
  /// confirmation snackbar after the sheet itself is dismissed.
  final BuildContext pageContext;

  @override
  State<_CreateEffectSheet> createState() => _CreateEffectSheetState();
}

class _CreateEffectSheetState extends State<_CreateEffectSheet> {
  final TextEditingController _controller = TextEditingController();

  static const _examples = [
    'Blue futuristic sunglasses',
    'A green dinosaur head that roars when I smile',
    'Gold crown with sparkles',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    if (_controller.text.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(widget.pageContext);
    Navigator.of(context).pop();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("AI effect creation isn't connected yet."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1C1F27) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF2F2F4) : const Color(0xFF1A1A1A);
    final secondaryText = isDark ? const Color(0xFFA6AAB8) : const Color(0xFF777777);
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
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCB4CFF),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Create with AI',
                        style: AppTypography.title(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe an effect and AI will build it for your camera. '
                    "Generation isn't connected yet — this is where it will live.",
                    style: AppTypography.body(fontSize: 13, color: secondaryText),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: TextField(
                      controller: _controller,
                      maxLines: 2,
                      minLines: 1,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleGenerate(),
                      style: AppTypography.body(fontSize: 14, color: primaryText),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'e.g. blue futuristic sunglasses',
                        hintStyle: AppTypography.body(fontSize: 14, color: secondaryText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final example in _examples)
                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            _controller.text = example;
                            _controller.selection = TextSelection.collapsed(offset: example.length);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: fieldColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              example,
                              style: AppTypography.caption(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Generate',
                        style: AppTypography.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
