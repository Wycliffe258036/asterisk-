enum MediaType {
  image,
  video,
}

enum MediaProcessingStatus {
  pending,
  processing,
  ready,
  failed,
}

class Media {
  final String id;
  final MediaType type;

  /// Original/source media.
  final String url;

  /// Optimized delivery URL.
  final String? optimizedUrl;

  /// Preview image.
  final String? thumbnailUrl;

  final int? width;
  final int? height;

  /// width / height
  final double? aspectRatio;

  /// Video duration.
  final int? durationMs;

  final MediaProcessingStatus processingStatus;

  final String? blurHash;

  const Media({
    required this.id,
    required this.type,
    required this.url,
    this.optimizedUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.aspectRatio,
    this.durationMs,
    this.processingStatus = MediaProcessingStatus.ready,
    this.blurHash,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String,
      type: MediaType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => MediaType.image,
      ),
      url: json['url'] as String,
      optimizedUrl: json['optimizedUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
      durationMs: json['durationMs'] as int?,
      processingStatus: MediaProcessingStatus.values.firstWhere(
        (value) => value.name == json['processingStatus'],
        orElse: () => MediaProcessingStatus.ready,
      ),
      blurHash: json['blurHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'optimizedUrl': optimizedUrl,
      'thumbnailUrl': thumbnailUrl,
      'width': width,
      'height': height,
      'aspectRatio': aspectRatio,
      'durationMs': durationMs,
      'processingStatus': processingStatus.name,
      'blurHash': blurHash,
    };
  }
}