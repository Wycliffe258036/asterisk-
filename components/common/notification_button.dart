import 'package:flutter/material.dart';

class NotificationButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onPressed;
  final double size;
  final Color iconColor;

  const NotificationButton({
    super.key,
    this.unreadCount = 0,
    this.onPressed,
    this.size = 48,
    this.iconColor = const Color(0xFF111111),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: unreadCount > 0
          ? 'Notifications, $unreadCount unread'
          : 'Notifications',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 26,
                  color: iconColor,
                ),

                if (unreadCount > 0) _buildBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Positioned(
      right: 7,
      top: 6,
      child: Container(
        constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
        padding: unreadCount > 9
            ? const EdgeInsets.symmetric(horizontal: 4)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: unreadCount > 9
            ? Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              )
            : const SizedBox(width: 6, height: 6),
      ),
    );
  }
}