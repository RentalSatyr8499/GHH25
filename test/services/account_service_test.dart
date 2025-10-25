import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ghh25_app/services/account_service.dart';

void main() {
  test('createAccountAndPopulate posts account and purchases', () async {
    final mockClient = MockClient((request) async {
      final path = request.url.path;
      if (request.method == 'POST' && path.endsWith('/accounts')) {
        final body = json.decode(request.body) as Map<String, dynamic>;
        final resp = {...body, 'id': 'acc-123'};
        return http.Response(json.encode(resp), 201, headers: {'content-type': 'application/json'});
      }

      if (request.method == 'POST' && path.endsWith('/purchases')) {
        final p = json.decode(request.body) as Map<String, dynamic>;
        final resp = {...p, 'id': 'pur-${p['merchant_id'] ?? 'x'}'};
        return http.Response(json.encode(resp), 201, headers: {'content-type': 'application/json'});
      }

      return http.Response('Not Found', 404);
    });

    final service = AccountService(apiKey: 'key', client: mockClient);

    final purchases = [
      {'merchant_id': 'm1', 'merchant_name': 'A', 'amount': 1.0, 'description': 'd', 'purchase_date': '2025-01-01', 'medium': 'balance', 'status': 'completed'},
      {'merchant_id': 'm2', 'merchant_name': 'B', 'amount': 2.0, 'description': 'd2', 'purchase_date': '2025-01-02', 'medium': 'balance', 'status': 'completed'},
      {'merchant_id': 'm3', 'merchant_name': 'C', 'amount': 3.0, 'description': 'd3', 'purchase_date': '2025-01-03', 'medium': 'balance', 'status': 'completed'},
    ];

    final account = await service.createAccountAndPopulate('cust-1', {'type': 'Checking', 'nickname': 'Mock Account'}, purchasesData: purchases);
    expect(account['id'], 'acc-123');
    expect(service.accountId, 'acc-123');
  });
}
