import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/models/video_model.dart';
import 'package:yttool_flutter/core/services/storage_service.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoAnalysisScreen extends StatefulWidget {
  final String? initialUrl;
  const VideoAnalysisScreen({super.key, this.initialUrl});

  @override
  State<VideoAnalysisScreen> createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends State<VideoAnalysisScreen> {
  final TextEditingController _urlController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  VideoModel? _videoData;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _analyzeVideo();
    }
  }

  Future<void> _checkFavorite() async {
    if (_videoData != null) {
      final isFav = await _storageService.isFavorite(_urlController.text);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_urlController.text.isNotEmpty && _videoData != null) {
      await _storageService.toggleFavorite(
        _urlController.text,
        _videoData!.title,
      );
      _checkFavorite();
    }
  }

  Future<void> _analyzeVideo() async {
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

      await _storageService.addToHistory(url, video.title);
      await _checkFavorite();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Analysis')),
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
                    ClipboardData? data = await Clipboard.getData(
                      Clipboard.kTextPlain,
                    );

                    if (data != null && data.text != null) {
                      _urlController.text = data.text!;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Analyze Video',
                onPressed: _analyzeVideo,
                isLoading: _isLoading,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_videoData != null) _buildResults(_videoData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(VideoModel video) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl:
                  video.thumbnails['high'] ?? video.thumbnails['medium'] ?? '',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  video.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                ),
                color: _isFavorite ? Theme.of(context).primaryColor : null,
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                video.channelTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              const Icon(Icons.visibility, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${video.viewCount} views',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(Icons.thumb_up, 'Likes', video.likeCount),
          _buildStatRow(Icons.comment, 'Comments', video.commentCount),
          _buildStatRow(
            Icons.calendar_today,
            'Published',
            video.publishedAt.split('T')[0],
          ),
          const SizedBox(height: 24),
          Text(
            'Tags',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: video.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(video.description),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
