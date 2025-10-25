import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghh25_app/widgets/password_field.dart';

void main() {
  testWidgets('PasswordField toggles visibility', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PasswordField(controller: controller))));

    // Initially obscureText should be true: there's a suffix icon and tapping it reveals text
    final suffixFinder = find.byIcon(Icons.visibility);
    expect(suffixFinder, findsOneWidget);

    await tester.tap(suffixFinder);
    await tester.pumpAndSettle();

    // After tap, suffix icon toggles to visibility_off
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
