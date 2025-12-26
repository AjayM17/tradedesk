import '../../../settings/data/settings_state.dart';
import '../models/trade_model.dart';
import '../models/trade_validation_result.dart';

class TradeValidator {
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

    // ✅ All rules passed
    return const TradeValidationResult.valid();
  }
}
