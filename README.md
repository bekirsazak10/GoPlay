# GoTrendy / GoPlay

Flutter starter for the premium black-and-matte-white app experience. Material widgets use Flutter's official standalone `material_ui` package.

## Current screens

- Animated welcome screen: the brand name enters with a bounce animation.
- Login screen: email and password fields, password visibility toggle and form validation.
- Registration screen: name, email, password confirmation and required terms/privacy acceptance with form validation.
- The welcome screen automatically opens the authentication screen after a short pause.
- The displayed brand name is controlled from `lib/main.dart`.

## Run locally

1. Install Flutter 3.47.9 or newer (Dart 3.13+).
2. In the repository folder, run `flutter create .` to generate the platform folders.
3. Run `flutter pub get`.
4. Run `flutter run`.

## Run checks

Run the static analysis and authentication widget tests:

```bash
flutter analyze
flutter test
```

GitHub Actions runs these checks for pushes and pull requests targeting `main`.

## Change the displayed brand

Open `lib/main.dart` and change:

```dart
const bool useGoTrendyName = true;
```

Set it to `false` to display **GoPlay** instead of **GoTrendy**.

## Important

Login and registration currently provide client-side form validation only. Firebase Authentication and password reset have not been connected yet.
