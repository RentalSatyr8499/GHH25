import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ghh25_app/screens/home_screen.dart';
import 'package:ghh25_app/providers/auth_provider.dart';
import 'package:ghh25_app/services/auth_service.dart';

class DummyService extends AuthService {
  DummyService(): super(apiKey: 'x', client: null);
}

void main() {
  testWidgets('HomeScreen displays user info and navigates', (tester) async {
    final service = DummyService();
    final provider = AuthProvider(service);
    provider.user = {'first_name': 'Jane', 'id': 'id-1', 'address': {'street_number': '1', 'street_name': 'Main'}};

    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: provider,
      child: const MaterialApp(home: HomeScreen()),
    ));

    expect(find.textContaining('Welcome, Jane'), findsOneWidget);
    expect(find.textContaining('Customer id:'), findsOneWidget);
    expect(find.text('View Dashboard'), findsOneWidget);
  });
}
