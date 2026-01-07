import '../models/trade_model.dart';
import '../v2/trade_action_log.dart';
import 'trade_validation_result.dart';

class TradeV2AddOnValidator {
  static TradeAddOnValidationResult canOpenAddOn({
    required TradeModel trade,
  }) {
    // 1️⃣ Trade must be active
    if (trade.quantity <= 0) {
      return const TradeAddOnValidationResult.denied(
        'Add-On not allowed on closed trade',
      );
    }

    // 2️⃣ R1 booking must exist
    final hasR1 = trade.actions.any(
      (a) => a.kind == TradeActionKind.rBooking,
    );

    if (!hasR1) {
      return const TradeAddOnValidationResult.denied(
        'Complete R1 booking before Add-On',
      );
    }

    // 3️⃣ Max actions
    if (trade.actions.length >= 4) {
      return const TradeAddOnValidationResult.denied(
        'Maximum actions reached',
      );
    }

    // 4️⃣ Remaining position must be in profit
    final double profitPerShare =
        trade.stopLoss - trade.entryPrice;

    if (profitPerShare <= 0) {
      return const TradeAddOnValidationResult.denied(
        'Add-On not allowed when remaining position is in loss',
      );
    }

    // 5️⃣ Remaining profit must be at least 25%
    final double profitPercent =
        (profitPerShare / trade.entryPrice) * 100;

    if (profitPercent < 25) {
      return const TradeAddOnValidationResult.denied(
        'Remaining position must be at least 25% in profit',
      );
    }

    return const TradeAddOnValidationResult.allowed();
  }
}
