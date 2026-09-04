import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/settings_model.dart';

class SettingsService {
  static const String _storageKey = 'tradedesk-settings';

  static const SettingsModel _defaultSettings = SettingsModel(
    maxActiveTrades: 6,
    maxTradesPerMonth: 3,
    maxTradesPerThreeMonths: 6,
    maxRiskPerTrade: 15000,
    maxRiskPercentPerTrade: 8,
    maxInvestmentPerTrade: 300000,
    totalInvestment: 2000000,
    maxPortfolioRiskPercent: 3,
  );

  /// Loads settings from local storage.
  ///
  /// If no settings are saved, default settings are returned.
  ///
  /// If saved JSON is invalid, default settings are returned.
  ///
  /// Missing individual values fall back to their defaults,
  /// matching the merge behavior of the Ionic V1 service.
  Future<SettingsModel> getSettings() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedSettings =
        preferences.getString(_storageKey);

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
      );
    } catch (_) {
      return _defaultSettings;
    }
  }

  /// Saves settings to local storage.
  Future<void> saveSettings(
    SettingsModel settings,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

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