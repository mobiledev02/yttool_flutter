import 'package:flutter/material.dart';
import 'package:yttool_flutter/core/constants/app_constants.dart';
import 'package:yttool_flutter/core/models/channel_model.dart';
import 'package:yttool_flutter/core/services/youtube_api_service.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExploreChannelScreen extends StatefulWidget {
  const ExploreChannelScreen({super.key});

  @override
  State<ExploreChannelScreen> createState() => _ExploreChannelScreenState();
}

class _ExploreChannelScreenState extends State<ExploreChannelScreen> {
  final TextEditingController _urlController = TextEditingController();
  final YouTubeApiService _apiService = YouTubeApiService(
    AppConstants.youtubeApiKey,
  );

  bool _isLoading = false;
  ChannelModel? _channelData;
  String? _errorMessage;

  Future<void> _analyzeChannel() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _channelData = null;
    });

    try {
      // Basic ID extraction (needs improvement for full URL support)
      String channelId = url;
      if (url.contains('channel/')) {
        channelId = url.split('channel/')[1].split('/')[0];
      } else if (url.contains('@')) {
        // Handle handles if API supports it or via search
        // For now, assume ID or direct input
      }

      final channel = await _apiService.getChannelDetails(channelId);
      if (channel == null) {
        throw Exception('Channel not found');
      }

      setState(() {
        _channelData = channel;
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
      appBar: AppBar(title: const Text('Explore Channel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _urlController,
              hintText: 'Enter Channel ID (e.g., UC...)',
              suffixIcon: const Icon(Icons.search),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Analyze Channel',
              onPressed: _analyzeChannel,
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
            if (_channelData != null) _buildResults(_channelData!),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ChannelModel channel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        if (channel.bannerUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: channel.bannerUrl,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(channel.thumbnailUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    channel.customUrl,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Subscribers', channel.subscriberCount),
            _buildStatItem('Total Views', channel.viewCount),
            _buildStatItem('Videos', channel.videoCount),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(channel.description),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
