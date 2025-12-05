import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/models/video_model.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

class TagsExtractorScreen extends StatefulWidget {
  const TagsExtractorScreen({super.key});

  @override
  State<TagsExtractorScreen> createState() => _TagsExtractorScreenState();
}

class _TagsExtractorScreenState extends State<TagsExtractorScreen> {
  final TextEditingController _urlController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );

  bool _isLoading = false;
  VideoModel? _videoData;
  String? _errorMessage;

  Future<void> _extractTags() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _videoData = null;
    });

    try {
      final videoId = _apiService.extractVideoId(url);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      final video = await _apiService.getVideoDetails(videoId);
      if (video == null) {
        throw Exception('Video not found');
      }

      setState(() {
        _videoData = video;
      });
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

  void _copyTags() {
    if (_videoData == null || _videoData!.tags.isEmpty) return;

    final tagsString = _videoData!.tags.join(', ');
    Clipboard.setData(ClipboardData(text: tagsString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All tags copied to clipboard!')),
    );
  }

  void _copyTag(String tag) {
    Clipboard.setData(ClipboardData(text: tag));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Tag "$tag" copied!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags Extractor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                controller: _urlController,
                hintText: 'Paste YouTube Video URL',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    // TODO: Implement paste
                  },
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Extract Tags',
                onPressed: _extractTags,
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
              if (_videoData != null) _buildTagsList(_videoData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsList(VideoModel video) {
    if (video.tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No tags found for this video.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Found ${video.tags.length} Tags',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy All'),
              onPressed: _copyTags,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: video.tags
              .map(
                (tag) => ActionChip(
                  label: Text(tag),
                  avatar: const Icon(Icons.copy, size: 14),
                  onPressed: () => _copyTag(tag),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
