import 'package:flutter/material.dart';

import 'settings_storage.dart';

class SettingsState extends ChangeNotifier {
  final SettingsStorage _storage = SettingsStorage();

  // ---------------------------
  // Default Values
  // ---------------------------
  static const double defaultCapital = 1000000;
  static const double defaultRiskPercent = 0.7;
  static const double defaultMaxCapitalPerStock = 7;
  static const double defaultTargetR = 3;

  // ---------------------------
  // Internal State
  // ---------------------------
  double _totalCapital = defaultCapital;
  double _riskPerTradePercent = defaultRiskPercent;
  double _maxCapitalPerStockPercent = defaultMaxCapitalPerStock;
  double _targetR = defaultTargetR;

  // ---------------------------
  // Getters
  // ---------------------------
  double get totalCapital => _totalCapital;

  double get riskPerTradePercent => _riskPerTradePercent;

  double get maxCapitalPerStockPercent =>
      _maxCapitalPerStockPercent;

  double get targetR => _targetR;

  // ---------------------------
  // Derived Values
  // ---------------------------
  double get riskAmountPerTrade =>
      (_totalCapital * _riskPerTradePercent) / 100;

  double get maxCapitalPerStockAmount =>
      (_totalCapital * _maxCapitalPerStockPercent) / 100;

  // ---------------------------
  // Constructor
  // ---------------------------
  SettingsState() {
    _load();
  }

  // ---------------------------
  // Load Settings
  // ---------------------------
  Future<void> _load() async {
    _totalCapital = await _storage.loadTotalCapital();
    _riskPerTradePercent =
        await _storage.loadRiskPerTradePercent();
    _maxCapitalPerStockPercent =
        await _storage.loadMaxCapitalPerStockPercent();
    _targetR = await _storage.loadTargetR();

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

  Future<void> updateRiskPerTradePercent(double value) async {
    _riskPerTradePercent = value;
    notifyListeners();
    await _storage.saveRiskPerTradePercent(value);
  }

  Future<void> updateMaxCapitalPerStockPercent(
    double value,
  ) async {
    _maxCapitalPerStockPercent = value;
    notifyListeners();
    await _storage.saveMaxCapitalPerStockPercent(value);
  }

  Future<void> updateTargetR(double value) async {
    _targetR = value;
    notifyListeners();
    await _storage.saveTargetR(value);
  }

  // ---------------------------
  // Reset Defaults
  // ---------------------------
  Future<void> resetToDefaults() async {
    _totalCapital = defaultCapital;
    _riskPerTradePercent = defaultRiskPercent;
    _maxCapitalPerStockPercent = defaultMaxCapitalPerStock;
    _targetR = defaultTargetR;

    notifyListeners();

    await Future.wait([
      _storage.saveTotalCapital(_totalCapital),
      _storage.saveRiskPerTradePercent(_riskPerTradePercent),
      _storage.saveMaxCapitalPerStockPercent(
        _maxCapitalPerStockPercent,
      ),
      _storage.saveTargetR(_targetR),
    ]);
  }
}