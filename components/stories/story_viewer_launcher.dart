import 'package:flutter/material.dart';

import '../../models/story.dart';
import 'story_viewer.dart';

Future<void> openStoryViewer({
  required BuildContext context,
  required List<Story> stories,
  required int initialIndex,
  ValueChanged<Story>? onStoryViewed,
}) async {
  if (stories.isEmpty) {
    return;
  }

  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true,
      barrierColor: Colors.black,
      transitionDuration:
          const Duration(milliseconds: 250),
      reverseTransitionDuration:
          const Duration(milliseconds: 200),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return StoryViewer(
          stories: stories,
          initialIndex: initialIndex,
          onStoryViewed: onStoryViewed,
        );
      },
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}