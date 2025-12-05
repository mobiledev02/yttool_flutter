import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

class TitleGeneratorScreen extends StatefulWidget {
  const TitleGeneratorScreen({super.key});

  @override
  State<TitleGeneratorScreen> createState() => _TitleGeneratorScreenState();
}

class _TitleGeneratorScreenState extends State<TitleGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _titles = [];
  String? _errorMessage;

  Future<void> _generateTitles() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _titles = [];
    });

    // Simulate AI delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final List<Map<String, dynamic>> generatedTitles = [
        {
          'title': 'How to Master $topic in 2024',
          'score': 95,
          'type': 'Educational',
        },
        {
          'title': '10 Secrets About $topic You Didn\'t Know',
          'score': 92,
          'type': 'Listicle',
        },
        {
          'title': 'Why $topic is Changing Everything',
          'score': 88,
          'type': 'Curiosity',
        },
        {'title': 'The Ultimate Guide to $topic', 'score': 85, 'type': 'Guide'},
        {
          'title': 'Stop Doing This With $topic!',
          'score': 90,
          'type': 'Warning',
        },
        {
          'title': '$topic Explained in 5 Minutes',
          'score': 87,
          'type': 'Speed',
        },
        {
          'title': 'I Tried $topic for 30 Days',
          'score': 89,
          'type': 'Challenge',
        },
        {'title': 'Is $topic Worth It?', 'score': 86, 'type': 'Review'},
      ];

      setState(() {
        _titles = generatedTitles;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate titles.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyTitle(String title) {
    Clipboard.setData(ClipboardData(text: title));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$title"')));
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Title Generator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputField(
                controller: _topicController,
                hintText: 'Enter video topic',
                suffixIcon: const Icon(Icons.title),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Generate Titles',
                onPressed: _generateTitles,
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
              if (_titles.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Generated Titles (${_titles.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _titles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _titles[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['type'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item['title'].length} chars',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getScoreColor(
                                  item['score'],
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${item['score']}',
                                style: TextStyle(
                                  color: _getScoreColor(item['score']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyTitle(item['title']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
