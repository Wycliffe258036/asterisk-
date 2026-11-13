import 'package:flutter/material.dart';

enum StoryProgressState {
  completed,
  active,
  upcoming,
}

class StoryProgressBar extends StatelessWidget {
  final StoryProgressState state;
  final double progress;

  const StoryProgressBar({
    super.key,
    required this.state,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: _widthFactor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get _widthFactor {
    switch (state) {
      case StoryProgressState.completed:
        return 1;

      case StoryProgressState.active:
        return progress.clamp(0, 1);

      case StoryProgressState.upcoming:
        return 0;
    }
  }
}