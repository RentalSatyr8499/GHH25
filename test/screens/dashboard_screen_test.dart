import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ghh25_app/screens/dashboard_screen.dart';
import 'package:ghh25_app/providers/auth_provider.dart';
import 'package:ghh25_app/services/auth_service.dart';

class DummyService extends AuthService {
  DummyService(): super(apiKey: 'x', client: null);

  @override
  Future<Map<String, double>> getSpendingHabits(String customerId) async {
    return {'Shop A': 12.5, 'Coffee Place': 3.75};
  }
}

void main() {
  testWidgets('Dashboard shows spending summary', (tester) async {
    final service = DummyService();
    final provider = AuthProvider(service);
    provider.user = {'id': 'id-s'};

    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: provider,
      child: const MaterialApp(home: DashboardScreen()),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Shop A'), findsOneWidget);
    expect(find.textContaining('\$12.50'), findsOneWidget);
  });
}
