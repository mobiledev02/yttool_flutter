import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:yttool_flutter/core/constants/app_colors.dart';
import 'package:yttool_flutter/features/channel_analysis/channel_name_generator_screen.dart';
import 'package:yttool_flutter/features/channel_analysis/channel_name_ideas_screen.dart';
import 'package:yttool_flutter/features/channel_analysis/earning_calculator_screen.dart';
import 'package:yttool_flutter/features/channel_analysis/explore_channel_screen.dart';
import 'package:yttool_flutter/features/channel_analysis/find_competitor_screen.dart';
import 'package:yttool_flutter/features/generators/ai_tags_generator_screen.dart';
import 'package:yttool_flutter/features/generators/gemini_content_generator.dart';
import 'package:yttool_flutter/features/generators/hashtag_generator_screen.dart';
import 'package:yttool_flutter/features/generators/keyword_suggestion_screen.dart';
import 'package:yttool_flutter/features/generators/title_generator_screen.dart';
import 'package:yttool_flutter/features/home/saved_screen.dart';
import 'package:yttool_flutter/features/home/widgets/tool_card.dart';
import 'package:yttool_flutter/features/home/settings_screen.dart';
import 'package:yttool_flutter/features/trends/popular_hashtags_screen.dart';
import 'package:yttool_flutter/features/trends/trending_videos_screen.dart';
import 'package:yttool_flutter/features/video_analysis/tags_extractor_screen.dart';
import 'package:yttool_flutter/features/video_analysis/thumbnail_downloader_screen.dart';
import 'package:yttool_flutter/features/video_analysis/video_analysis_screen.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

