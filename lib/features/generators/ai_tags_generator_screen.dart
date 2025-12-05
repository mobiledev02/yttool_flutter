import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

class AiTagsGeneratorScreen extends StatefulWidget {
  const AiTagsGeneratorScreen({super.key});

  @override
  State<AiTagsGeneratorScreen> createState() => _AiTagsGeneratorScreenState();
}

class _AiTagsGeneratorScreenState extends State<AiTagsGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );

  bool _isLoading = false;
  List<String> _tags = [];
  String? _errorMessage;

  Future<void> _generateTags() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _tags = [];
    });

    try {
      // Heuristic: Search for videos, get tags from top videos
      final videos = await _apiService.searchVideos(topic);

      final Set<String> suggestions = {};

      // Add topic variations
      suggestions.add(topic);
      suggestions.add(topic.toLowerCase());

      for (var video in videos) {
        // Extract words from title
        final titleWords = video.title
            .split(' ')
            .where((w) => w.length > 3)
            .map((w) => w.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase())
            .toList();

        suggestions.addAll(titleWords);

        // In a real app with full video details, we would add video.tags here
        // But search API doesn't return tags, so we rely on titles for now
      }

      setState(() {
        _tags = suggestions.toList().take(40).toList();
      });

      if (_tags.isEmpty) {
        _errorMessage = 'No tags found. Try a broader topic.';
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

  void _copyTag(String tag) {
    Clipboard.setData(ClipboardData(text: tag));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$tag"')));
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _tags.join(',')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All tags copied (comma separated)!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tags Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _topicController,
              hintText: 'Enter topic (e.g., "Flutter State Management")',
              suffixIcon: const Icon(Icons.tag),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Generate Tags',
              onPressed: _generateTags,
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
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Tags (${_tags.length})',
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
                children: _tags
                    .map(
                      (tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () => _copyTag(tag),
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
