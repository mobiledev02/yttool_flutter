import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/video_script_model.dart';
import '../models/youtube_ai_response.dart';

class YouTubeAiService {
  // આ વિડિયો ભગવાન શિવની મહિમા અને મહાશિવરાત્રી વિશે છે
  static const String _apiKey = "AIzaSyBGvYUoPF_kQait8PuizQsDSelCUqhapc0";

  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_apiKey";

  /// Main method
  static Future<YouTubeAiResponse> generateYouTubeMetadata({
    required String userDescription,
  }) async {
    final prompt = _buildPrompt(userDescription);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topP": 0.9,
          "maxOutputTokens": 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Gemini API failed: ${response.statusCode} ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    final rawText = decoded["candidates"][0]["content"]["parts"][0]["text"];

    // Gemini sometimes wraps JSON in ```json ``` blocks
    final cleanJson = _extractJson(rawText);

    return YouTubeAiResponse.fromJson(jsonDecode(cleanJson));
  }

  // ------------------------------------------------------
  // PROMPT
  // ------------------------------------------------------

  static String _buildPrompt(String userText) {
    return """
You are a YouTube content optimization expert.

The user has written a video description in their own language.
Understand the topic, intent, and purpose regardless of language.

User input:
\"\"\"
$userText
\"\"\"

Generate the following:

1. Video Title (SEO-friendly, max 60 characters)
2. Video Description (engaging, SEO-optimized)
3. Short Description
4. YouTube Tags (comma-separated)
5. Hashtags (8–15)
6. Video Category
7. Target Audience
8. Video Intent
9. Suggested Thumbnail Text
10. Language detected

Rules:
- Preserve original language
- Also provide English-optimized title & description
- No emojis in title
- Avoid clickbait
- YouTube policy safe

Return ONLY valid JSON in this format:

{
  "language_detected": "",
  "title": "",
  "title_english": "",
  "short_description": "",
  "description": "",
  "description_english": "",
  "tags": [],
  "hashtags": [],
  "category": "",
  "target_audience": "",
  "video_intent": "",
  "thumbnail_text": []
}
""";
  }

  // ------------------------------------------------------
  // JSON CLEANER
  // ------------------------------------------------------

  static String _extractJson(String text) {
    // Remove markdown/code fences
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();

    final start = text.indexOf('{');
    if (start == -1) {
      throw Exception("No JSON object found in response");
    }

    // Trim everything before first {
    text = text.substring(start);

    int curly = 0;
    int square = 0;
    bool started = false;

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '{') {
        curly++;
        started = true;
      }
      if (char == '}') curly--;
      if (char == '[') square++;
      if (char == ']') square--;

      if (started) buffer.write(char);

      // Stop when JSON structure is complete
      if (started && curly == 0 && square == 0) {
        break;
      }
    }

    final result = buffer.toString().trim();

    // ❌ DO NOT manually validate with startsWith / endsWith
    // ✅ Let jsonDecode validate it

    return result;
  }

  //!  -------------------- Video script generator ---------------------

  /// ------------------------------------------------------
  /// 15-MIN VIDEO SCRIPT GENERATOR
  /// ------------------------------------------------------
  ///
  ///
  static Future<List<CustVideoScriptModel>> generateVideoScripts({
    required String topic,
    required String purpose, // education, comedy, motivational, etc.
    int numberOfPersons = 2, // 1, 2, 3, 4...
  }) async {
    final prompt =
        """
You are a professional YouTube storyteller.

Topic:
"$topic"

Purpose:
"$purpose"

Number of persons:
$numberOfPersons

Rules:
- Detect the language of the topic.
- Write EVERYTHING in the SAME language.
- Create UP TO 10 complete stories.
- Each story is suitable for a ~15 minute video.
- Person-wise dialogue (Person 1, Person 2, etc.).
- Natural spoken language.
- NO markdown, NO symbols, NO bullets.

VERY IMPORTANT:
- Separate each story using this exact delimiter:

=== STORY BREAK ===

Return ONLY the scripts.
Do NOT return JSON.
Do NOT add explanations.
""";

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.85,
          "topP": 0.9,
          "maxOutputTokens": 4096,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Gemini API failed: ${response.statusCode} ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);
    final rawText = decoded["candidates"][0]["content"]["parts"][0]["text"];

    final List<String> stories = rawText
        .split("=== STORY BREAK ===")
        .where((String e) => e.isNotEmpty)
        .toList();

    // final cleanJson = _extractJson(rawText);

    // final decodedJson = safeJsonDecode(cleanJson);

    // if (!decodedJson.containsKey("stories")) {
    //   throw Exception("Gemini response does not contain stories");
    // }

    // final List list = decodedJson["stories"];

    return stories.map((e) => CustVideoScriptModel(script: e)).toList();
  }

  static Map<String, dynamic> safeJsonDecode(String json) {
    try {
      return jsonDecode(json);
    } catch (_) {
      // Try to salvage by trimming incomplete array item
      final int lastCompleteBrace = json.lastIndexOf('}');
      if (lastCompleteBrace == -1) {
        throw Exception("Unable to recover JSON");
      }

      final trimmed = json.substring(0, lastCompleteBrace + 1);

      // Close arrays & objects safely
      String fixed = trimmed;
      int openCurly = '{'.allMatches(fixed).length;
      int closeCurly = '}'.allMatches(fixed).length;
      int openSquare = '['.allMatches(fixed).length;
      int closeSquare = ']'.allMatches(fixed).length;

      fixed += ']' * (openSquare - closeSquare);
      fixed += '}' * (openCurly - closeCurly);

      return jsonDecode(fixed);
    }
  }
}
