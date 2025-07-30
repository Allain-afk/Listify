import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum Currency {
  php, // Philippine Peso (default)
  usd, // US Dollar
  eur, // Euro
  gbp, // British Pound
  jpy, // Japanese Yen
  aud, // Australian Dollar
  cad, // Canadian Dollar
  sgd, // Singapore Dollar
  hkd, // Hong Kong Dollar
  krw, // South Korean Won
}

class BudgetSettings {
  final double budget;
  final Currency currency;
  final DateTime lastUpdated;

  BudgetSettings({
    required this.budget,
    this.currency = Currency.php,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  BudgetSettings copyWith({
    double? budget,
    Currency? currency,
    DateTime? lastUpdated,
  }) {
    return BudgetSettings(
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'budget': budget,
      'currency': currency.index,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory BudgetSettings.fromMap(Map<String, dynamic> map) {
    return BudgetSettings(
      budget: map['budget']?.toDouble() ?? 0.0,
      currency: Currency.values[map['currency'] ?? 0],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  String get currencySymbol {
    switch (currency) {
      case Currency.php:
        return '₱';
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.jpy:
        return '¥';
      case Currency.aud:
        return 'A\$';
      case Currency.cad:
        return 'C\$';
      case Currency.sgd:
        return 'S\$';
      case Currency.hkd:
        return 'HK\$';
      case Currency.krw:
        return '₩';
    }
  }

  String get currencyName {
    switch (currency) {
      case Currency.php:
        return 'Philippine Peso';
      case Currency.usd:
        return 'US Dollar';
      case Currency.eur:
        return 'Euro';
      case Currency.gbp:
        return 'British Pound';
      case Currency.jpy:
        return 'Japanese Yen';
      case Currency.aud:
        return 'Australian Dollar';
      case Currency.cad:
        return 'Canadian Dollar';
      case Currency.sgd:
        return 'Singapore Dollar';
      case Currency.hkd:
        return 'Hong Kong Dollar';
      case Currency.krw:
        return 'South Korean Won';
    }
  }

  String formatAmount(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }
} 