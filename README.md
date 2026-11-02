# Pantom Meals

Recipe catalog mobile app for the Mobile Developer internship test.

## Features

- Category chips from TheMealDB
- Recipe list with loading and retry states
- Recipe detail with ingredients, measures, and instructions
- Search by recipe name
- Local favorites with SharedPreferences
- Pull-to-refresh
- Dark Pantom Wallet-inspired UI: deep navy, mint accent, large rounded surfaces

## Run locally

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

GitHub Actions builds the APK automatically on every push to `main`. Download it from the workflow run's **Artifacts** section.
