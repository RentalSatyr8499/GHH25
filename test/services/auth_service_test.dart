import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ghh25_app/services/auth_service.dart';

void main() {
  test('createCustomer posts profile and stores id', () async {
    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path.endsWith('/customers')) {
        final body = json.decode(request.body) as Map<String, dynamic>;
        final resp = {...body, 'id': 'mock-cust-1'};
        return http.Response(json.encode(resp), 201, headers: {'content-type': 'application/json'});
      }
      return http.Response('Not Found', 404);
    });

    final service = AuthService(apiKey: 'key', client: mockClient);
    final created = await service.createCustomer({'first_name': 'X', 'last_name': 'Y'});
    expect(created['id'], 'mock-cust-1');
    expect(service.customerId, 'mock-cust-1');
  });

  test('getSpendingHabits summarizes purchases by merchant', () async {
    final mockClient = MockClient((request) async {
      if (request.method == 'GET' && request.url.path.endsWith('/purchases')) {
        final items = [
          {'merchant_name': 'Shop A', 'amount': 10},
          {'merchant_name': 'Shop A', 'amount': 5},
          {'merchant_name': 'Shop B', 'amount': 7.5}
        ];
        return http.Response(json.encode(items), 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('Not Found', 404);
    });

    final service = AuthService(apiKey: 'key', client: mockClient);
    final summary = await service.getSpendingHabits('cid');
    expect(summary['Shop A'], 15);
    expect(summary['Shop B'], 7.5);
  });
}
