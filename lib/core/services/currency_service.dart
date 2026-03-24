import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CurrencyService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  CurrencyService(this._dio, this._storage);

  Future<Map<String, double>> fetchRates() async {
    try {
      final response = await _dio.get('https://api.exchangerate-api.com/v4/latest/USD');
      final rawRates = response.data['rates'] as Map<String, dynamic>;
      final rates = Map<String, double>.from(
        rawRates.map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
      await cacheRates(rates);
      return rates;
    } catch (e) {
      return getCachedRates();
    }
  }

  Future<void> cacheRates(Map<String, double> rates) async {
    await _storage.write(key: 'currency_rates', value: jsonEncode(rates));
    await _storage.write(key: 'rates_last_update', value: DateTime.now().toIso8601String());
  }

  Future<Map<String, double>> getCachedRates() async {
    final cached = await _storage.read(key: 'currency_rates');
    if (cached == null) return _defaultRates();
    final Map<String, dynamic> data = jsonDecode(cached) as Map<String, dynamic>;
    return Map<String, double>.from(
      data.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final rates = await getCachedRates();
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return (amount / fromRate) * toRate;
  }

  Map<String, double> _defaultRates() => {
    'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.50,
    'CAD': 1.35, 'AUD': 1.52, 'TRY': 32.0,
  };
}
