import 'package:flutter/material.dart';

class ChannelNameIdeasScreen extends StatelessWidget {
  const ChannelNameIdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel Name Ideas')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            'Naming Strategies',
            'Choose a name that reflects your content and personality.',
            [
              'Use your own name (e.g., Casey Neistat)',
              'Descriptive names (e.g., TechCrunch)',
              'Abstract/Creative (e.g., PewDiePie)',
              'Combine words (e.g., MrBeast)',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Tips for Success',
            'Keep these in mind when choosing:',
            [
              'Keep it short and memorable',
              'Easy to spell and pronounce',
              'Check availability across social media',
              'Avoid numbers unless meaningful',
              'Think about future growth',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Common Patterns',
            'Popular structures used by top channels:',
            [
              '[Name] + [Niche] (e.g., Marques Brownlee Tech)',
              'The [Adjective] [Noun]',
              '[Action] with [Name]',
              '[Topic] Daily/Central/Hub',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String subtitle,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
