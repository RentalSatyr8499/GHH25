import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ghh25_app/models/purchase.dart';

void main() {
  test('Purchase.randomFromPool creates a Purchase with expected fields', () {
    final map = {
      'merchant_id': 'm1',
      'merchant_name': 'Test Merchant',
      'descriptions': ['Item A', 'Item B']
    };

    final rng = Random(42);
    final purchase = Purchase.randomFromPool(map, rng, date: '2025-10-25');
    expect(purchase.merchantId, 'm1');
    expect(purchase.merchantName, 'Test Merchant');
    expect(purchase.purchaseDate, '2025-10-25');
    expect(purchase.amount, isNonZero);
    expect(purchase.description, isNotEmpty);
  });
}
