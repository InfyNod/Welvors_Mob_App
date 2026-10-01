# GEMINI.md - Welvors Mobile App

Project instructions and AI guidelines for Antigravity and pair programming assistants.

## Official Flutter AI Capabilities Configured
This workspace is equipped with official Flutter AI Agent Plugins based on [Flutter AI Documentation](https://docs.flutter.dev/ai/get-started):
- **Skills**: 25 official procedural guides located in `.agents/skills/`.
- **Rules**: `.agents/rules/flutter_rules.md` and `AGENTS.md`.
- **MCP Server**: `.agents/mcp_config.json` configured for the Dart SDK analyzer.

## Welvors Project Guidelines
1. **Error Handling & Feedback**:
   - Always display errors and notices using `CustomSnackBar.showError(context, message)` or `CustomSnackBar.showSuccess(...)`.
   - Never show raw JSON or `Error 400:` strings in the UI. Always sanitize/extract the message.
2. **State Management**:
   - Use `flutter_bloc` (Cubit / Bloc) for app state. Keep widgets focused on presentation.
3. **Async / Lifecycle**:
   - Always check `if (mounted)` before calling `setState()` or using `BuildContext` across async boundaries.
   - Dispose all controllers in `dispose()`.
4. **Verification**:
   - Always run `flutter analyze` on touched files to maintain zero warnings and errors.
