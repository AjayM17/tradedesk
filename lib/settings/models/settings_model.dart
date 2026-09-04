class SettingsModel {
  final int maxActiveTrades;
  final int maxTradesPerMonth;
  final int maxTradesPerThreeMonths;

  final double maxRiskPerTrade;
  final double maxRiskPercentPerTrade;

  final double maxInvestmentPerTrade;
  final double totalInvestment;
  final double maxPortfolioRiskPercent;

  const SettingsModel({
    required this.maxActiveTrades,
    required this.maxTradesPerMonth,
    required this.maxTradesPerThreeMonths,
    required this.maxRiskPerTrade,
    required this.maxRiskPercentPerTrade,
    required this.maxInvestmentPerTrade,
    required this.totalInvestment,
    required this.maxPortfolioRiskPercent,
  });

  /// Maximum amount of portfolio risk allowed.
  double get maxPortfolioRisk {
    return totalInvestment * maxPortfolioRiskPercent / 100;
  }

  /// Same validation behavior as Ionic V1 canSave.
  bool get canSave {
    return maxActiveTrades > 0 &&
        maxTradesPerMonth > 0 &&
        maxTradesPerThreeMonths > 0 &&
        maxRiskPerTrade > 0 &&
        maxRiskPercentPerTrade > 0 &&
        maxInvestmentPerTrade > 0 &&
        totalInvestment > 0 &&
        maxPortfolioRiskPercent > 0;
  }

  /// Creates a copy with only the provided values changed.
  SettingsModel copyWith({
    int? maxActiveTrades,
    int? maxTradesPerMonth,
    int? maxTradesPerThreeMonths,
    double? maxRiskPerTrade,
    double? maxRiskPercentPerTrade,
    double? maxInvestmentPerTrade,
    double? totalInvestment,
    double? maxPortfolioRiskPercent,
  }) {
    return SettingsModel(
      maxActiveTrades:
          maxActiveTrades ?? this.maxActiveTrades,
      maxTradesPerMonth:
          maxTradesPerMonth ?? this.maxTradesPerMonth,
      maxTradesPerThreeMonths:
          maxTradesPerThreeMonths ?? this.maxTradesPerThreeMonths,
      maxRiskPerTrade:
          maxRiskPerTrade ?? this.maxRiskPerTrade,
      maxRiskPercentPerTrade:
          maxRiskPercentPerTrade ?? this.maxRiskPercentPerTrade,
      maxInvestmentPerTrade:
          maxInvestmentPerTrade ?? this.maxInvestmentPerTrade,
      totalInvestment:
          totalInvestment ?? this.totalInvestment,
      maxPortfolioRiskPercent:
          maxPortfolioRiskPercent ?? this.maxPortfolioRiskPercent,
    );
  }

  /// Converts the model to JSON-compatible data.
  Map<String, dynamic> toJson() {
    return {
      'maxActiveTrades': maxActiveTrades,
      'maxTradesPerMonth': maxTradesPerMonth,
      'maxTradesPerThreeMonths': maxTradesPerThreeMonths,
      'maxRiskPerTrade': maxRiskPerTrade,
      'maxRiskPercentPerTrade': maxRiskPercentPerTrade,
      'maxInvestmentPerTrade': maxInvestmentPerTrade,
      'totalInvestment': totalInvestment,
      'maxPortfolioRiskPercent': maxPortfolioRiskPercent,
    };
  }

  /// Creates a model from JSON data.
  factory SettingsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SettingsModel(
      maxActiveTrades:
          (json['maxActiveTrades'] as num).toInt(),
      maxTradesPerMonth:
          (json['maxTradesPerMonth'] as num).toInt(),
      maxTradesPerThreeMonths:
          (json['maxTradesPerThreeMonths'] as num).toInt(),
      maxRiskPerTrade:
          (json['maxRiskPerTrade'] as num).toDouble(),
      maxRiskPercentPerTrade:
          (json['maxRiskPercentPerTrade'] as num).toDouble(),
      maxInvestmentPerTrade:
          (json['maxInvestmentPerTrade'] as num).toDouble(),
      totalInvestment:
          (json['totalInvestment'] as num).toDouble(),
      maxPortfolioRiskPercent:
          (json['maxPortfolioRiskPercent'] as num).toDouble(),
    );
  }
}