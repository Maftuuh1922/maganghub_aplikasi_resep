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

## Architecture

```text
lib/
├── core/theme/              # Shared colors and Material theme
├── data/
│   ├── models/              # Category, Meal, Ingredient JSON models
│   ├── services/            # TheMealDB HTTP endpoints
│   └── repositories/        # Data access boundary used by logic/UI
├── logic/                   # App state and favorite persistence
├── presentation/
│   ├── pages/               # Onboarding, catalog, recipe detail
│   └── widgets/             # Reusable cards, navigation, status views
└── main.dart                # App composition and dependency wiring
```

`MealApiService` handles network/JSON, `MealRepository` exposes the app data operations, `AppState` manages UI state and local favorites, and presentation widgets render loading, empty, error/retry, and success states.

## API

Recipe data is fetched from TheMealDB test key `1`:

- Categories: `categories.php`
- Category list: `filter.php?c=<category>`
- Search: `search.php?s=<query>`
- Full recipe details: `lookup.php?i=<idMeal>`

The API base URL is `https://www.themealdb.com/api/json/v1/1/`.

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
