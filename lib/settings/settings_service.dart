
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/settings_model.dart';

class SettingsService {
  static const String _storageKey = 'tradedesk-settings';

  static const SettingsModel _defaultSettings = SettingsModel(
    maxActiveTrades: 10,
    maxTradesPerMonth: 3,
    maxTradesPerThreeMonths: 6,
    maxRiskPerTrade: 10000,
    maxRiskPercentPerTrade: 8,
    maxInvestmentPerTrade: 100000,
    totalInvestment: 1000000,
    maxPortfolioRiskPercent: 6,
    targetR: 3.0,
    showOnlyActiveTrades: true,
  );

  /// Loads settings from local storage.
  Future<SettingsModel> getSettings() async {
    final preferences = await SharedPreferences.getInstance();

    final savedSettings = preferences.getString(_storageKey);

    if (savedSettings == null) {
      return _defaultSettings;
    }

    try {
      final decoded = jsonDecode(savedSettings);

      if (decoded is! Map<String, dynamic>) {
        return _defaultSettings;
      }

      return SettingsModel(
        maxActiveTrades: _readInt(
          decoded,
          'maxActiveTrades',
          _defaultSettings.maxActiveTrades,
        ),
        maxTradesPerMonth: _readInt(
          decoded,
          'maxTradesPerMonth',
          _defaultSettings.maxTradesPerMonth,
        ),
        maxTradesPerThreeMonths: _readInt(
          decoded,
          'maxTradesPerThreeMonths',
          _defaultSettings.maxTradesPerThreeMonths,
        ),
        maxRiskPerTrade: _readDouble(
          decoded,
          'maxRiskPerTrade',
          _defaultSettings.maxRiskPerTrade,
        ),
        maxRiskPercentPerTrade: _readDouble(
          decoded,
          'maxRiskPercentPerTrade',
          _defaultSettings.maxRiskPercentPerTrade,
        ),
        maxInvestmentPerTrade: _readDouble(
          decoded,
          'maxInvestmentPerTrade',
          _defaultSettings.maxInvestmentPerTrade,
        ),
        totalInvestment: _readDouble(
          decoded,
          'totalInvestment',
          _defaultSettings.totalInvestment,
        ),
        maxPortfolioRiskPercent: _readDouble(
          decoded,
          'maxPortfolioRiskPercent',
          _defaultSettings.maxPortfolioRiskPercent,
        ),
        targetR: _readDouble(
          decoded,
          'targetR',
          _defaultSettings.targetR,
        ),
        showOnlyActiveTrades:
            (decoded['showOnlyActiveTrades'] as bool?) ??
                _defaultSettings.showOnlyActiveTrades,
      );
    } catch (_) {
      return _defaultSettings;
    }
  }

  /// Saves only the Show Only Active Trades toggle.
  /// Other unsaved settings remain untouched.
  Future<void> saveShowOnlyActiveTrades(bool value) async {
    final preferences = await SharedPreferences.getInstance();

    final savedSettings = preferences.getString(_storageKey);

    Map<String, dynamic> settingsJson = {};

    if (savedSettings != null) {
      try {
        final decoded = jsonDecode(savedSettings);

        if (decoded is Map<String, dynamic>) {
          settingsJson = decoded;
        }
      } catch (_) {
        // Keep an empty map if saved settings are invalid.
      }
    }

    settingsJson['showOnlyActiveTrades'] = value;

    await preferences.setString(
      _storageKey,
      jsonEncode(settingsJson),
    );
  }

  /// Saves all settings.
  Future<void> saveSettings(SettingsModel settings) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _storageKey,
      jsonEncode(settings.toJson()),
    );
  }

  int _readInt(
    Map<String, dynamic> json,
    String key,
    int defaultValue,
  ) {
    final value = json[key];

    if (value is num) {
      return value.toInt();
    }

    return defaultValue;
  }

  double _readDouble(
    Map<String, dynamic> json,
    String key,
    double defaultValue,
  ) {
    final value = json[key];

    if (value is num) {
      return value.toDouble();
    }

    return defaultValue;
  }
}
