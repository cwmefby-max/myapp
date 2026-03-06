# Blueprint

## Overview

This document outlines the style, design, and features of the Flutter application. It serves as a single source of truth for the project's current state.

## Style and Design

The application will follow Material Design 3 principles for a modern and consistent user experience.

*   **Theming**: A centralized theme will be defined in `lib/main.dart` using `ThemeData`. `ColorScheme.fromSeed` will be used to generate color palettes. Both light and dark themes will be supported.
*   **Typography**: The `google_fonts` package will be used for custom fonts to ensure a visually appealing and readable text.
*   **Component Theming**: Specific theme properties (e.g., `appBarTheme`, `elevatedButtonTheme`) will be used to customize the appearance of individual Material components.

## Features

### Current Features

*   **Basic App Structure**: A simple Flutter application structure with a `main.dart` entry point.
*   **Dependency Management**: The `pubspec.yaml` file is configured with the necessary dependencies.

### Implemented Changes

*   **Resolved `dart pub get` Error**: Corrected the dependency resolution issue by using `flutter pub get` instead of `dart pub get`.
*   **Fixed GitHub Actions Workflow**: Recreated the `.github/workflows/build_flutter.yml` file to fix a syntax error.
*   **Upgraded Dependencies**: Updated all project dependencies to the latest major versions to ensure compatibility and access to the latest features.

### Next Steps

*   Implement a theme toggle to switch between light and dark modes.
*   Add a simple UI with a home screen to demonstrate the theme.
