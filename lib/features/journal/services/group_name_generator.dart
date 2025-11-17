import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:amp/core/config/gemini_config.dart';

/// Service for generating group names for journal entries using AI.
class GroupNameGenerator {
  final String _apiKey;
  final String _model;

  GroupNameGenerator({String? apiKey, String? model})
    : _apiKey = apiKey ?? GeminiConfig.apiKey,
      _model = model ?? 'gemini-2.5-flash-lite';

  /// Generates a group name based on a list of entry names.
  ///
  /// Returns a suggested name that describes the group of entries.
  /// Returns null if the API call fails or is disabled.
  Future<String?> generateGroupName(List<String> entryNames) async {
    if (!GeminiConfig.isEnabled || _apiKey.isEmpty) {
      return null;
    }

    if (entryNames.isEmpty) {
      return null;
    }

    try {
      final model = GenerativeModel(model: _model, apiKey: _apiKey);

      final prompt = _buildPrompt(entryNames);
      final response = await model.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return null;
      }

      // Clean up the response - remove quotes if present
      var cleaned = text.trim();
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      } else if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      return cleaned;
    } catch (e) {
      // Silently fail - we don't want to break the UI if AI generation fails
      return null;
    }
  }

  String _buildPrompt(List<String> entryNames) {
    final entriesList = entryNames.map((name) => '- $name').join('\n');

    return '''Given these food/journal entries:
$entriesList

Generate a short, descriptive name (1-4 words max) for a group or meal containing these entries. 
The name should be concise and capture what the combination of the entries likely represents (e.g. "Bagel", "Smoked Salmon" and "Cream Cheese" might make a "Salmon Bagel"), or what these entries have in common (e.g., meal type, time of day, theme).
Return only the name, nothing else.''';
  }
}
