import '../models/trade_model.dart';
import '../v2/wap_calculator.dart';
import '../v2/worst_case_safety.dart';

class TradeV2AddOnValidator {

  static void validate({
    required TradeModel trade,
    required int addQty,
    required double addPrice,
    required double stopLoss,
  }) {
    // Must already be profitable
    if ((addPrice - trade.entryPrice) <= 0) {
      throw Exception('Trade not in profit');
    }

    // Quantity cap ≤ 25%
    final maxAddQty = (trade.quantity * 0.25).floor();
    if (addQty <= 0 || addQty > maxAddQty) {
      throw Exception('Add-On quantity exceeds limit');
    }

    // SL tightening only
    if (stopLoss < trade.stopLoss) {
      throw Exception('Stop-loss cannot be widened');
    }

    // SL ≥ WAP
    final wap = WapCalculator.calculate(
      currentQty: trade.quantity.toDouble(),
      currentAvgPrice: trade.entryPrice,
      addQty: addQty.toDouble(),
      addPrice: addPrice,
    );

    if (stopLoss < wap) {
      throw Exception('Stop-loss below weighted average price');
    }

    // Worst-case safety
    final safe = WorstCaseSafety.isSafe(
      trade: trade,
      addQty: addQty,
      addPrice: addPrice,
      stopLoss: stopLoss,
    );

    if (!safe) {
      throw Exception('Worst-case safety violated');
    }
  }
}
