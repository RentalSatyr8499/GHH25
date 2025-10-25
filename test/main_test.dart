import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ghh25_app/main.dart';

void main() {
  testWidgets('MyApp builds', (tester) async {
    await tester.pumpWidget(const MyApp(apiKey: ''));
    // Basic smoke: app bar title 'Login' should be present in the login screen
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_app_bar')), findsOneWidget);
  });
}
