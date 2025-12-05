class VideoModel {
  final String id;
  final String title;
  final String description;
  final String channelId;
  final String channelTitle;
  final List<String> tags;
  final String publishedAt;
  final String duration;
  final String viewCount;
  final String likeCount;
  final String commentCount;
  final Map<String, String> thumbnails;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.channelId,
    required this.channelTitle,
    required this.tags,
    required this.publishedAt,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.thumbnails,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final statistics = json['statistics'] ?? {};
    final contentDetails = json['contentDetails'] ?? {};

    Map<String, String> thumbs = {};
    if (snippet['thumbnails'] != null) {
      snippet['thumbnails'].forEach((key, value) {
        thumbs[key] = value['url'];
      });
    }

    return VideoModel(
      id: json['id'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      channelId: snippet['channelId'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      tags: List<String>.from(snippet['tags'] ?? []),
      publishedAt: snippet['publishedAt'] ?? '',
      duration: contentDetails['duration'] ?? '',
      viewCount: statistics['viewCount'] ?? '0',
      likeCount: statistics['likeCount'] ?? '0',
      commentCount: statistics['commentCount'] ?? '0',
      thumbnails: thumbs,
    );
  }
}
