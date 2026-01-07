import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/validators/trade_validation_result.dart';

class TradeV2ActionValidator {
  static TradeAddOnValidationResult validateAddOnConfirm({
    required TradeModel trade,
    required double addOnPrice,
    required int addOnQuantity,
  }) {
    final remainingQty = trade.quantity;

    final totalPnlAtSl =
        (remainingQty * (trade.stopLoss - trade.entryPrice)) +
        (addOnQuantity * (trade.stopLoss - addOnPrice));

    final totalInvested =
        (remainingQty * trade.entryPrice) +
        (addOnQuantity * addOnPrice);

    final profitPercent =
        (totalPnlAtSl / totalInvested) * 100;

    if (profitPercent < 10) {
      return const TradeAddOnValidationResult.denied(
        'Trade must remain at least 10% profitable after Add-On',
      );
    }

    return const TradeAddOnValidationResult.allowed();
  }
}
