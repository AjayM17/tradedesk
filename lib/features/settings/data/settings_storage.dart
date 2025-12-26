import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _totalCapitalKey = 'total_capital';
  static const _maxCapitalPerStockKey = 'max_capital_per_stock_percent';
  static const _riskPerTradeKey = 'risk_per_trade_percent';

  // ---------------------------
  // Total Capital
  // ---------------------------
  Future<void> saveTotalCapital(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_totalCapitalKey, value);
  }

  Future<double> loadTotalCapital() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_totalCapitalKey) ?? 1000000; // default 10L
  }

  // ---------------------------
  // Max Capital Per Stock (%)
  // ---------------------------
  Future<void> saveMaxCapitalPerStockPercent(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_maxCapitalPerStockKey, value);
  }

  Future<double> loadMaxCapitalPerStockPercent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_maxCapitalPerStockKey) ?? 10; // default 10%
  }

  // ---------------------------
  // Risk Per Trade (%)
  // ---------------------------
  Future<void> saveRiskPerTradePercent(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_riskPerTradeKey, value);
  }

  Future<double> loadRiskPerTradePercent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_riskPerTradeKey) ?? 1.0; // default 1%
  }
}
