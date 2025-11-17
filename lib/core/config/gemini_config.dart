/// Configuration for Gemini API.
///
/// The API key is read from compile-time environment variables using --dart-define-from-file.
/// See README.md for setup instructions.
///
/// TODO: In the future, this could be:
/// 1. Stored in user settings (if user links their Google account)
/// 2. Or entered by the user in app settings
class GeminiConfig {
  /// Gemini API key read from compile-time environment variable.
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Whether Gemini API is enabled.
  /// Set to false if API key is not configured.
  static bool get isEnabled => apiKey.isNotEmpty;
}
