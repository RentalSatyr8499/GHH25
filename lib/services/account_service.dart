import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class AccountService {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  /// Stores the last created account id for future calls.
  String? accountId;

  AccountService({required this.apiKey, this.baseUrl = 'http://api.nessieisreal.com', http.Client? client}) : _client = client ?? http.Client();

  /// Create an account for [customerId] using provided [accountData].
  Future<Map<String, dynamic>> createAccountForCustomer(String customerId, Map<String, dynamic> accountData) async {
    if (apiKey.isEmpty) throw Exception('NESSIE_API_KEY is not set');

    final body = {...accountData, 'customer_id': customerId};
    final uri = Uri.parse('$baseUrl/accounts').replace(queryParameters: {'key': apiKey});
    final resp = await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(body));

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Nessie create account failed: ${resp.statusCode} ${resp.body}');
    }

    final created = json.decode(resp.body) as Map<String, dynamic>;

    // Extract nested id if present
    String? extractedId;
    final objCreated = created['objectCreated'];
    if (objCreated is Map<String, dynamic>) {
      extractedId = objCreated['_id'] as String?;
    }
    if (extractedId == null) {
      final maybeId = created['id'];
      if (maybeId is String) extractedId = maybeId;
    }
    accountId = extractedId;

    return created;
  }

  /// Populate purchases for the given account/customer. If [purchasesData]
  /// is provided, it will be used; otherwise the method will attempt to load
  /// `assets/purchases.json` from the app bundle.
  Future<List<Map<String, dynamic>>> populatePurchases(String accountId, String customerId, {List<Map<String, dynamic>>? purchasesData, List<dynamic>? purchasesAsObjects}) async {
  if (apiKey.isEmpty) throw Exception('NESSIE_API_KEY is not set');

    List<Map<String, dynamic>> purchases;
    if (purchasesData != null) {
      purchases = purchasesData;
    } else if (purchasesAsObjects != null) {
      purchases = purchasesAsObjects.map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)).toList();
    } else {
      final jsonStr = await rootBundle.loadString('assets/purchases.json');
      final parsed = json.decode(jsonStr);
      if (parsed is List) {
        purchases = parsed.cast<Map<String, dynamic>>();
      } else {
        purchases = [];
      }
    }

    final List<Map<String, dynamic>> created = [];
    for (final p in purchases) {
      final body = {
        ...p,
        'account_id': accountId,
        'customer_id': customerId,
      };
      final uri = Uri.parse('$baseUrl/purchases').replace(queryParameters: {'key': apiKey});
      final resp = await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(body));
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Nessie create purchase failed: ${resp.statusCode} ${resp.body}');
      }

      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      created.add(decoded);
    }

    return created;
  }

  /// Convenience: create account and populate purchases using either
  /// injected purchasesData or bundled asset.
  Future<Map<String, dynamic>> createAccountAndPopulate(String customerId, Map<String, dynamic> accountData, {List<Map<String, dynamic>>? purchasesData}) async {
    final account = await createAccountForCustomer(customerId, accountData);

    String? accId;
    final objCreated = account['objectCreated'];
    if (objCreated is Map<String, dynamic>) {
      accId = objCreated['_id'] as String?;
    }
    if (accId == null) {
      final maybeId = account['id'];
      if (maybeId is String) accId = maybeId;
    }

    if (accId == null) throw Exception('Account creation returned no id');
    await populatePurchases(accId, customerId, purchasesData: purchasesData);
    return account;
  }
}
