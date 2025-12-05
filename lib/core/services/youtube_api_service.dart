import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yttool_flutter/core/models/video_model.dart';
import 'package:yttool_flutter/core/models/channel_model.dart';

class YouTubeApiService {
  // TODO: Move to secure storage or config
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final String _apiKey;

  YouTubeApiService(this._apiKey);

  Future<VideoModel?> getVideoDetails(String videoId) async {
    final url =
        'https://www.googleapis.com/youtube/v3/videos'
        '?part=snippet,contentDetails,statistics'
        '&id=$videoId'
        '&key=$_apiKey';

    debugPrint('YouTube API URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          return VideoModel.fromJson(data['items'][0]);
        } else {
          // No video found for this ID
          debugPrint('No items returned for videoId: $videoId');
          return null;
        }
      } else {
        // Non-200 → show reason from API
        throw Exception(
          'YouTube API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load video details: $e');
    }
  }

  Future<ChannelModel?> getChannelDetails(String channelId) async {
    final url =
        '$_baseUrl/channels?part=snippet,statistics,brandingSettings&id=$channelId&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return ChannelModel.fromJson(data['items'][0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load channel details: $e');
    }
  }

  Future<List<VideoModel>> searchVideos(String query) async {
    final url =
        '$_baseUrl/search?part=snippet&q=$query&type=video&maxResults=10&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Note: Search endpoint doesn't return full stats, might need secondary call
        // For now, we'll map what we have, but stats will be empty/default
        // A production app would fetch details for these IDs
        List<VideoModel> videos = [];
        if (data['items'] != null) {
          for (var item in data['items']) {
            // We only get snippet here, so we create a partial model
            // Ideally, we should collect IDs and call videos endpoint
            videos.add(
              VideoModel(
                id: item['id']['videoId'],
                title: item['snippet']['title'],
                description: item['snippet']['description'],
                channelId: item['snippet']['channelId'],
                channelTitle: item['snippet']['channelTitle'],
                tags: [],
                publishedAt: item['snippet']['publishedAt'],
                duration: '',
                viewCount: '0',
                likeCount: '0',
                commentCount: '0',
                thumbnails: {
                  'default': item['snippet']['thumbnails']['default']['url'],
                  'medium': item['snippet']['thumbnails']['medium']['url'],
                  'high': item['snippet']['thumbnails']['high']['url'],
                },
              ),
            );
          }
        }
        return videos;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }

  Future<List<VideoModel>> getTrendingVideos() async {
    final url =
        '$_baseUrl/videos?part=snippet,contentDetails,statistics&chart=mostPopular&regionCode=US&maxResults=20&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<VideoModel> videos = [];
        if (data['items'] != null) {
          for (var item in data['items']) {
            videos.add(VideoModel.fromJson(item));
          }
        }
        return videos;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load trending videos: $e');
    }
  }

  String? extractVideoId(String url) {
    RegExp regExp = RegExp(
      r"(?:v=|\/)([0-9A-Za-z_-]{11})(?:\?.*)?$",
      caseSensitive: false,
      multiLine: false,
    );

    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }
}
