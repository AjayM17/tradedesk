import '../../../settings/data/settings_state.dart';
import '../models/trade_model.dart';
import '../models/trade_validation_result.dart';
import 'dart:math';


class TradeValidator {
  static const double maxPortfolioRiskPercent = 6.0;

  // =========================================================
  // SINGLE TRADE VALIDATION (UNCHANGED)
  // =========================================================
  static TradeValidationResult validateNewTrade({
    required TradeModel trade,
    required SettingsState settings,
  }) {
    // 1️⃣ Stop-loss is mandatory
    if (trade.stopLoss <= 0 ||
        trade.stopLoss == trade.entryPrice) {
      return const TradeValidationResult.invalid(
        'Stop-loss is mandatory',
      );
    }

    // 2️⃣ Risk per trade
    if (trade.totalRisk >
        settings.riskAmountPerTrade) {
      return TradeValidationResult.invalid(
        'Risk exceeds ₹${settings.riskAmountPerTrade.toStringAsFixed(0)}',
      );
    }

    // 3️⃣ Max capital per stock
    if (trade.investedAmount >
        settings.maxCapitalPerStockAmount) {
      return const TradeValidationResult.invalid(
        'Capital exceeds per-stock limit',
      );
    }

    return const TradeValidationResult.valid();
  }

  // =========================================================
  // PORTFOLIO RISK VALIDATION (EDIT-SAFE)
  // =========================================================
static TradeValidationResult validatePortfolioRisk({
  required TradeModel newTrade,
  required List<TradeModel> activeTrades,
  required SettingsState settings,
  String? editingTradeId,
}) {
  double existingRisk = 0;
  int existingQty = 0;

  for (final trade in activeTrades) {
    if (editingTradeId != null &&
        trade.tradeId != null &&
        trade.tradeId == editingTradeId) {
      // ✅ capture existing qty
      existingQty = trade.quantity;
      continue;
    }
    existingRisk += trade.totalRisk;
  }

  final double maxAllowedRisk =
      (settings.totalCapital * maxPortfolioRiskPercent) / 100;

  final double riskPerShare =
      (newTrade.entryPrice - newTrade.stopLoss).abs();

  if (riskPerShare <= 0) {
    return const TradeValidationResult.valid();
  }

  final double remainingRisk = maxAllowedRisk - existingRisk;

  final int portfolioQty = remainingRisk > 0
      ? (remainingRisk / riskPerShare).floor()
      : 0;

  // ✅ SAME RULE AS UI
  final int allowedQty = editingTradeId != null
      ? max(portfolioQty, existingQty)
      : portfolioQty;

  if (newTrade.quantity > allowedQty) {
    return TradeValidationResult.invalid(
      'Portfolio risk limit exceeded.\n'
      'Max allowed qty: $allowedQty',
    );
  }

  return const TradeValidationResult.valid();
}



}
