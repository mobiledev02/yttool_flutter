import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

class KeywordSuggestionScreen extends StatefulWidget {
  const KeywordSuggestionScreen({super.key});

  @override
  State<KeywordSuggestionScreen> createState() =>
      _KeywordSuggestionScreenState();
}

class _KeywordSuggestionScreenState extends State<KeywordSuggestionScreen> {
  final TextEditingController _topicController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );

  bool _isLoading = false;
  List<String> _keywords = [];
  String? _errorMessage;

  Future<void> _generateKeywords() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _keywords = [];
    });

    try {
      // Use search API to find related videos and extract titles/keywords
      // This is a heuristic approach since we don't have a direct keyword API
      final videos = await _apiService.searchVideos(topic);

      final Set<String> suggestions = {};

      // Add the topic itself
      suggestions.add(topic);

      for (var video in videos) {
        // Extract words from title
        final titleWords = video.title
            .split(' ')
            .where((w) => w.length > 3)
            .map((w) => w.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase())
            .toList();

        suggestions.addAll(titleWords);

        // Add full title as a long-tail keyword
        if (video.title.length < 50) {
          suggestions.add(video.title);
        }
      }

      setState(() {
        _keywords = suggestions.toList().take(20).toList(); // Limit to 20
      });

      if (_keywords.isEmpty) {
        _errorMessage = 'No keywords found. Try a broader topic.';
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

  void _copyKeyword(String keyword) {
    Clipboard.setData(ClipboardData(text: keyword));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$keyword"')));
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _keywords.join(', ')));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All keywords copied!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyword Suggestion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _topicController,
              hintText: 'Enter topic (e.g., "Flutter Tutorial")',
              suffixIcon: const Icon(Icons.search),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Generate Keywords',
              onPressed: _generateKeywords,
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
            if (_keywords.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggestions (${_keywords.length})',
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _keywords.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final keyword = _keywords[index];
                  return ListTile(
                    title: Text(keyword),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyKeyword(keyword),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
