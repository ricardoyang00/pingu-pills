# Environment Settings

Create `env.g.dart` file in this directory `lib/env/`:
```dart
// env.g.dart

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _Env {
  static const String API_KEY = 'A';

  static const String PROJECT_ID = 'B';

  static const String MESSAGING_SENDER_ID = 'C';

  static const String APP_ID = 'D';
}
```

Fill `A`, `B`, `C` and `D` with credentials provided by [Firebase](https://firebase.google.com/).

You should get a `google-services.json` file containing the credentials.
