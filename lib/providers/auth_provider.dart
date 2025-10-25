import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../services/purchase_generator.dart';

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

      };

  final created = await _service.createCustomer(mockProfile);

      if (created.isEmpty) {
        error = 'Failed to create mock user';
        loading = false;
        notifyListeners();
        return false;
      }

      user = created;
      // After creating the customer, create an account and populate purchases
      try {
        String? custId;
        final objCreated = created['objectCreated'];
        if (objCreated is Map<String, dynamic>) {
          custId = objCreated['_id'] as String?;
        }
        if (custId == null) {
          final maybeId = created['id'];
          if (maybeId is String) custId = maybeId;
        }

        if (custId != null) {

          final accountService = AccountService(apiKey: _service.apiKey);
          final accountData = {'type': 'Checking', 'nickname': 'Mock Account'};

          // Create account
          final account = await accountService.createAccountForCustomer(custId, accountData);
          

          // Generate random purchases using the merchant pool (3 purchases)
          final generator = PurchaseGenerator();
          final purchases = await generator.generateRandomPurchases(3, date: DateTime.now().toIso8601String().split('T').first);

          // Convert purchases to JSON-ready maps
          final purchaseMaps = purchases.map((p) => p.toJson()).toList();

          // Extract account id safely
          String? accId;
          final accountObjCreated = account['objectCreated'];
          if (accountObjCreated is Map<String, dynamic>) {
            accId = accountObjCreated['_id'] as String?;
          }
          if (accId == null) {
            final maybe = account['id'];
            if (maybe is String) accId = maybe;
          }

          if (accId != null) {
            await accountService.populatePurchases(accId, custId, purchasesAsObjects: purchaseMaps);
          } else {
            // set an error so UI can surface that populate didn't run as expected
            error = 'Account created but returned no id; purchases not populated';
            notifyListeners();
          }
        }
      } catch (_) {
        // Capture any error and surface it instead of silently ignoring
        error = 'Account or purchases population failed';
        notifyListeners();
      }
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
    String? id;
    if (user == null) {
      id = _service.customerId;
    } else {
      id = (user?['objectCreated'] as Map<String, dynamic>?)?['_id'] as String?;
    }
    // Ensure we read nested structures safely
    if (user != null) {
      final objCreated = user?['objectCreated'];
      if (objCreated is Map<String, dynamic>) {
        id = objCreated['_id'] as String?;
      }
      if (id == null) {
        final maybe = user?['id'];
        if (maybe is String) id = maybe;
      }
    }

    if (id == null) {
      // No id available — surface the issue
      error = 'No customer id available to fetch spending habits';
      notifyListeners();
      return {};
    }

    try {
      final purchases = await _service.getSpendingHabits(id);
      return purchases;
    } catch (e) {
      error = 'Failed to fetch spending habits: $e';
      notifyListeners();
      return {};
    }
  }
}
