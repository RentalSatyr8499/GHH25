import 'dart:math';

class Purchase {
  final String merchantId;
  final String merchantName;
  final double amount;
  final String description;
  final String purchaseDate;
  final String medium;
  final String status;

  Purchase({
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.description,
    required this.purchaseDate,
    this.medium = 'balance',
    this.status = 'completed',
  });

  Map<String, dynamic> toJson() => {
        'merchant_id': merchantId,
        'merchant_name': merchantName,
        'amount': amount,
        'description': description,
        'purchase_date': purchaseDate,
        'medium': medium,
        'status': status,
      };

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      merchantId: json['merchant_id'] ?? '',
      merchantName: json['merchant_name'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      description: json['description'] ?? '',
      purchaseDate: json['purchase_date'] ?? '',
      medium: json['medium'] ?? 'balance',
      status: json['status'] ?? 'completed',
    );
  }

  /// Generate a random Purchase from a merchant pool entry.
  static Purchase randomFromPool(Map<String, dynamic> merchantEntry, Random rng, {required String date}) {
    final merchantId = merchantEntry['merchant_id'] ?? 'm-${rng.nextInt(10000)}';
    final merchantName = merchantEntry['merchant_name'] ?? 'Merchant';
    final descriptions = (merchantEntry['descriptions'] is List) ? (merchantEntry['descriptions'] as List).cast<String>() : <String>['Purchase'];
    final description = descriptions.isNotEmpty ? descriptions[rng.nextInt(descriptions.length)] : 'Purchase';

    // Random amount between 1 and 100
    final amount = double.parse((rng.nextDouble() * 99 + 1).toStringAsFixed(2));

    return Purchase(
      merchantId: merchantId,
      merchantName: merchantName,
      amount: amount,
      description: description,
      purchaseDate: date,
    );
  }
}
