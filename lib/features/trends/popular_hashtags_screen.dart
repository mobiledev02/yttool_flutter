import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PopularHashtagsScreen extends StatefulWidget {
  const PopularHashtagsScreen({super.key});

  @override
  State<PopularHashtagsScreen> createState() => _PopularHashtagsScreenState();
}

class _PopularHashtagsScreenState extends State<PopularHashtagsScreen> {
  final Map<String, List<String>> _categories = {
    'Gaming': [
      '#gaming',
      '#gamer',
      '#ps5',
      '#xbox',
      '#nintendo',
      '#fortnite',
      '#minecraft',
      '#callofduty',
      '#streamer',
      '#esports',
    ],
    'Tech': [
      '#tech',
      '#technology',
      '#gadgets',
      '#iphone',
      '#android',
      '#programming',
      '#coding',
      '#developer',
      '#software',
      '#ai',
    ],
    'Lifestyle': [
      '#lifestyle',
      '#vlog',
      '#dailyvlog',
      '#morningroutine',
      '#productivity',
      '#motivation',
      '#inspiration',
      '#goals',
      '#life',
      '#wellness',
    ],
    'Education': [
      '#education',
      '#learning',
      '#study',
      '#student',
      '#school',
      '#university',
      '#knowledge',
      '#science',
      '#history',
      '#math',
    ],
    'Entertainment': [
      '#entertainment',
      '#funny',
      '#comedy',
      '#memes',
      '#viral',
      '#trending',
      '#music',
      '#movie',
      '#dance',
      '#challenge',
    ],
    'Food': [
      '#food',
      '#foodie',
      '#cooking',
      '#recipe',
      '#baking',
      '#delicious',
      '#yummy',
      '#dinner',
      '#lunch',
      '#breakfast',
    ],
  };

  String _selectedCategory = 'Gaming';

  void _copyHashtag(String hashtag) {
    Clipboard.setData(ClipboardData(text: hashtag));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$hashtag"')));
  }

  void _copyAll() {
    final hashtags = _categories[_selectedCategory] ?? [];
    Clipboard.setData(ClipboardData(text: hashtags.join(' ')));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All hashtags copied!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Hashtags')),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.keys.length,
              itemBuilder: (context, index) {
                final category = _categories.keys.elementAt(index);
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedCategory Hashtags',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_categories[_selectedCategory] ?? []).map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        onPressed: () => _copyHashtag(tag),
                        avatar: const Icon(Icons.copy, size: 14),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
