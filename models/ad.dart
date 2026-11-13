import 'media.dart';

enum AdSource {
  internal,
  externalApi,
}

enum AdType {
  image,
  video,
}

enum AdAction {
  openWebsite,
  openApp,
  openProfile,
  openStore,
  openDeepLink,
}

class Ad {
  final String id;

  /// Advertiser information.
  final String advertiserName;
  final String? advertiserLogoUrl;

  /// Optional agency/campaign information.
  final String? agencyId;
  final String? campaignId;

  final AdSource source;
  final AdType type;

  final List<Media> media;

  final String? headline;
  final String? body;
  final String? callToAction;

  /// Where the user goes when interacting with the advertisement.
  final String destinationUrl;

  final AdAction action;

  /// Whether the ad has background audio.
  final bool hasAudio;

  /// Whether the audio starts muted.
  final bool startsMuted;

  /// Label displayed to users.
  final String disclosureLabel;

  final DateTime? startDate;
  final DateTime? endDate;

  const Ad({
    required this.id,
    required this.advertiserName,
    this.advertiserLogoUrl,
    this.agencyId,
    this.campaignId,
    required this.source,
    required this.type,
    this.media = const [],
    this.headline,
    this.body,
    this.callToAction,
    required this.destinationUrl,
    this.action = AdAction.openWebsite,
    this.hasAudio = false,
    this.startsMuted = true,
    this.disclosureLabel = 'Sponsored',
    this.startDate,
    this.endDate,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] as String,
      advertiserName: json['advertiserName'] as String,
      advertiserLogoUrl: json['advertiserLogoUrl'] as String?,
      agencyId: json['agencyId'] as String?,
      campaignId: json['campaignId'] as String?,
      source: AdSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => AdSource.internal,
      ),
      type: AdType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => AdType.image,
      ),
      media: (json['media'] as List<dynamic>? ?? [])
          .map(
            (item) => Media.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      headline: json['headline'] as String?,
      body: json['body'] as String?,
      callToAction: json['callToAction'] as String?,
      destinationUrl: json['destinationUrl'] as String,
      action: AdAction.values.firstWhere(
        (value) => value.name == json['action'],
        orElse: () => AdAction.openWebsite,
      ),
      hasAudio: json['hasAudio'] as bool? ?? false,
      startsMuted: json['startsMuted'] as bool? ?? true,
      disclosureLabel:
          json['disclosureLabel'] as String? ?? 'Sponsored',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advertiserName': advertiserName,
      'advertiserLogoUrl': advertiserLogoUrl,
      'agencyId': agencyId,
      'campaignId': campaignId,
      'source': source.name,
      'type': type.name,
      'media': media.map((item) => item.toJson()).toList(),
      'headline': headline,
      'body': body,
      'callToAction': callToAction,
      'destinationUrl': destinationUrl,
      'action': action.name,
      'hasAudio': hasAudio,
      'startsMuted': startsMuted,
      'disclosureLabel': disclosureLabel,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}