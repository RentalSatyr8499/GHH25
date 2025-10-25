import 'package:flutter_test/flutter_test.dart';
import 'package:ghh25_app/providers/auth_provider.dart';
import 'package:ghh25_app/services/auth_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService(): super(apiKey: 'fake', client: null);

  @override
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> profile) async {
    final result = {...profile, 'id': 'fake-id-1'};
    customerId = 'fake-id-1';
    return result;
  }

  @override
  Future<Map<String, double>> getSpendingHabits(String customerId) async {
    return {'Shop A': 20.0, 'Shop B': 5.0};
  }
}

void main() {
  test('AuthProvider login creates mock user and exposes spending habits', () async {
    final service = FakeAuthService();
    final provider = AuthProvider(service);
    final ok = await provider.login('any', 'any');
    expect(ok, isTrue);
    expect(provider.user, isNotNull);
    expect(provider.customerId, 'fake-id-1');
    final habits = await provider.getSpendingHabits();
    expect(habits['Shop A'], 20.0);
  });
}
