import '../models/trade_model.dart';
import '../models/trade_action_type.dart';
import '../validators/trade_v2_action_validator.dart';
import '../validators/trade_v2_addon_validator.dart';
import 'r_booking_calculator.dart';
import 'trade_action_log.dart';
import 'trade_v2_execution_result.dart';

class TradeV2Executor {
  static TradeV2ExecutionResult execute({
    required TradeModel trade,
    required TradeActionType action,
    int? addQty,
    double? addPrice,
  }) {
    TradeV2ActionValidator.validate(trade: trade, action: action);

    switch (action) {
      case TradeActionType.rBooking:
        return _rBooking(trade);

      case TradeActionType.addOn:
        if (addQty == null || addPrice == null) {
          throw Exception('Add-On requires qty & price');
        }
        return _addOn(trade, addQty, addPrice);
    }
  }

  static TradeV2ExecutionResult _rBooking(TradeModel trade) {
    final sellQty = RBookingCalculator.calculateQty(trade: trade);

    final action = TradeActionLog(
      kind: TradeActionKind.rBooking,
      quantity: sellQty,
      price: trade.entryPrice + trade.rValue,
      pnl: sellQty * trade.rValue,
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

  static TradeV2ExecutionResult _addOn(
    TradeModel trade,
    int qty,
    double price,
  ) {
    TradeV2AddOnValidator.validate(
      trade: trade,
      addQty: qty,
      addPrice: price,
      stopLoss: trade.stopLoss,
    );

    final action = TradeActionLog(
      kind: TradeActionKind.addOn,
      quantity: qty,
      price: price,
      pnl: 0,
      timestamp: DateTime.now(),
    );

    final updatedTrade = trade.copyWith(
      quantity: trade.quantity + qty,
      actions: [...trade.actions, action],
    );

    return TradeV2ExecutionResult(
      trade: updatedTrade,
      actionLog: action,
    );
  }

  /// ✅ SAFE UNDO
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
