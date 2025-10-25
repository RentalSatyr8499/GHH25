import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  bool loading = false;
  Map<String, dynamic>? user;
  String? error;

  AuthProvider(this._service);

  /// For tests or UI that want the stored customer id
  String? get customerId => _service.customerId;

  /// Create a mock customer on Nessie and set it as the current user.
  /// This method ignores the supplied username/password and always creates
  /// the same hardcoded mock profile (per request).
  Future<bool> login(String username, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final mockProfile = {
        'first_name': 'Test',
        'last_name': 'User',
        'address': {
          'street_number': '123',
          'street_name': 'Mockingbird Lane',
          'city': 'Testville',
          'state': 'TS',
          'zip': '12345'
        },
        'phone_number': '555-555-5555',
        'email': 'test.user@example.com'
      };

      final created = await _service.createCustomer(mockProfile);

      if (created.isEmpty) {
        error = 'Failed to create mock user';
        loading = false;
        notifyListeners();
        return false;
      }

      user = created;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    user = null;
    notifyListeners();
  }

  Future<Map<String, double>> getSpendingHabits() async {
    final id = user == null ? _service.customerId : user!['id'] as String?;
    if (id == null) return {};
    return await _service.getSpendingHabits(id);
  }
}
