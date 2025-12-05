class ChannelModel {
  final String id;
  final String title;
  final String description;
  final String customUrl;
  final String publishedAt;
  final String viewCount;
  final String subscriberCount;
  final String videoCount;
  final String thumbnailUrl;
  final String bannerUrl;

  ChannelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.customUrl,
    required this.publishedAt,
    required this.viewCount,
    required this.subscriberCount,
    required this.videoCount,
    required this.thumbnailUrl,
    required this.bannerUrl,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final statistics = json['statistics'] ?? {};
    final branding = json['brandingSettings'] ?? {};

    return ChannelModel(
      id: json['id'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      customUrl: snippet['customUrl'] ?? '',
      publishedAt: snippet['publishedAt'] ?? '',
      viewCount: statistics['viewCount'] ?? '0',
      subscriberCount: statistics['subscriberCount'] ?? '0',
      videoCount: statistics['videoCount'] ?? '0',
      thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? '',
      bannerUrl: branding['image']?['bannerExternalUrl'] ?? '',
    );
  }
}
