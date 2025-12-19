import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';

import '../../core/models/youtube_ai_response.dart';
import '../../core/services/gemini_api_service.dart';
import '../../shared/widgets/input_field.dart';

class GeminiContentGenerator extends StatefulWidget {
  const GeminiContentGenerator({super.key});

  @override
  State<GeminiContentGenerator> createState() => _GeminiContentGeneratorState();
}

class _GeminiContentGeneratorState extends State<GeminiContentGenerator> {
  final TextEditingController _topicController = TextEditingController();

  final RxBool isLoading = false.obs;

  YouTubeAiResponse? data;

  Future<void> _generateContent() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    try {
      isLoading.value = true;
      data = await YouTubeAiService.generateYouTubeMetadata(
        userDescription: _topicController.text.trim(),
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Content Generator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                controller: _topicController,
                hintText: 'Enter topic (e.g., "Gaming Setup")',
                suffixIcon: const Icon(Icons.numbers),
              ),
              const SizedBox(height: 16),
              if (data != null) details(data!),
              Obx(() {
                return (isLoading.value || data == null)
                    ? SizedBox()
                    : details(data!);
              }),

              const SizedBox(height: 24),

              Obx(() {
                return CustomButton(
                  text: 'Generate Hashtags',
                  onPressed: _generateContent,
                  isLoading: isLoading.value,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget details(YouTubeAiResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Language Detected"),
        _value(data.languageDetected),

        _header("Title"),
        _value(data.title),

        _header("Title (English)"),
        _value(data.titleEnglish),

        _header("Short Description"),
        _value(data.shortDescription),

        _header("Description"),
        _value(data.description),

        _header("Description (English)"),
        _value(data.descriptionEnglish),

        _header("Category"),
        _value(data.category),

        _header("Target Audience"),
        _value(data.targetAudience),

        _header("Video Intent"),
        _value(data.videoIntent),

        _header("Tags"),
        _chipWrap(data.tags),

        _header("Hashtags"),
        _chipWrap(data.hashtags),

        _header("Thumbnail Text"),
        _chipWrap(data.thumbnailText),
      ],
    );
  }
}

Widget _header(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _value(String text) {
  return Text(
    text.isEmpty ? "-" : text,
    style: const TextStyle(fontSize: 14, height: 1.4),
  );
}

Widget _chipWrap(List<String> items) {
  if (items.isEmpty) {
    return const Text("-");
  }

  return true
      ? Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(items.join(", ")),
        )
      : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (e) =>
                    Chip(label: Text(e), backgroundColor: Colors.grey.shade200),
              )
              .toList(),
        );
}
