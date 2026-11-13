import 'package:flutter/material.dart';

class PostSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const PostSkeleton({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(14, 0, 14, 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF1C1F27).withOpacity(0.82)
        : Colors.white.withOpacity(0.90);
    final block = isDark ? const Color(0xFF2B2F3A) : const Color(0xFFE8E8E8);
    final blockLight = isDark ? const Color(0xFF262A34) : const Color(0xFFF1F1F1);
    final mediaBlock = isDark ? const Color(0xFF23262F) : const Color(0xFFECECEC);

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(shape: BoxShape.circle, color: block),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: double.infinity, color: block),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 90, color: blockLight),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 220,
              width: double.infinity,
              color: mediaBlock,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(width: 28, height: 14, color: block),
              const SizedBox(width: 8),
              Container(width: 28, height: 14, color: block),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 14, color: blockLight)),
            ],
          ),

          const SizedBox(height: 8),

          Container(height: 12, width: double.infinity, color: blockLight),
        ],
      ),
    );
  }
}