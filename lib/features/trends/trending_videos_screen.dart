import 'package:flutter/material.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/models/video_model.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrendingVideosScreen extends StatefulWidget {
  const TrendingVideosScreen({super.key});

  @override
  State<TrendingVideosScreen> createState() => _TrendingVideosScreenState();
}

class _TrendingVideosScreenState extends State<TrendingVideosScreen> {
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );

  bool _isLoading = true;
  List<VideoModel> _videos = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrendingVideos();
  }

  Future<void> _loadTrendingVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videos = await _apiService.getTrendingVideos();
      setState(() {
        _videos = videos;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending Videos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrendingVideos,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTrendingVideos,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        // Navigate to analysis with this video URL?
                        // Or just show details?
                        // For now, let's just show a snackbar or copy URL
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  video.thumbnails['high'] ??
                                  video.thumbnails['medium'] ??
                                  '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      video.channelTitle,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.visibility,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      video.viewCount,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
