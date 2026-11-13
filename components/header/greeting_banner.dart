import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

class GreetingBanner extends StatelessWidget {
  final String greeting;
  final String subtitle;

  const GreetingBanner({
    super.key,
    required this.greeting,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFF2EDFF),
            Color(0xFFF8F5FF),
            Color(0xFFF0ECFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '👋',
            style: TextStyle(
              fontSize: 28,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF25205B),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    fontSize: 13,
                    color: const Color(0xFF5F5A78),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          const _SparkleDecoration(),
        ],
      ),
    );
  }
}

class _SparkleDecoration extends StatelessWidget {
  const _SparkleDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 7,
            top: 2,
            child: _sparkle(
              size: 15,
              color: const Color(0xFFC9B5FF),
            ),
          ),
          Positioned(
            right: 4,
            top: 11,
            child: _sparkle(
              size: 11,
              color: const Color(0xFFFFA9C8),
            ),
          ),
          Positioned(
            left: 19,
            bottom: 3,
            child: _sparkle(
              size: 10,
              color: const Color(0xFFFFC66E),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 7,
            child: _sparkle(
              size: 16,
              color: const Color(0xFFDE9CFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sparkle({
    required double size,
    required Color color,
  }) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: color,
    );
  }
}