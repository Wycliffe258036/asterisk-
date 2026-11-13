import 'package:flutter/material.dart';

import 'story_bubble_skeleton.dart';

class StoryRowSkeleton extends StatelessWidget {
  final int itemCount;

  final EdgeInsetsGeometry padding;

  const StoryRowSkeleton({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 103,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(width: 9);
        },
        itemBuilder: (
          context,
          index,
        ) {
          return const StoryBubbleSkeleton();
        },
      ),
    );
  }
}