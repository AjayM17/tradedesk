import '../../settings/settings_service.dart';
import '../models/trade_model.dart';

class TradeRuleResult {
  final String key;
  final String label;
  final bool passed;
  final String message;

  const TradeRuleResult({
    required this.key,
    required this.label,
    required this.passed,
    required this.message,
  });
}

class TradeRuleCheckResult {
  final bool passed;
  final List<TradeRuleResult> results;

  const TradeRuleCheckResult({
    required this.passed,
    required this.results,
  });
}

class TradeRulesService {
  final SettingsService _settingsService;

  TradeRulesService({
    SettingsService? settingsService,
  }) : _settingsService =
            settingsService ?? SettingsService();

  // =========================================================
  // NEW TRADE
  // =========================================================

  Future<TradeRuleCheckResult> checkTrade(
    TradeModel trade,
    List<TradeModel> existingTrades, {
    String? excludeTradeId,
  }) async {
    final settings =
        await _settingsService.getSettings();

    final otherTrades = existingTrades
        .where(
          (existingTrade) =>
              existingTrade.id != excludeTradeId,
        )
        .toList();

    final results = <TradeRuleResult>[
      _checkRiskValue(
        trade,
        settings.maxRiskPerTrade,
      ),

      _checkRiskPercentage(
        trade,
        settings.maxRiskPercentPerTrade,
      ),

      _checkInvestment(
        trade,
        settings.maxInvestmentPerTrade,
      ),

      _checkActiveTrades(
        otherTrades,
        settings.maxActiveTrades,
      ),

      _checkMonthlyLimit(
        trade,
        otherTrades,
        settings.maxTradesPerMonth,
      ),

      _checkQuarterlyLimit(
        trade,
        otherTrades,
        settings.maxTradesPerThreeMonths,
      ),

      _checkPortfolioRisk(
        trade,
        otherTrades,
        settings.totalInvestment,
        settings.maxPortfolioRiskPercent,
      ),
    ];

    return TradeRuleCheckResult(
      passed: results.every(
        (result) => result.passed,
      ),
      results: results,
    );
  }

  // =========================================================
  // REACTIVATE COMPLETED TRADE
  // =========================================================

  Future<TradeRuleCheckResult> checkReactivation(
    TradeModel trade,
    List<TradeModel> existingTrades,
  ) async {
    final settings =
        await _settingsService.getSettings();

    final otherTrades = existingTrades
        .where(
          (existingTrade) =>
              existingTrade.id != trade.id,
        )
        .toList();

    final results = <TradeRuleResult>[
      _checkRiskValue(
        trade,
        settings.maxRiskPerTrade,
      ),

      _checkRiskPercentage(
        trade,
        settings.maxRiskPercentPerTrade,
      ),

      _checkInvestment(
        trade,
        settings.maxInvestmentPerTrade,
      ),

      _checkActiveTrades(
        otherTrades,
        settings.maxActiveTrades,
      ),

      _checkPortfolioRisk(
        trade,
        otherTrades,
        settings.totalInvestment,
        settings.maxPortfolioRiskPercent,
      ),
    ];

    return TradeRuleCheckResult(
      passed: results.every(
        (result) => result.passed,
      ),
      results: results,
    );
  }

  // =========================================================
  // RISK VALUE
  // =========================================================

  TradeRuleResult _checkRiskValue(
    TradeModel trade,
    double maxRisk,
  ) {
    final riskValue = _getRiskValue(trade);

    final passed = riskValue <= maxRisk;

    return TradeRuleResult(
      key: 'risk-value',
      label: 'Risk Value',
      passed: passed,
      message: passed
          ? 'Risk ₹${riskValue.toStringAsFixed(2)} '
              'is within ₹${maxRisk.toStringAsFixed(2)} limit.'
          : 'Risk ₹${riskValue.toStringAsFixed(2)} '
              'exceeds ₹${maxRisk.toStringAsFixed(2)} limit.',
    );
  }

  // =========================================================
  // RISK PERCENTAGE
  // =========================================================

  TradeRuleResult _checkRiskPercentage(
    TradeModel trade,
    double maxRiskPercentage,
  ) {
    final riskPercentage =
        _getRiskPercentage(trade);

    final passed =
        riskPercentage <= maxRiskPercentage;

    return TradeRuleResult(
      key: 'risk-percentage',
      label: 'Risk Percentage',
      passed: passed,
      message: passed
          ? 'Risk ${riskPercentage.toStringAsFixed(2)}% '
              'is within $maxRiskPercentage% limit.'
          : 'Risk ${riskPercentage.toStringAsFixed(2)}% '
              'exceeds $maxRiskPercentage% limit.',
    );
  }

