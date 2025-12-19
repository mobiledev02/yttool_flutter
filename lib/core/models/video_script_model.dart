class CustVideoScriptModel {
  // final String title;
  // final String estimatedDuration;
  // final List<PersonDialogue> persons;
  final String script;

  CustVideoScriptModel({
    // required this.title,
    // required this.estimatedDuration,
    // required this.persons,
    required this.script,
  });

  // factory CustVideoScriptModel.fromJson(Map<String, dynamic> json) {
  //   return CustVideoScriptModel(
  //     title: json['title'] ?? '',
  //     estimatedDuration: json['estimated_duration'] ?? '',
  //     persons: (json['persons'] as List? ?? [])
  //         .map((e) => PersonDialogue.fromJson(e))
  //         .toList(),
  //   );
  // }
}

String cleanAiScript(String text) {
  String result = text;

  // Remove markdown symbols
  result = result.replaceAll(RegExp(r'\*\*'), '');
  result = result.replaceAll(RegExp(r'###'), '');
  result = result.replaceAll(RegExp(r'##'), '');
  result = result.replaceAll(RegExp(r'#'), '');

  // Remove bullet points & separators
  result = result.replaceAll(RegExp(r'[-•–—]{2,}'), '');
  result = result.replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '');

  // Remove numbered headings like "1. Intro", "2) Body"
  result = result.replaceAll(RegExp(r'^\s*\d+[\.\)]\s*', multiLine: true), '');

  // Remove common AI section labels
  result = result.replaceAll(
    RegExp(
      r'(Hook:|Introduction:|Intro:|Conclusion:|Ending:|Outro:|Body:)',
      caseSensitive: false,
    ),
    '',
  );

  // Normalize excessive new lines
  result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return result.trim();
}

class PersonDialogue {
  final String name;
  final String dialogue;

  PersonDialogue({required this.name, required this.dialogue});

  factory PersonDialogue.fromJson(Map<String, dynamic> json) {
    return PersonDialogue(
      name: json['name'] ?? '',
      dialogue: cleanAiScript(json['dialogue'] ?? ''),
    );
  }
}
