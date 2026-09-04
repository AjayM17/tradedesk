import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _totalCapitalKey = 'total_capital';
  static const _riskPerTradeKey = 'risk_per_trade_percent';
  static const _maxCapitalPerStockKey =
      'max_capital_per_stock_percent';
  static const _targetRKey = 'target_r';

  Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // ---------------------------
  // Total Capital
  // ---------------------------

  Future<void> saveTotalCapital(double value) async {
    (await _prefs).setDouble(_totalCapitalKey, value);
  }

  Future<double> loadTotalCapital() async {
    return (await _prefs).getDouble(_totalCapitalKey) ?? 1000000;
  }

  // ---------------------------
  // Risk Per Trade
  // ---------------------------

  Future<void> saveRiskPerTradePercent(double value) async {
    (await _prefs).setDouble(_riskPerTradeKey, value);
  }

  Future<double> loadRiskPerTradePercent() async {
    return (await _prefs).getDouble(_riskPerTradeKey) ?? 0.7;
  }

  // ---------------------------
  // Capital Per Stock
  // ---------------------------

  Future<void> saveMaxCapitalPerStockPercent(double value) async {
    (await _prefs).setDouble(_maxCapitalPerStockKey, value);
  }

  Future<double> loadMaxCapitalPerStockPercent() async {
    return (await _prefs).getDouble(_maxCapitalPerStockKey) ?? 7;
  }

  // ---------------------------
  // Target R
  // ---------------------------

  Future<void> saveTargetR(double value) async {
    (await _prefs).setDouble(_targetRKey, value);
  }

  Future<double> loadTargetR() async {
    return (await _prefs).getDouble(_targetRKey) ?? 3;
  }
}