  // =========================================================
  // INVESTMENT
  // =========================================================

  TradeRuleResult _checkInvestment(
    TradeModel trade,
    double maxInvestment,
  ) {
    final investment = _getInvestment(trade);

    final passed = investment <= maxInvestment;

    return TradeRuleResult(
      key: 'investment',
      label: 'Investment',
      passed: passed,
      message: passed
          ? 'Investment ₹${investment.toStringAsFixed(2)} '
              'is within ₹${maxInvestment.toStringAsFixed(2)} limit.'
          : 'Investment ₹${investment.toStringAsFixed(2)} '
              'exceeds ₹${maxInvestment.toStringAsFixed(2)} limit.',
    );
  }

  // =========================================================
  // ACTIVE TRADES
  // =========================================================

  TradeRuleResult _checkActiveTrades(
    List<TradeModel> existingTrades,
    int maxActiveTrades,
  ) {
    final activeTrades = existingTrades
        .where(
          (trade) =>
              trade.status == TradeStatus.active,
        )
        .length;

    final passed = activeTrades < maxActiveTrades;

    return TradeRuleResult(
      key: 'active-trades',
      label: 'Active Trades',
      passed: passed,
      message: passed
          ? '$activeTrades of $maxActiveTrades '
              'active trade slots used.'
          : 'Maximum $maxActiveTrades active trades reached.',
    );
  }

  // =========================================================
  // MONTHLY LIMIT
  // =========================================================

  TradeRuleResult _checkMonthlyLimit(
    TradeModel trade,
    List<TradeModel> existingTrades,
    int maxTradesPerMonth,
  ) {
    final tradeDate =
        _parseDateOnly(trade.tradeDate);

    final month = tradeDate.month;
    final year = tradeDate.year;

    final tradesThisMonth =
        existingTrades.where((existingTrade) {
      // Waiting trades are Watchlist only.
      if (existingTrade.status ==
          TradeStatus.waiting) {
        return false;
      }

      final existingDate =
          _parseDateOnly(
        existingTrade.tradeDate,
      );

      return existingDate.month == month &&
          existingDate.year == year;
    }).length;

    final passed =
        tradesThisMonth < maxTradesPerMonth;

    return TradeRuleResult(
      key: 'monthly-limit',
      label: 'Monthly Limit',
      passed: passed,
      message: passed
          ? '$tradesThisMonth of $maxTradesPerMonth '
              'monthly trades used.'
          : 'Maximum $maxTradesPerMonth '
              'trades for this month reached.',
    );
  }

  // =========================================================
  // QUARTERLY LIMIT
  // =========================================================

  TradeRuleResult _checkQuarterlyLimit(
    TradeModel trade,
    List<TradeModel> existingTrades,
    int maxTradesPerQuarter,
  ) {
    final quarter =
        _getQuarterInfo(trade.tradeDate);

    // -------------------------------------------------------
    // New trades opened during this quarter
    // -------------------------------------------------------

    final newTradesThisQuarter =
        existingTrades.where((existingTrade) {
      // Waiting trades are Watchlist only.
      if (existingTrade.status ==
          TradeStatus.waiting) {
        return false;
      }

      final openedDate =
          _parseDateOnly(
        existingTrade.tradeDate,
      );

      return _isDateInRange(
        openedDate,
        quarter.start,
        quarter.end,
      );
    }).length;

    // -------------------------------------------------------
    // Previous-quarter trades completed this quarter
    // -------------------------------------------------------

    final previousQuarterCompletions =
        existingTrades.where((existingTrade) {
      // Waiting trades are ignored.
      if (existingTrade.status ==
          TradeStatus.waiting) {
        return false;
      }

      // Only completed trades can have completedAt.
      if (existingTrade.status !=
              TradeStatus.completed ||
          existingTrade.completedAt == null) {
        return false;
      }

      final openedDate =
          _parseDateOnly(
        existingTrade.tradeDate,
      );

      final completedDate =
          _parseDateOnly(
        existingTrade.completedAt!,
      );

      final openedBeforeQuarter =
          openedDate.isBefore(quarter.start);

      final completedThisQuarter =
          _isDateInRange(
        completedDate,
        quarter.start,
        quarter.end,
      );

      return openedBeforeQuarter &&
          completedThisQuarter;
    }).length;

    // -------------------------------------------------------
    // Previous-quarter active trades carried forward
    // -------------------------------------------------------

    final carriedForwardTrades =
        existingTrades.where((existingTrade) {
      // Only active trades can be carried forward.
      if (existingTrade.status !=
          TradeStatus.active) {
        return false;
      }

      final openedDate =
          _parseDateOnly(
        existingTrade.tradeDate,
      );

      return openedDate.isBefore(
        quarter.start,
      );
    }).length;

    // -------------------------------------------------------
    // Quarterly capacity
    // -------------------------------------------------------

    final quarterlyCapacityUsed =
        newTradesThisQuarter +
            previousQuarterCompletions;

    final availableForNewTrades =
        _max(
      0,
      maxTradesPerQuarter -
          carriedForwardTrades -
          quarterlyCapacityUsed,
    );

    final passed =
        availableForNewTrades > 0;

    return TradeRuleResult(
      key: 'quarterly-limit',
      label: 'Quarterly Limit',
      passed: passed,
      message: passed
          ? '$quarterlyCapacityUsed of '
              '$maxTradesPerQuarter quarterly slots used, '
              '$carriedForwardTrades trade(s) carried forward. '
              '$availableForNewTrades new trade slot(s) available.'
          : 'Quarterly limit reached. '
              '$carriedForwardTrades trade(s) carried forward and '
              '$quarterlyCapacityUsed quarterly slot(s) already used.',
    );
  }

