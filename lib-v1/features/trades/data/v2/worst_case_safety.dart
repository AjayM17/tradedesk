import '../models/trade_model.dart';

class WorstCaseSafety {

  /// After Add-On:
  /// If SL hits immediately → final P&L must be >= 0
  static bool isSafe({
    required TradeModel trade,
    required int addQty,
    required double addPrice,
    required double stopLoss,
  }) {
    final currentPnL =
        (stopLoss - trade.entryPrice) * trade.quantity;

    final addPnL =
        (stopLoss - addPrice) * addQty;

    final finalPnL = currentPnL + addPnL;

    return finalPnL >= 0;
  }
}
