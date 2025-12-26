import 'package:flutter/material.dart';
import 'settings_storage.dart';

class SettingsState extends ChangeNotifier {
  final SettingsStorage _storage = SettingsStorage();

  // ---------------------------
  // Internal State
  // ---------------------------
  double _totalCapital = 1000000;
  double _maxCapitalPerStockPercent = 10;
  double _riskPerTradePercent = 1.0;

  // ---------------------------
  // Getters
  // ---------------------------
  double get totalCapital => _totalCapital;

  double get maxCapitalPerStockPercent =>
      _maxCapitalPerStockPercent;

  double get riskPerTradePercent =>
      _riskPerTradePercent;

  // ---------------------------
  // Derived Values (DO NOT STORE)
  // ---------------------------
  double get maxCapitalPerStockAmount =>
      (_totalCapital * _maxCapitalPerStockPercent) / 100;

  /// ✅ THIS IS WHAT YOU ASKED FOR
  /// Maximum allowed loss per trade (₹)
  double get riskAmountPerTrade =>
      (_totalCapital * _riskPerTradePercent) / 100;

  // ---------------------------
  // Constructor
  // ---------------------------
  SettingsState() {
    _load();
  }

  // ---------------------------
  // Load from Local Storage
  // ---------------------------
  Future<void> _load() async {
    _totalCapital = await _storage.loadTotalCapital();
    _maxCapitalPerStockPercent =
        await _storage.loadMaxCapitalPerStockPercent();
    _riskPerTradePercent =
        await _storage.loadRiskPerTradePercent();

    notifyListeners();
  }

  // ---------------------------
  // Update Methods
  // ---------------------------
  Future<void> updateTotalCapital(double value) async {
    _totalCapital = value;
    notifyListeners();
    await _storage.saveTotalCapital(value);
  }

  Future<void> updateMaxCapitalPerStockPercent(double value) async {
    _maxCapitalPerStockPercent = value;
    notifyListeners();
    await _storage.saveMaxCapitalPerStockPercent(value);
  }

  Future<void> updateRiskPerTradePercent(double value) async {
    _riskPerTradePercent = value;
    notifyListeners();
    await _storage.saveRiskPerTradePercent(value);
  }
}