import '../../core/models/youtube_ai_response.dart';
import '../../core/services/gemini_api_service.dart';
import '../generators/video_script_generator.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);

  final List<Map<String, dynamic>> _allTools = [
    {
      'title': 'Gemini Content Gen',
      'icon': Icons.auto_awesome,
      'route': '/gemini-content-gen',
      'color': Colors.yellow,
    },
    {
      'title': 'Gemini Content Gen',
      'icon': Icons.subscriptions_rounded,
      'route': '/gemini-video-script-gen',
      'color': Colors.cyan,
    },

    {
      'title': 'Video Analysis',
      'icon': Icons.analytics,
      'route': '/video-analysis',
      'color': Colors.blue,
    },
    {
      'title': 'Tags Extractor',
      'icon': Icons.tag,
      'route': '/tags-extractor',
      'color': Colors.green,
    },
    {
      'title': 'Keyword Suggest',
      'icon': Icons.search,
      'route': '/keyword-suggest',
      'color': Colors.orange,
    },
    {
      'title': 'Hashtag Gen',
      'icon': Icons.numbers,
      'route': '/hashtag-gen',
      'color': Colors.purple,
    },
    {
      'title': 'AI Tags Gen',
      'icon': Icons.auto_awesome,
      'route': '/ai-tags-gen',
      'color': Colors.teal,
    },
    {
      'title': 'Channel Name',
      'icon': Icons.branding_watermark,
      'route': '/channel-name',
      'color': Colors.indigo,
    },
    {
      'title': 'Title Gen',
      'icon': Icons.title,
      'route': '/title-gen',
      'color': Colors.deepOrange,
    },
    {
      'title': 'Popular Hashtags',
      'icon': Icons.trending_up,
      'route': '/popular-hashtags',
      'color': Colors.pink,
    },
    {
      'title': 'Explore Channel',
      'icon': Icons.person_search,
      'route': '/explore-channel',
      'color': Colors.cyan,
    },
    {
      'title': 'Trending Videos',
      'icon': Icons.whatshot,
      'route': '/trending',
      'color': Colors.red,
    },
    {
      'title': 'Competitor',
      'icon': Icons.compare_arrows,
      'route': '/competitor',
      'color': Colors.amber,
    },
    {
      'title': 'Name Ideas',
      'icon': Icons.lightbulb,
      'route': '/name-ideas',
      'color': Colors.yellow,
    },
    {
      'title': 'Earning Calc',
      'icon': Icons.attach_money,
      'route': '/earning-calc',
      'color': Colors.lightGreen,
    },
    {
      'title': 'Thumbnail Downloader',
      'icon': Icons.image,
      'route': '/thumbnail',
      'color': Colors.orange,
    },
  ];

  RxBool isLoading = false.obs;

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _controller.jumpTo(index);
        },
        children: [
          Obx(() {
            return Stack(
              children: [
                _buildHomeTab(),
                if (isLoading.value)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: SpinKitSpinningCircle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SavedScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_filled, color: Colors.white24),
            activeItem: Icon(Icons.home_filled, color: AppColors.primary),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.bookmark, color: Colors.white24),
            activeItem: Icon(Icons.bookmark, color: Colors.orange),
            itemLabel: 'Saved',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.history, color: Colors.white24),
            activeItem: Icon(Icons.history, color: Colors.blue),
            itemLabel: 'History',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.settings, color: Colors.white24),
            activeItem: Icon(Icons.settings, color: Colors.green),
            itemLabel: 'Settings',
          ),
        ],
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        },
        kIconSize: 24.0,
      ),
    );
  }

  Widget _buildHomeTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          surfaceTintColor: AppColors.primary,
          title: Text(
            'YT Tool',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: InputField(
                            hintText: 'Enter video or channel URL',
                            suffixIcon: Icon(Icons.search),
                            onSubmitted: (value) async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoAnalysisScreen(initialUrl: value),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Popular Tools',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 140,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            children: [
                              Gap(14),
                              SizedBox(
                                width: 120,
                                child: ToolCard(
                                  title: 'Video Analysis',
                                  icon: Icons.analytics,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const VideoAnalysisScreen(),
                                      ),
                                    );
                                  },
                                  iconColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 120,
                                child: ToolCard(
                                  title: 'Thumbnail Downloader',
                                  icon: Icons.image,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ThumbnailDownloaderScreen(),
                                      ),
                                    );
                                  },
                                  iconColor: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 120,
                                child: ToolCard(
                                  title: 'Tags Extractor',
                                  icon: Icons.tag,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TagsExtractorScreen(),
                                      ),
                                    );
                                  },
                                  iconColor: Colors.green,
                                ),
                              ),
                              Gap(16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            'All Tools',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 0),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.86,
                        ),
                    itemCount: _allTools.length,
                    itemBuilder: (context, index) {
                      final tool = _allTools[index];

                      return ToolCard(
                        title: tool['title'],
                        icon: tool['icon'],
                        iconColor: tool['color'],
                        onTap: () {
                          final route = tool['route'];

                          if (route == '/video-analysis') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VideoAnalysisScreen(),
                              ),
                            );
                          } else if (route == '/thumbnail') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ThumbnailDownloaderScreen(),
                              ),
                            );
                          } else if (route == '/tags-extractor') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TagsExtractorScreen(),
                              ),
                            );
                          } else if (route == '/keyword-suggest') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KeywordSuggestionScreen(),
                              ),
                            );
                          } else if (route == '/hashtag-gen') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HashtagGeneratorScreen(),
                              ),
                            );
                          } else if (route == '/ai-tags-gen') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AiTagsGeneratorScreen(),
                              ),
                            );
                          } else if (route == '/title-gen') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TitleGeneratorScreen(),
                              ),
                            );
                          } else if (route == '/channel-name') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ChannelNameGeneratorScreen(),
                              ),
                            );
                          } else if (route == '/explore-channel') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExploreChannelScreen(),
                              ),
                            );
                          } else if (route == '/trending') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TrendingVideosScreen(),
                              ),
                            );
                          } else if (route == '/popular-hashtags') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PopularHashtagsScreen(),
                              ),
                            );
                          } else if (route == '/earning-calc') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EarningCalculatorScreen(),
                              ),
                            );
                          } else if (route == '/competitor') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FindCompetitorScreen(),
                              ),
                            );
                          } else if (route == '/name-ideas') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChannelNameIdeasScreen(),
                              ),
                            );
                          } else if (route == '/gemini-content-gen') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GeminiContentGenerator(),
                              ),
                            );
                          } else if (route == '/gemini-video-script-gen') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GeminiScriptGeneratorView(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Feature ${tool['title']} coming soon!',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
