class YouTubeAiResponse {
  final String languageDetected;
  final String title;
  final String titleEnglish;
  final String shortDescription;
  final String description;
  final String descriptionEnglish;
  final List<String> tags;
  final List<String> hashtags;
  final String category;
  final String targetAudience;
  final String videoIntent;
  final List<String> thumbnailText;

  YouTubeAiResponse({
    required this.languageDetected,
    required this.title,
    required this.titleEnglish,
    required this.shortDescription,
    required this.description,
    required this.descriptionEnglish,
    required this.tags,
    required this.hashtags,
    required this.category,
    required this.targetAudience,
    required this.videoIntent,
    required this.thumbnailText,
  });

  factory YouTubeAiResponse.fromJson(Map<String, dynamic> json) {
    return YouTubeAiResponse(
      languageDetected: json["language_detected"] ?? "",
      title: json["title"] ?? "",
      titleEnglish: json["title_english"] ?? "",
      shortDescription: json["short_description"] ?? "",
      description: json["description"] ?? "",
      descriptionEnglish: json["description_english"] ?? "",
      tags: List<String>.from(json["tags"] ?? []),
      hashtags: List<String>.from(json["hashtags"] ?? []),
      category: json["category"] ?? "",
      targetAudience: json["target_audience"] ?? "",
      videoIntent: json["video_intent"] ?? "",
      thumbnailText: List<String>.from(json["thumbnail_text"] ?? []),
    );
  }
}
