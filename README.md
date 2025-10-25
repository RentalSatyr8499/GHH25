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

## Nessie API integration (optional)

This repo contains an `AuthService` that can query the Capital One Nessie mock API to retrieve customer data.

- You must provide a Nessie API key when starting the app. Do not hard-code keys in source control. Use `--dart-define` when running:

```bash
# example (replace YOUR_KEY_HERE)
flutter run -d macos --dart-define=NESSIE_API_KEY=YOUR_KEY_HERE
```

- The app will attempt to fetch a customer by the username's first name. This is mock behaviour — the password is not actually authenticated against Nessie. If no API key is provided the call will fail with a helpful message.

## Notes

- If you want me to add stronger mapping between entered credentials and fetched mock user data (or a configurable mock backend), I can implement that next.
- Failed main_test.dart