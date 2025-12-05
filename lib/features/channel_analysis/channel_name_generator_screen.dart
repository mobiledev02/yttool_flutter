import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yttool_flutter/shared/widgets/custom_button.dart';
import 'package:yttool_flutter/shared/widgets/input_field.dart';

class ChannelNameGeneratorScreen extends StatefulWidget {
  const ChannelNameGeneratorScreen({super.key});

  @override
  State<ChannelNameGeneratorScreen> createState() =>
      _ChannelNameGeneratorScreenState();
}

class _ChannelNameGeneratorScreenState
    extends State<ChannelNameGeneratorScreen> {
  final TextEditingController _nicheController = TextEditingController();

  bool _isLoading = false;
  List<String> _names = [];
  String? _errorMessage;

  Future<void> _generateNames() async {
    final niche = _nicheController.text.trim();
    if (niche.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _names = [];
    });

    // Simulate AI delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final List<String> generatedNames = [
        '${niche}Mastery',
        'The${niche}Hub',
        '${niche}Insider',
        'Daily$niche',
        '${niche}Unleashed',
        'Purely$niche',
        '${niche}Vibes',
        'The${niche}Chronicles',
        '${niche}Lab',
        '${niche}Central',
        'Beyond$niche',
        '${niche}Focus',
        'Smart$niche',
        '${niche}Pro',
        '${niche}Tube',
      ];

      setState(() {
        _names = generatedNames;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate names.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyName(String name) {
    Clipboard.setData(ClipboardData(text: name));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$name"')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel Name Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              controller: _nicheController,
              hintText: 'Enter niche (e.g., "Tech", "Gaming")',
              suffixIcon: const Icon(Icons.branding_watermark),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Generate Names',
              onPressed: _generateNames,
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
            if (_names.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Generated Names (${_names.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _names.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final name = _names[index];
                  return ListTile(
                    title: Text(name),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyName(name),
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
