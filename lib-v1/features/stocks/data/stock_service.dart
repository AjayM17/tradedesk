import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

class StockService {
  static const String _baseUrl =
      'https://query1.finance.yahoo.com/v1/finance/search';

  static Future<List<Stock>> search(String query) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl'
        '?q=$query'
        '&quotesCount=15'
        '&newsCount=0'
        '&lang=en-IN'
        '&region=IN',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final Map<String, dynamic> data = json.decode(response.body);
      final List quotes = data['quotes'] ?? [];

      // baseSymbol -> best Stock (NSE preferred, BSE fallback)
      final Map<String, Stock> uniqueStocks = {};

      for (final q in quotes) {
        final raw = q['symbol']?.toString().toUpperCase();
        if (raw == null) continue;

        // Only consider Indian exchanges
        if (!raw.contains('.NS') && !raw.contains('.BO')) continue;

        final baseSymbol = raw.split('.').first;
        final incomingPriority = _exchangePriority(raw);

        final existing = uniqueStocks[baseSymbol];
        if (existing == null ||
            incomingPriority < _exchangePriority(existing.symbol)) {
          uniqueStocks[baseSymbol] = Stock(
            symbol: raw, // store full symbol internally (e.g. TCS.BO / TCS.NS)
            name: q['shortname'] ??
                q['longname'] ??
                baseSymbol,
          );
        }
      }

      final result = uniqueStocks.values.toList();

      debugPrint('✅ Unique stocks returned: ${result.length}');
      for (final s in result) {
        debugPrint('🎯 ${s.symbol}');
      }

      return result;
    } catch (e) {
      debugPrint('🔥 StockService error: $e');
      return [];
    }
  }

  static int _exchangePriority(String symbol) {
    final s = symbol.toUpperCase();
    if (s.contains('.NS')) return 1; // NSE (highest)
    if (s.contains('.BO')) return 2; // BSE (fallback)
    return 99;
  }
}
