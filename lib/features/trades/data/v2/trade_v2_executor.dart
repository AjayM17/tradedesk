import '../models/trade_model.dart';
import 'trade_action_log.dart';
import 'trade_v2_execution_result.dart';
import 'r_booking_calculator.dart';

class TradeV2Executor {
  /// ───────── R1 BOOKING ─────────
  static TradeV2ExecutionResult executeRBooking({
    required TradeModel trade,
    required double executionPrice,
  }) {
    final int sellQty = RBookingCalculator.calculateQty(trade: trade);

    final action = TradeActionLog(
      kind: TradeActionKind.rBooking,
      quantity: sellQty,
      price: executionPrice,
      pnl: (executionPrice - trade.entryPrice) * sellQty,
      timestamp: DateTime.now(),
    );

    final updatedTrade = trade.copyWith(
      quantity: trade.quantity - sellQty,
      actions: [...trade.actions, action],
    );

    return TradeV2ExecutionResult(
      trade: updatedTrade,
      actionLog: action,
    );
  }

  /// ───────── ADD-ON ─────────
  static TradeV2ExecutionResult executeAddOn({
    required TradeModel trade,
    required int quantity,
    required double price,
  }) {
    final action = TradeActionLog(
      kind: TradeActionKind.addOn,
      quantity: quantity,
      price: price,
      pnl: 0, // Add-On does not realize P&L
      timestamp: DateTime.now(),
    );

    final updatedTrade = trade.copyWith(
      quantity: trade.quantity + quantity,
      actions: [...trade.actions, action],
    );

    return TradeV2ExecutionResult(
      trade: updatedTrade,
      actionLog: action,
    );
  }

  /// ───────── UNDO (SAFE) ─────────
  static TradeModel undoLastAction({
    required TradeModel trade,
  }) {
    if (trade.actions.isEmpty) {
      throw Exception('No action to undo');
    }

    final lastAction = trade.actions.last;
    final remainingActions =
        trade.actions.sublist(0, trade.actions.length - 1);

    int restoredQuantity = trade.quantity;

    switch (lastAction.kind) {
      case TradeActionKind.rBooking:
        restoredQuantity += lastAction.quantity;
        break;

      case TradeActionKind.addOn:
        restoredQuantity -= lastAction.quantity;
        break;
    }

    return trade.copyWith(
      quantity: restoredQuantity,
      actions: remainingActions,
    );
  }
}
