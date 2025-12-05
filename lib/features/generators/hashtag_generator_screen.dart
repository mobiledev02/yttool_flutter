import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

class HashtagGeneratorScreen extends StatefulWidget {
  const HashtagGeneratorScreen({super.key});

  @override
  State<HashtagGeneratorScreen> createState() => _HashtagGeneratorScreenState();
}

class _HashtagGeneratorScreenState extends State<HashtagGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );

  bool _isLoading = false;
  List<String> _hashtags = [];
  String? _errorMessage;

  Future<void> _generateHashtags() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hashtags = [];
    });

    try {
      // Heuristic: Search for videos, get tags, convert to hashtags
      final videos = await _apiService.searchVideos(topic);

      final Set<String> suggestions = {};

      // Add topic as hashtag
      suggestions.add('#${topic.replaceAll(' ', '')}');

      for (var video in videos) {
        // From title words
        final titleWords = video.title
            .split(' ')
            .where((w) => w.length > 3)
            .map((w) => '#${w.replaceAll(RegExp(r'[^\w]'), '')}')
            .where((t) => t.length > 2) // Filter out short/empty
            .toList();

        suggestions.addAll(titleWords);
      }

      setState(() {
        _hashtags = suggestions.toList().take(30).toList();
      });

      if (_hashtags.isEmpty) {
        _errorMessage = 'No hashtags found. Try a broader topic.';
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyHashtag(String hashtag) {
    Clipboard.setData(ClipboardData(text: hashtag));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$hashtag"')));
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _hashtags.join(' ')));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All hashtags copied!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Hashtag Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _topicController,
              hintText: 'Enter topic (e.g., "Gaming Setup")',
              suffixIcon: const Icon(Icons.numbers),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Generate Hashtags',
              onPressed: _generateHashtags,
              isLoading: _isLoading,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            if (_hashtags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Hashtags (${_hashtags.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy All'),
                    onPressed: _copyAll,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _hashtags
                    .map(
                      (tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () => _copyHashtag(tag),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
