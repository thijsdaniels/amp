# amp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Variables

### Gemini API Key

To enable AI-powered group name generation, create an `env.json` file in the project root:

1. Copy the example file:

   ```bash
   cp env.json.example env.json
   ```

2. Edit `env.json` and add your API key:
   ```json
   {
   	"GEMINI_API_KEY": "your_api_key_here"
   }
   ```

The `env.json` file is gitignored, so your API key won't be committed to the repository.

**Running the app:**

- **From VS Code:** Use the "Launch" configuration (already configured in `.vscode/launch.json`)
- **From terminal:**
  ```bash
  flutter run --dart-define-from-file=env.json
  ```

Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey).
