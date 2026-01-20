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
  int get quantity => trade.quantity;
  double get stopLoss => trade.stopLoss;
  double get initialStopLoss => trade.initialStopLoss;
  List<TradeActionLog> get actions => trade.actions;

  bool get isLocked => trade.actions.length >= 4;

  // ───────── ENTRY / BUY LOGIC ─────────

  /// Reconstruct initial entry quantity
  /// (before any sell or add-on)
  int get initialQuantity {
    int qty = trade.quantity;

    for (final a in trade.actions) {
      if (a.kind == TradeActionKind.rBooking) {
        qty += a.quantity; // sold earlier
      } else if (a.kind == TradeActionKind.addOn) {
        qty -= a.quantity; // bought later
      }
    }

    return qty;
  }

  /// Average buy price (ONLY BUY prices)
  /// Sell actions do NOT affect cost basis
  double get averageBuyPrice {
    double totalCost = trade.entryPrice * initialQuantity;
    int totalQty = initialQuantity;

    for (final a in trade.actions) {
      if (a.kind == TradeActionKind.addOn) {
        totalCost += a.price * a.quantity;
        totalQty += a.quantity;
      }
    }

    return totalQty > 0 ? totalCost / totalQty : trade.entryPrice;
  }

  // ───────── DERIVED UI VALUES ─────────

  /// For UI display only
  double get buyPrice => averageBuyPrice;

  /// Invested amount based on current quantity & avg buy
  double get investedAmount => averageBuyPrice * trade.quantity;

  // ───────── DASHBOARD HELPERS ─────────

  bool get isActive => status == TradeStatus.active;

  bool get isInProfit => pnlValue > 0;

  bool get isInLoss => pnlValue < 0;

  /// Remaining downside risk in ₹
  /// (only for active trades)
  double get remainingRisk {
    if (!isActive) return 0;

    final riskPerUnit = buyPrice - stopLoss;
    if (riskPerUnit <= 0) return 0;

    return riskPerUnit * quantity;
  }
}