  // =========================================================
  // QUARTER HELPERS
  // =========================================================

  _QuarterInfo _getQuarterInfo(
    String dateString,
  ) {
    final date = _parseDateOnly(dateString);

    final year = date.year;
    final month = date.month;

    final quarterStartMonth =
        ((month - 1) ~/ 3) * 3 + 1;

    final start = DateTime(
      year,
      quarterStartMonth,
      1,
    );

    final end = DateTime(
      year,
      quarterStartMonth + 3,
      1,
    );

    return _QuarterInfo(
      start: start,
      end: end,
    );
  }

  DateTime _parseDateOnly(
    String dateString,
  ) {
    final parts = dateString
        .split('-')
        .map(int.parse)
        .toList();

    return DateTime(
      parts[0],
      parts[1],
      parts[2],
    );
  }

  bool _isDateInRange(
    DateTime date,
    DateTime start,
    DateTime end,
  ) {
    return !date.isBefore(start) &&
        date.isBefore(end);
  }

  // =========================================================
  // PORTFOLIO RISK
  // =========================================================

  TradeRuleResult _checkPortfolioRisk(
    TradeModel trade,
    List<TradeModel> existingTrades,
    double totalInvestment,
    double maxPortfolioRiskPercent,
  ) {
    final currentRisk = existingTrades
        .where(
          (existingTrade) =>
              existingTrade.status ==
              TradeStatus.active,
        )
        .fold<double>(
          0,
          (total, existingTrade) =>
              total +
              _getRiskValue(existingTrade),
        );

    final newTradeRisk =
        _getRiskValue(trade);

    final totalRisk =
        currentRisk + newTradeRisk;

    final maxPortfolioRisk =
        totalInvestment *
            maxPortfolioRiskPercent /
            100;

    final passed =
        totalRisk <= maxPortfolioRisk;

    return TradeRuleResult(
      key: 'portfolio-risk',
      label: 'Portfolio Risk',
      passed: passed,
      message: passed
          ? 'Portfolio risk ₹${totalRisk.toStringAsFixed(2)} '
              'is within ₹${maxPortfolioRisk.toStringAsFixed(2)} limit.'
          : 'Portfolio risk ₹${totalRisk.toStringAsFixed(2)} '
              'exceeds ₹${maxPortfolioRisk.toStringAsFixed(2)} limit.',
    );
  }

  // =========================================================
  // CALCULATIONS
  // =========================================================

  double _getInvestment(
    TradeModel trade,
  ) {
    return trade.entryPrice * trade.quantity;
  }

  double _getRiskValue(
    TradeModel trade,
  ) {
    final riskPerShare =
        (trade.entryPrice - trade.stopLoss).abs();

    return riskPerShare * trade.quantity;
  }

  double _getRiskPercentage(
    TradeModel trade,
  ) {
    if (trade.entryPrice <= 0) {
      return 0;
    }

    final riskPerShare =
        (trade.entryPrice - trade.stopLoss).abs();

    return (riskPerShare /
            trade.entryPrice) *
        100;
  }

  // =========================================================
  // CAN START NEW TRADE
  // =========================================================

