import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/v2/trade_action_log.dart';

enum TradeStatus { active, free, closed }

class TradeUiModel {
  final String id;
  final String name;
  final TradeStatus status;
  final TradeModel trade;

  final double pnlValue;
  final double pnlPercent;
  final int ageInDays;
  final DateTime tradeDate;

  const TradeUiModel({
    required this.id,
    required this.name,
    required this.status,
    required this.trade,
    required this.pnlValue,
    required this.pnlPercent,
    required this.ageInDays,
    required this.tradeDate,
  });

  // ───────── BASIC PASSTHROUGHS ─────────

  /// Original quantity stored in Firestore.
  int get quantity => trade.quantity;

  /// Quantity used for calculations.
  /// After Partial Book, only 50% quantity is considered.
  int get effectiveQuantity =>
      partialBooked ? (trade.quantity * 0.5).floor() : trade.quantity;

  double get stopLoss => trade.stopLoss;
  double get initialStopLoss => trade.initialStopLoss;
  List<TradeActionLog> get actions => trade.actions;

  bool get isLocked => trade.actions.length >= 4;
  bool get partialBooked => trade.partialBooked;

  // ───────── BUY LOGIC ─────────

  double get averageBuyPrice => trade.entryPrice;

  // ───────── DERIVED UI VALUES ─────────

  double get buyPrice => averageBuyPrice;

  /// Investment based on effective quantity.
  double get investedAmount => averageBuyPrice * effectiveQuantity;

  // ───────── DASHBOARD HELPERS ─────────

  bool get isActive => status == TradeStatus.active;

  bool get isInProfit => pnlValue > 0;

  bool get isInLoss => pnlValue < 0;

  /// Remaining downside risk.
  double get remainingRisk {
    if (!isActive) return 0;

    final riskPerUnit = buyPrice - stopLoss;
    if (riskPerUnit <= 0) return 0;

    return riskPerUnit * effectiveQuantity;
  }

  double get entryPrice => trade.entryPrice;
}