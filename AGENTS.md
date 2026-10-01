# AGENTS.md

This repository is configured with official Flutter AI Agent Plugins, Skills, and Rules according to the [official Flutter AI documentation](https://docs.flutter.dev/ai/get-started).

## Project Overview
- **Project**: Welvors Mobile App
- **Framework**: Flutter (Dart SDK >= 3.0.0)
- **State Management**: BLoC / Cubit (`package:flutter_bloc`)
- **Networking**: `package:http` via centralized `ApiService`
- **Design System**: Welvors Custom Theme & `CustomSnackBar`

## Agent Configuration & Tools

### 1. Agent Skills (`.agents/skills/`)
The project includes the 25 official Flutter and Dart procedural skills from `flutter/agent-plugins`:
- `flutter-apply-architecture-best-practices`: Layered UI, logic, data separation.
- `flutter-build-responsive-layout`: Adaptive designs using `LayoutBuilder`, `MediaQuery`, `Expanded`.
- `flutter-fix-layout-issues`: Diagnosing and fixing `RenderFlex` overflows and unbounded constraints.
- `flutter-implement-json-serialization`: Type-safe JSON parsing models.
- `flutter-add-widget-test` & `flutter-add-integration-test`: Automated testing.
- `flutter-use-http-package`: REST API patterns and robust error handling.
- `dart-run-static-analysis`: Lint and diagnostic validation with `flutter analyze`.
- `dart-fix-runtime-errors`: Runtime stack trace resolution.
- `dart-use-pattern-matching`: Dart 3 pattern matching and destructuring.

### 2. Agent Rules (`.agents/rules/flutter_rules.md`)
- **Clean Error Messages**: Never show raw JSON or HTTP status code prefixes to users. Extract the `message` field and display using `CustomSnackBar`.
- **Async Safety**: Always guard `setState()` and context access with `if (mounted)`.
- **Resource Cleanup**: Always dispose `TextEditingController`, `FocusNode`, `AnimationController`, and subscriptions.
- **Static Analysis**: Verify changes with `flutter analyze` before finishing any task.

### 3. MCP Server (`.agents/mcp_config.json`)
The Dart and Flutter MCP server is configured for real-time SDK diagnostics, symbol resolution, and runtime introspection:
```json
{
  "mcpServers": {
    "dart": {
      "command": "dart",
      "args": ["mcp-server"]
    }
  }
}
```
