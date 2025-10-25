# GHH25

This is a minimal Flutter app added to the repository that includes a login screen (username + password). There is no backend — pressing Login validates input and navigates to a simple placeholder Home screen.

## Files added

- `pubspec.yaml` — Flutter package manifest.
- `lib/main.dart` — Main app with `LoginScreen` and simple `HomeScreen`.
- `.gitignore` — common Flutter ignores.

## How to run (macOS)

Make sure you have Flutter installed and available in your PATH. Then, from the repository root run:

```bash
# fetch packages
flutter pub get

# run on a connected device or simulator
flutter run
```

If you don't have Flutter installed yet, follow the official instructions at https://flutter.dev/docs/get-started/install

## Notes

- No backend is implemented. The login button only validates the form and navigates to a placeholder home screen.
- You can extend `lib/main.dart` to integrate authentication or state management as needed.
