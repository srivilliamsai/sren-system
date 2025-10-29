# SREN Mobile Client

SREN is a Flutter 3 application that captures a user’s expression, analyses emotions through the running SREN backend, and surfaces curated wellness content. The project follows clean architecture with feature-first folders, Riverpod state management, GoRouter navigation, Dio networking, secure token storage, and Hive caching.

## Project Layout

```
lib/
  core/            # config, theme, network, utilities, DI
  domain/          # entities, repository contracts, use cases
  data/            # DTOs, Hive models, repository implementations
  features/        # feature-first UI + state (auth, capture, history, etc.)
  routing/         # GoRouter setup
  widgets/         # shared UI components
```

## Prerequisites

- Flutter 3.13+ / Dart 3.9+
- Backend reachable at `http://localhost:8080`
- (Optional) Sentry DSN if crash reporting is desired

## Setup & Tooling

Install dependencies and generate Hive adapters:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
flutter run --dart-define=BASE_URL=http://localhost:8080
```

Optional flags:

- `--dart-define=SENTRY=true`
- `--dart-define=SENTRY_DSN=<your-dsn>`
- `--dart-define=MOCK_MODE=true` (forces gallery picker instead of camera)

### Platform Notes

- **iOS**: add `NSCameraUsageDescription` to `ios/Runner/Info.plist`
- **Android**: declare camera permissions in `android/app/src/main/AndroidManifest.xml`

## Feature Highlights

- JWT auth with secure storage, token refresh flow, and guarded navigation
- Camera capture / gallery pick with optional mock mode for simulators
- Emotion analysis flow with Tesla-esque dark UI and actionable results
- Recommendation feed with video/audio/article deep links and offline cache
- Emotion history charts, filter controls, and offline-first Hive storage
- Settings toggles for analytics & Sentry plus backend health checks
- Observability hooks (Sentry ready, structured analytics logging)

## Useful Commands

```bash
flutter format .
flutter analyze
flutter test
```

Happy shipping! 🚀
