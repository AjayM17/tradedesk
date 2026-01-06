import '../v2/trade_action_log.dart';
import 'trade_action_step.dart';

class TradeModel {
  // ───────── CORE ─────────
  final String? tradeId;
  final double entryPrice;
  final double stopLoss;
  final int quantity;

  // ───────── R (IMMUTABLE) ─────────
  final double initialStopLoss;
  final double rValue;

  // ───────── ACTIONS (SOURCE OF TRUTH) ─────────
  final List<TradeActionLog> actions;

  const TradeModel({
    required this.tradeId,
    required this.entryPrice,
    required this.stopLoss,
    required this.quantity,
    required this.initialStopLoss,
    required this.rValue,
    this.actions = const [],
  });

  // ───────── COUNTS ─────────

  int get actionCount => actions.length;

  int get rBookingCount =>
      actions.where((a) => a.kind == TradeActionKind.rBooking).length;

  int get addOnCount =>
      actions.where((a) => a.kind == TradeActionKind.addOn).length;

  // ───────── STEP (DERIVED — FIXES YOUR ERROR) ─────────
  TradeActionStep get step {
    if (actions.isEmpty) return TradeActionStep.none;

    final last = actions.last;

    if (last.kind == TradeActionKind.rBooking) {
      return rBookingCount == 1
          ? TradeActionStep.r1Done
          : TradeActionStep.r2Done;
    }

    if (last.kind == TradeActionKind.addOn) {
      return addOnCount == 1
          ? TradeActionStep.addOn1Done
          : TradeActionStep.addOn2Done;
    }

    return TradeActionStep.none;
  }

  // ───────── RISK ─────────

  double get riskPerShare {
    final r = entryPrice - initialStopLoss;
    return r > 0 ? r : 0;
  }

  double get totalRisk => riskPerShare * quantity;

  double get investedAmount => entryPrice * quantity;

  // ───────── IMMUTABLE UPDATE ─────────
  TradeModel copyWith({
    double? stopLoss,
    int? quantity,
    List<TradeActionLog>? actions,
  }) {
    return TradeModel(
      tradeId: tradeId,
      entryPrice: entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      quantity: quantity ?? this.quantity,
      initialStopLoss: initialStopLoss,
      rValue: rValue,
      actions: actions ?? this.actions,
    );
  }
}
