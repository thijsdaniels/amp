import 'package:openfoodfacts/openfoodfacts.dart';

/// Configuration for Open Food Facts API.
///
/// Sets up the SDK with app-specific settings.
class OpenFoodFactsConfig {
  /// Initializes the Open Food Facts SDK configuration.
  ///
  /// Should be called once at app startup (e.g., in main.dart).
  static void initialize() {
    // Set user agent to identify our app (recommended to avoid being blocked)
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'Amp',
      url: null, // Add URL if you have one
    );

    // Optional: Configure default language and country
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.NETHERLANDS;
    OpenFoodAPIConfiguration.globalLanguages = [
      OpenFoodFactsLanguage.ENGLISH,
      OpenFoodFactsLanguage.DUTCH,
    ];
  }
}
