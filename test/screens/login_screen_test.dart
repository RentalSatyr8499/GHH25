import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ghh25_app/screens/login_screen.dart';
import 'package:ghh25_app/providers/auth_provider.dart';
import 'package:ghh25_app/services/auth_service.dart';

class FastFakeService extends AuthService {
  FastFakeService(): super(apiKey: 'fake', client: null);

  @override
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> profile) async {
    return {...profile, 'id': 'fast-1', 'first_name': profile['first_name']};
  }

  @override
  Future<Map<String, double>> getSpendingHabits(String customerId) async {
    return {'Shop A': 10.0};
  }
}

void main() {
  testWidgets('LoginScreen calls provider and navigates on success', (tester) async {
    final service = FastFakeService();
    final provider = AuthProvider(service);

    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: provider,
      child: const MaterialApp(home: LoginScreen()),
    ));

    // Enter username and password
    await tester.enterText(find.byType(TextFormField).first, 'Someone');
    await tester.enterText(find.byType(TextFormField).last, 'password');

    // Tap the login button
    await tester.tap(find.byKey(const Key('login_button')));
    // await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // After login, Dashboard should appear with mocked spending data
    expect(find.text('Shop A'), findsOneWidget);
    expect(find.textContaining(r'$10.00'), findsOneWidget);
  });
}