  Future<bool> canStartNewTrade(
    List<TradeModel> trades,
  ) async {
    final settings =
        await _settingsService.getSettings();

    // -------------------------------------------------------
    // 1. Active trade capacity
    // -------------------------------------------------------

    final activeTrades = trades
        .where(
          (trade) =>
              trade.status == TradeStatus.active,
        )
        .length;

    if (activeTrades >=
        settings.maxActiveTrades) {
      return false;
    }

    // -------------------------------------------------------
    // 2. Monthly new-trade capacity
    // -------------------------------------------------------

    final today = DateTime.now();

    final todayString =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final previewTrade = TradeModel(
      id: 'new-trade-preview',
      symbol: 'Preview',
      tradeDate: todayString,
      entryPrice: 1,
      stopLoss: 1,
      initialSL: 1,
      quantity: 1,
      status: TradeStatus.active,
      notes: '',
    );

    final monthlyResult =
        _checkMonthlyLimit(
      previewTrade,
      trades,
      settings.maxTradesPerMonth,
    );

    if (!monthlyResult.passed) {
      return false;
    }

    // -------------------------------------------------------
    // 3. Quarterly new-trade capacity
    // -------------------------------------------------------

    final quarterlyResult =
        _checkQuarterlyLimit(
      previewTrade,
      trades,
      settings.maxTradesPerThreeMonths,
    );

    if (!quarterlyResult.passed) {
      return false;
    }

    // -------------------------------------------------------
    // 4. Current portfolio risk
    // -------------------------------------------------------

    final currentPortfolioRisk = trades
        .where(
          (trade) =>
              trade.status == TradeStatus.active,
        )
        .fold<double>(
          0,
          (total, trade) =>
              total + _getRiskValue(trade),
        );

    final maxPortfolioRisk =
        settings.totalInvestment *
            settings.maxPortfolioRiskPercent /
            100;

    if (currentPortfolioRisk >=
        maxPortfolioRisk) {
      return false;
    }

    // There is currently capacity.
    // Actual trade details are checked later.
    return true;
  }

  // =========================================================
  // NEW TRADE BLOCK REASON
  // =========================================================

  Future<String?> getNewTradeBlockReason(
    List<TradeModel> trades,
  ) async {
    final settings =
        await _settingsService.getSettings();

    // -------------------------------------------------------
    // 1. Active trade capacity
    // -------------------------------------------------------

    final activeTrades = trades
        .where(
          (trade) =>
              trade.status == TradeStatus.active,
        )
        .length;

    if (activeTrades >=
        settings.maxActiveTrades) {
      return 'Maximum active trades reached: '
          '$activeTrades / '
          '${settings.maxActiveTrades}.';
    }

    // -------------------------------------------------------
    // 2. Monthly capacity
    // -------------------------------------------------------

    final today = DateTime.now();

    final todayString =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final previewTrade = TradeModel(
      id: 'new-trade-preview',
      symbol: 'Preview',
      tradeDate: todayString,
      entryPrice: 1,
      stopLoss: 1,
      initialSL: 1,
      quantity: 1,
      status: TradeStatus.active,
      notes: '',
    );

    final monthlyResult =
        _checkMonthlyLimit(
      previewTrade,
      trades,
      settings.maxTradesPerMonth,
    );

    if (!monthlyResult.passed) {
      return monthlyResult.message;
    }

    // -------------------------------------------------------
    // 3. Quarterly capacity
    // -------------------------------------------------------

    final quarterlyResult =
        _checkQuarterlyLimit(
      previewTrade,
      trades,
      settings.maxTradesPerThreeMonths,
    );

    if (!quarterlyResult.passed) {
      return quarterlyResult.message;
    }

    // -------------------------------------------------------
    // 4. Portfolio risk
    // -------------------------------------------------------

    final currentPortfolioRisk = trades
        .where(
          (trade) =>
              trade.status == TradeStatus.active,
        )
        .fold<double>(
          0,
          (total, trade) =>
              total + _getRiskValue(trade),
        );

    final maxPortfolioRisk =
        settings.totalInvestment *
            settings.maxPortfolioRiskPercent /
            100;

    if (currentPortfolioRisk >=
        maxPortfolioRisk) {
      return 'Portfolio risk limit reached: '
          '₹${currentPortfolioRisk.toStringAsFixed(2)} / '
          '₹${maxPortfolioRisk.toStringAsFixed(2)}.';
    }

    // Trade can be started.
    return null;
  }

  int _max(
    int first,
    int second,
  ) {
    return first > second ? first : second;
  }
}

class _QuarterInfo {
  final DateTime start;
  final DateTime end;

  const _QuarterInfo({
    required this.start,
    required this.end,
  });
}