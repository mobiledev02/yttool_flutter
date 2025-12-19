import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/gemini_api_service.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/input_field.dart';
import '../../core/models/video_script_model.dart';

/// ------------------------------------------------------
/// ENUM : VIDEO PURPOSE
/// ------------------------------------------------------
enum VideoPurpose {
  education,
  comedy,
  motivational,
  fun,
  storytelling,
  devotional,
}

/// ------------------------------------------------------
/// MODEL : VIDEO SCRIPT
/// ------------------------------------------------------
class VideoScriptModel {
  final String title;
  final String estimatedDuration;
  final String script;

  VideoScriptModel({
    required this.title,
    required this.estimatedDuration,
    required this.script,
  });

  factory VideoScriptModel.fromJson(Map<String, dynamic> json) {
    return VideoScriptModel(
      title: json['title'] ?? '',
      estimatedDuration: json['estimated_duration'] ?? '',
      script: json['script'] ?? '',
    );
  }
}

/// ------------------------------------------------------
/// VIEW
/// ------------------------------------------------------
class GeminiScriptGeneratorView extends StatefulWidget {
  const GeminiScriptGeneratorView({super.key});

  @override
  State<GeminiScriptGeneratorView> createState() =>
      _GeminiScriptGeneratorViewState();
}

class _GeminiScriptGeneratorViewState extends State<GeminiScriptGeneratorView> {
  final TextEditingController _topicController = TextEditingController();

  final RxBool isLoading = false.obs;

  VideoPurpose selectedPurpose = VideoPurpose.education;

  List<CustVideoScriptModel> scripts = [];

  /// ------------------------------------------------------
  /// GENERATE SCRIPTS
  /// ------------------------------------------------------
  Future<void> _generateScripts() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    try {
      isLoading.value = true;

      final result = await YouTubeAiService.generateVideoScripts(
        topic: topic,
        purpose: selectedPurpose.name,
      );

      scripts = result;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar(
        'Error',
        'Failed to generate scripts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ------------------------------------------------------
  /// UI
  /// ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Video Script Generator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Topic Input
              InputField(
                controller: _topicController,
                hintText: 'Enter video topic (e.g. Bhagavad Gita Chapter 1)',
                suffixIcon: const Icon(Icons.topic),
              ),

              const SizedBox(height: 20),

              _sectionHeader('Select Video Purpose'),
              const SizedBox(height: 8),
              _purposeSelector(),

              const SizedBox(height: 28),

              Obx(() {
                return CustomButton(
                  text: 'Generate 15-Minute Scripts',
                  onPressed: _generateScripts,
                  isLoading: isLoading.value,
                );
              }),

              const SizedBox(height: 24),

              if (scripts.isNotEmpty) _scriptList(),
            ],
          ),
        ),
      ),
    );
  }

  /// ------------------------------------------------------
  /// PURPOSE SELECTOR
  /// ------------------------------------------------------
  Widget _purposeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: VideoPurpose.values.map((purpose) {
        final bool isSelected = purpose == selectedPurpose;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPurpose = purpose;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              purpose.name.capitalizeFirst!,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// ------------------------------------------------------
  /// SCRIPT LIST UI
  /// ------------------------------------------------------
  Widget _scriptList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Generated Scripts'),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scripts.length,
          itemBuilder: (context, index) {
            final script = scripts[index];
            return Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Script ${index + 1}: ${script.title}',
                  //   style: const TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 6),
                  // Text(
                  //   'Estimated Duration: ${script.estimatedDuration}',
                  //   style: const TextStyle(fontSize: 12),
                  // ),
                  // const Divider(height: 20),
                  // ListView.separated(
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   itemCount: script.persons.length,
                  //   itemBuilder: (context, index) {
                  //     final person = script.persons[index];
                  //     return Text(
                  //       '${person.name}: ${person.dialogue}',
                  //       style: const TextStyle(fontSize: 14, height: 1.5),
                  //     );
                  //   },
                  //   separatorBuilder: (context, index) {
                  //     return const SizedBox(height: 10);
                  //   },
                  // ),
                  Text(
                    script.script,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// ------------------------------------------------------
  /// HELPERS
  /// ------------------------------------------------------
  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
