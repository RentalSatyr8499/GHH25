import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  /// Stores the last created customer id for future calls.
  String? customerId;

  AuthService({required this.apiKey, this.baseUrl = 'http://api.nessieisreal.com', http.Client? client}) : _client = client ?? http.Client();

  /// Create a mock customer on Nessie using the provided profile map.
  /// Returns the created customer object as map and stores its `id` in [customerId].
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> profile) async {
    if (apiKey.isEmpty) throw Exception('NESSIE_API_KEY is not set');

    final uri = Uri.parse('$baseUrl/customers').replace(queryParameters: {'key': apiKey});
    final resp = await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(profile));

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Nessie create customer failed: ${resp.statusCode} ${resp.body}');
    }

    final body = json.decode(resp.body) as Map<String, dynamic>;

    // Nessie may return the created id nested under objectCreated['_id']
    String? extractedId;
    final objCreated = body['objectCreated'];
    if (objCreated is Map<String, dynamic>) {
      extractedId = objCreated['_id'] as String?;
    }
    if (extractedId == null) {
      final maybeId = body['id'];
      if (maybeId is String) extractedId = maybeId;
    }
    customerId = extractedId;

    return body;
  }

  /// Fetch purchases for the given customer id and return a processed
  /// spending summary (merchant_name -> total amount).
  Future<Map<String, double>> getSpendingHabits(String customerId) async {
    if (apiKey.isEmpty) throw Exception('NESSIE_API_KEY is not set');

    final uri = Uri.parse('$baseUrl/purchases').replace(queryParameters: {'customer_id': customerId, 'key': apiKey});
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Nessie purchases request failed: ${resp.statusCode} ${resp.body}');
    }

    final body = json.decode(resp.body);
    if (body is! List) return {};

    final Map<String, double> summary = {};
    for (final item in body.cast<Map<String, dynamic>>()) {
      final merchant = item['merchant_name'] is String ? item['merchant_name'] as String : 'Unknown';
      double amount;
      if (item['amount'] is num) {
        amount = (item['amount'] as num).toDouble();
      } else {
        amount = 0.0;
      }

      if (summary[merchant] == null) {
        summary[merchant] = amount;
      } else {
        summary[merchant] = (summary[merchant] ?? 0.0) + amount;
      }
    }
    return summary;
  }

  /// Backwards-compatible GET by first_name (keeps the previous behavior).
  Future<Map<String, dynamic>?> findCustomerByFirstName(String firstName) async {
    if (apiKey.isEmpty) throw Exception('NESSIE_API_KEY is not set');
    final uri = Uri.parse('$baseUrl/customers').replace(queryParameters: {'first_name': firstName, 'key': apiKey});
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) throw Exception('Nessie API returned ${resp.statusCode}: ${resp.body}');
    final body = json.decode(resp.body);
    if (body is List && body.isNotEmpty) return Map<String, dynamic>.from(body.first as Map);
    if (body is Map<String, dynamic>) return body;
    return null;
  }
}
