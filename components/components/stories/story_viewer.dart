import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../models/story.dart';
import '../../../../models/story_group.dart';
import '../../../../models/user.dart';
import '../../../../components/stories/story_progress_bar.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final VoidCallback? onClose;
  final ValueChanged<Story>? onStoryViewed;
  final ValueChanged<Story>? onStoryChanged;

  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onClose,
    this.onStoryViewed,
    this.onStoryChanged,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  // `widget.stories` is grouped by author on entry. Navigation moves
  // through the current group's stories first, then rolls into the
  // next group — so a user's stories always play back to back, and
  // finishing the last group closes the viewer. A caller that only
  // ever passes one user's stories (e.g. tapping a post's avatar) ends
  // up with exactly one group, so it naturally closes as soon as that
  // person's stories are done instead of continuing to anyone else.
  late final List<StoryGroup> _groups;
  late int _currentGroupIndex;
  late int _currentStoryIndex;

  Timer? _timer;
  DateTime? _startedAt;
  Duration _storyDuration = const Duration(seconds: 5);
  Duration _elapsed = Duration.zero;

  VideoPlayerController? _videoController;
  bool _isPaused = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _groups = groupStoriesByUser(widget.stories);
    _setInitialPosition();
    _loadCurrentStory();
  }

  void _setInitialPosition() {
    if (_groups.isEmpty || widget.stories.isEmpty) {
      _currentGroupIndex = 0;
      _currentStoryIndex = 0;
      return;
    }

    final targetIndex =
        widget.initialIndex.clamp(0, widget.stories.length - 1).toInt();
    final targetStoryId = widget.stories[targetIndex].id;

    for (var groupIndex = 0; groupIndex < _groups.length; groupIndex++) {
      final storyIndex = _groups[groupIndex]
          .stories
          .indexWhere((story) => story.id == targetStoryId);

      if (storyIndex != -1) {
        _currentGroupIndex = groupIndex;
        _currentStoryIndex = storyIndex;
        return;
      }
    }

    _currentGroupIndex = 0;
    _currentStoryIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  StoryGroup get _currentGroup => _groups[_currentGroupIndex];

  Story get _currentStory => _currentGroup.stories[_currentStoryIndex];

  Future<void> _loadCurrentStory() async {
    _timer?.cancel();
    await _videoController?.dispose();
    _videoController = null;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isPaused = false;
      _elapsed = Duration.zero;
    });

    final story = _currentStory;
    _updateStory(story.copyWith(viewed: true), notifyViewed: true);

    if (story.mediaType == StoryMediaType.video) {
      await _loadVideoStory();
    } else {
      _storyDuration = const Duration(seconds: 5);
      if (!mounted) return;
      setState(() => _isLoading = false);
      _startTimer();
    }
  }

  Future<void> _loadVideoStory() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_currentStory.mediaUrl),
    );
    _videoController = controller;

    try {
      await controller.initialize();
      _storyDuration = controller.value.duration;
      controller.addListener(_videoListener);
      await controller.play();

      if (!mounted) return;
      setState(() => _isLoading = false);
      _startTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _startTimer();
    }
  }

  void _videoListener() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.position >= controller.value.duration) _goNext();
  }

  void _startTimer() {
    _timer?.cancel();
    _startedAt = DateTime.now().subtract(_elapsed);

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_isPaused || !mounted || _startedAt == null) return;

      final elapsed = DateTime.now().difference(_startedAt!);
      if (elapsed >= _storyDuration) {
        _goNext();
        return;
      }

      setState(() => _elapsed = elapsed);
    });
  }

  void _goNext() {
    _timer?.cancel();

    // More stories left for this person — advance within the group.
    if (_currentStoryIndex < _currentGroup.stories.length - 1) {
      setState(() => _currentStoryIndex++);
      _loadCurrentStory();
      return;
    }

    // This person is done — roll into the next person's stories.
    if (_currentGroupIndex < _groups.length - 1) {
      setState(() {
        _currentGroupIndex++;
        _currentStoryIndex = 0;
      });
      _loadCurrentStory();
      return;
    }

    // Last story of the last person — nothing left to advance to.
    _close();
  }

  void _goPrevious() {
    _timer?.cancel();

    if (_currentStoryIndex > 0) {
      setState(() => _currentStoryIndex--);
      _loadCurrentStory();
      return;
    }

    if (_currentGroupIndex > 0) {
      setState(() {
        _currentGroupIndex--;
        _currentStoryIndex = 0;
      });
      _loadCurrentStory();
      return;
    }

    // Already at the very first story of the very first person —
    // replay it instead of doing nothing.
    _loadCurrentStory();
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    final controller = _videoController;

    if (controller != null && controller.value.isInitialized) {
      if (_isPaused) {
        controller.pause();
      } else {
        controller.play();
        _startedAt = DateTime.now().subtract(_elapsed);
      }
    } else if (!_isPaused) {
      _startedAt = DateTime.now().subtract(_elapsed);
    }
  }

  void _toggleLike() {
    final story = _currentStory;
    final liked = !story.isLiked;
    final updated = story.copyWith(
      isLiked: liked,
      likeCount: liked
          ? story.likeCount + 1
          : (story.likeCount - 1).clamp(0, 999999999),
    );
    _updateStory(updated);
  }

  void _reshareStory() {
    final story = _currentStory;
    _updateStory(
      story.copyWith(reshareCount: story.reshareCount + 1),
    );
  }

  void _updateStory(Story story, {bool notifyViewed = false}) {
    if (!mounted) return;

    setState(() {
      _groups[_currentGroupIndex].stories[_currentStoryIndex] = story;
    });

    widget.onStoryChanged?.call(story);
    if (notifyViewed) widget.onStoryViewed?.call(story);
  }

  void _close() {
    _timer?.cancel();
    widget.onClose?.call();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  double get _progress {
    if (_storyDuration.inMilliseconds <= 0) return 0;
    return (_elapsed.inMilliseconds / _storyDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(),
          _buildTopGradient(),
          _buildTopControls(),
          _buildNavigationAreas(),
          _buildStoryCaption(),
          _buildBottomActions(),
          if (_isPaused) _buildPausedIndicator(),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_currentStory.mediaType == StoryMediaType.video) {
      return _buildVideo();
    }

    return Center(
      child: Image.network(
        _currentStory.mediaUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 48),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildTopGradient() {
    return IgnorePointer(
      child: Container(
        height: 180,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCC000000), Color(0x00000000)],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Column(
          children: [
            Row(
              // One segment per story in the CURRENT person's group
              // only — the strip resets fresh each time playback rolls
              // into the next person, rather than showing every story
              // from every person in the tray as one long ribbon.
              children: List.generate(_currentGroup.stories.length, (index) {
                final state = index < _currentStoryIndex
                    ? StoryProgressState.completed
                    : index == _currentStoryIndex
                        ? StoryProgressState.active
                        : StoryProgressState.upcoming;
                return StoryProgressBar(
                  state: state,
                  progress: index == _currentStoryIndex ? _progress : 0,
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildUserInfo(),
                const Spacer(),
                IconButton(
                  onPressed: _close,
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 29),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _currentStory.user;
    return Row(
      children: [
        _buildAvatar(user),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(user.displayName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                if (user.isVerified) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.verified_rounded, color: Color(0xFF2196F3), size: 15),
                ],
              ],
            ),
            Text('@${user.username}', style: const TextStyle(color: Color(0xBFFFFFFF), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(User user) {
    Widget image;
    if (user.avatarPath != null && user.avatarPath!.isNotEmpty) {
      image = Image.asset(
        user.avatarPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarFromUrl(user),
      );
    } else {
      image = _avatarFromUrl(user);
    }

    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF444444)),
      child: image,
    );
  }

  Widget _avatarFromUrl(User user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return Image.network(
        user.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarFallback(),
      );
    }
    return _avatarFallback();
  }

  Widget _avatarFallback() => const Icon(Icons.person, color: Colors.white);

  Widget _buildNavigationAreas() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _goPrevious,
            onLongPressStart: (_) => _togglePause(),
            onLongPressEnd: (_) => _togglePause(),
            child: const SizedBox.expand(),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _goNext,
            onLongPressStart: (_) => _togglePause(),
            onLongPressEnd: (_) => _togglePause(),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCaption() {
    final caption = _currentStory.caption;
    if (caption == null || caption.trim().isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 20,
      right: 20,
      bottom: 120,
      child: IgnorePointer(
        child: Text(
          caption,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 25,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildAction(
              icon: _currentStory.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              label: _currentStory.likeCount,
              onTap: _toggleLike,
            ),
            const SizedBox(width: 20),
            _buildAction(
              icon: Icons.repeat_rounded,
              label: _currentStory.reshareCount,
              onTap: _reshareStory,
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({required IconData icon, required int label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          if (label > 0) ...[
            const SizedBox(width: 5),
            Text(_formatCount(label), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Widget _buildPausedIndicator() {
    return const Center(
      child: Icon(Icons.pause_circle_filled_rounded, color: Colors.white, size: 58),
    );
  }
}
