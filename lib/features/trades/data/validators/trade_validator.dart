import '../../../settings/data/settings_state.dart';
import '../models/trade_model.dart';
import '../models/trade_validation_result.dart';

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
  String? editingTradeId, // 👈 important
}) {
  double existingRisk = 0;

  for (final trade in activeTrades) {
    // ✅ EXCLUDE the same trade while editing
    if (editingTradeId != null &&
        trade.tradeId != null &&
        trade.tradeId == editingTradeId) {
      continue;
    }

    existingRisk += trade.totalRisk;
  }

  final double maxAllowedRisk =
      (settings.totalCapital * maxPortfolioRiskPercent) / 100;

  final double finalRisk =
      existingRisk + newTrade.totalRisk;

  if (finalRisk > maxAllowedRisk) {
    return TradeValidationResult.invalid(
      'Portfolio risk limit exceeded.\n'
      'Allowed: ₹${maxAllowedRisk.toStringAsFixed(0)}\n'
      'Used: ₹${finalRisk.toStringAsFixed(0)}',
    );
  }

  return const TradeValidationResult.valid();
}

}
