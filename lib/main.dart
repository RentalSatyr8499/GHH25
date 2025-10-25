import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

void main() {
  // Read Nessie API key from --dart-define at runtime. Leave empty by default.
  const String apiKey = String.fromEnvironment('NESSIE_API_KEY', defaultValue: '');
  runApp(const MyApp(apiKey: apiKey));
}

class MyApp extends StatelessWidget {
  final String apiKey;

  const MyApp({Key? key, required this.apiKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthService(apiKey: apiKey)),
      child: MaterialApp(
        title: 'GHH25 Login Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Use the builder to wrap the app's root content when running on macOS
        builder: (context, child) {
          final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
          if (!isMacOS) return child ?? const SizedBox.shrink();

          // iPhone 11 logical pixels: 375 x 812
          return Center(
            child: SizedBox(
              width: 375,
              height: 812,
              child: Material(
                elevation: 0,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
        home: const LoginScreen(),
      ),
    );
  }
}
