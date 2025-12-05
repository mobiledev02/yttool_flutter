import 'package:flutter/material.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/models/video_model.dart';
import 'package:yttool_flutter/core/services/download_service.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ThumbnailDownloaderScreen extends StatefulWidget {
  const ThumbnailDownloaderScreen({super.key});

  @override
  State<ThumbnailDownloaderScreen> createState() =>
      _ThumbnailDownloaderScreenState();
}

class _ThumbnailDownloaderScreenState extends State<ThumbnailDownloaderScreen> {
  final TextEditingController _urlController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );
  final DownloadService _downloadService = DownloadService();

  bool _isLoading = false;
  VideoModel? _videoData;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _fetchThumbnails() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
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

  Future<void> _downloadThumbnail(String url, String quality) async {
    if (_videoData == null) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    final fileName = 'thumbnail_${_videoData!.id}_$quality';
    final success = await _downloadService.downloadAndSaveImage(url, fileName);

    setState(() {
      _isLoading = false;
      if (success) {
        _successMessage = 'Thumbnail saved to gallery!';
      } else {
        _errorMessage = 'Failed to save thumbnail. Check permissions.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thumbnail Downloader')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _urlController,
              hintText: 'Paste YouTube Video URL',
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Get Thumbnails',
              onPressed: _fetchThumbnails,
              isLoading: _isLoading && _videoData == null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
            if (_videoData != null) _buildThumbnailList(_videoData!),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailList(VideoModel video) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...video.thumbnails.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: entry.value,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        onPressed: _isLoading
                            ? null
                            : () => _downloadThumbnail(entry.value, entry.key),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
