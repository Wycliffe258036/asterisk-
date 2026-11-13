import 'package:flutter/material.dart';

import '../../../../models/ad.dart';
import '../../../../models/media.dart';

/// Renders an ad's primary media (the first item in [Ad.media]) as
/// either a plain image or a video-style thumbnail with a play button
/// and, if the ad has audio, a mute/unmute badge.
///
/// [Ad.media] is a list to leave room for future carousel-style ad
/// formats, but only the first item is shown today — matching the
/// singular [AdType] (image or video) already on the ad itself.
class AdMedia extends StatelessWidget {
  final Ad ad;

  /// Aspect ratio to render at when the media itself doesn't specify
  /// one. Ads commonly run wider than organic posts, so this defaults
  /// to a 1.91:1 "link ad" ratio rather than PostCard's 4:5.
  final double aspectRatio;

  const AdMedia({
    super.key,
    required this.ad,
    this.aspectRatio = 1.91,
  });

  @override
  Widget build(BuildContext context) {
    final media = ad.media.isNotEmpty ? ad.media.first : null;

    return AspectRatio(
      aspectRatio: media?.aspectRatio ?? aspectRatio,
      child: media == null ? _buildPlaceholder() : _buildMedia(media),
    );
  }

  Widget _buildMedia(Media media) {
    if (media.type == MediaType.video) {
      return _buildVideo(media);
    }
    return _buildImage(media);
  }

  Widget _buildImage(Media media) {
    return Image.network(
      media.optimizedUrl ?? media.url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          color: const Color(0xFFEFEFEF),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildVideo(Media media) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (media.thumbnailUrl != null)
          Image.network(
            media.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildVideoBackground(),
          )
        else
          _buildVideoBackground(),

        Container(color: Colors.black.withOpacity(0.12)),

        Center(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xAA111111),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),

        if (ad.hasAudio)
          Positioned(
            top: 10,
            right: 10,
            child: _AudioBadge(startsMuted: ad.startsMuted),
          ),
      ],
    );
  }

  Widget _buildVideoBackground() {
    return Container(
      color: const Color(0xFF222222),
      child: const Center(
        child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 44),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFECECEC),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF999999),
          size: 38,
        ),
      ),
    );
  }
}

class _AudioBadge extends StatelessWidget {
  final bool startsMuted;

  const _AudioBadge({required this.startsMuted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
      child: Icon(
        startsMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        color: Colors.white,
        size: 15,
      ),
    );
  }
}
