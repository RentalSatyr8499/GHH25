import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/purchase.dart';

class PurchaseGenerator {
  final Random rng;
  List<Map<String, dynamic>>? _merchantPool;

  PurchaseGenerator({Random? rng}) : rng = rng ?? Random();

  Future<void> _loadPool() async {
    if (_merchantPool != null) return;
    final jsonStr = await rootBundle.loadString('assets/merchants.json');
    final parsed = json.decode(jsonStr);
    if (parsed is List) {
      _merchantPool = parsed.cast<Map<String, dynamic>>();
    } else {
      _merchantPool = [];
    }
  }

  Future<Purchase> generateRandomPurchase({required String date}) async {
    await _loadPool();
    if (_merchantPool == null || _merchantPool!.isEmpty) {
      // fallback
      return Purchase(
        merchantId: 'm-fallback',
        merchantName: 'Fallback Merchant',
        amount: double.parse((rng.nextDouble() * 99 + 1).toStringAsFixed(2)),
        description: 'Purchase',
        purchaseDate: date,
      );
    }

    final entry = _merchantPool![rng.nextInt(_merchantPool!.length)];
    return Purchase.randomFromPool(entry, rng, date: date);
  }

  /// Generate N random purchases for given date values
  Future<List<Purchase>> generateRandomPurchases(int count, {required String date}) async {
    await _loadPool();
    final List<Purchase> out = [];
    for (var i = 0; i < count; i++) {
      out.add(await generateRandomPurchase(date: date));
    }
    return out;
  }
}
