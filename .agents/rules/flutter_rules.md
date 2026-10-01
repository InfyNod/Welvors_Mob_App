---
trigger: always_on
description: Official Flutter and Dart development rules and best practices
---

# Flutter & Dart Agent Rules

These rules guide all AI coding assistants working in this Flutter workspace.

## 1. Code Quality & Analysis
- **Static Analysis**: Always verify code quality using `flutter analyze` or the Dart MCP server before declaring tasks complete. Ensure zero warnings or errors.
- **Const Constructors**: Use `const` constructors wherever possible to optimize widget tree rebuilds (`prefer_const_constructors`).
- **Effective Dart**: Follow official [Effective Dart](https://dart.dev/effective-dart) guidelines for naming, style, error handling, and documentation comments (`///`).

## 2. Widget Architecture & Layout
- **Layered Architecture**: Keep a clean separation between:
  - **Presentation / UI**: Stateless / Stateful widgets, responsive layout builders.
  - **State Management**: BLoC / Cubit patterns (`flutter_bloc`). Keep UI decoupled from business logic.
  - **Data / Services**: Dedicated API services (e.g., `ApiService`) with strong error handling and type-safe model parsing.
- **Avoid RenderFlex Overflows**:
  - Always bound scrollable views inside Column/Row with `Expanded`, `Flexible`, or explicit constraints.
  - Use `SingleChildScrollView` or `ListView` when content can exceed screen height on smaller devices.
  - Respect screen cutouts and notches using `SafeArea`.

## 3. Error Handling & Feedback
- **User Feedback**: Always use the project's centralized `CustomSnackBar` (`CustomSnackBar.showError`, `CustomSnackBar.showSuccess`, etc.) instead of raw, unstyled `ScaffoldMessenger` snackbars.
- **Clean Error Parsing**: Never display raw JSON responses (e.g. `{"success": false, "message": "..."}`) or status code prefixes (`Error 400:`) to the user. Always parse and extract the human-readable `message` or use friendly fallback text.
- **Safe Asynchronous Operations**: Always check `if (!mounted) return;` or `if (mounted)` before calling `setState()` or accessing `BuildContext` across `await` points.

## 4. Hot Reload & State Preservation
- Preserve widget state across Hot Reloads: Avoid initializing long-lived state directly in `build()`; use `initState()` or state cubits.
- Dispose of controllers, focus nodes, stream subscriptions, and animation controllers in `dispose()`.

## 5. Accessibility (a11y)
- Provide `Semantics` or tooltip labels for icon-only action buttons.
- Ensure interactive touch targets meet the minimum 48x48 logical pixels recommended for mobile usability.
