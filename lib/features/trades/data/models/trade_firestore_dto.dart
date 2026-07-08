import '../models/trade_model.dart';
import '../v2/trade_action_log.dart';
import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreDto {
  final String id;
  final Map<String, dynamic> data;

  TradeFirestoreDto({
    required this.id,
    required this.data,
  });

  TradeUiModel toUiModel() {
    final entry = (data['entryprice'] as num).toDouble();
    final sl = (data['stoploss'] as num).toDouble();
    final initSl = (data['initial_stoploss'] as num).toDouble();
    final qty = (data['quantity'] as num).toInt();

    final actions = (data['actions'] as List<dynamic>? ?? [])
        .map(
          (e) => TradeActionLog.fromMap(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();

    final trade = TradeModel(
      tradeId: id,
      entryPrice: entry,
      stopLoss: sl,
      quantity: qty,
      initialStopLoss: initSl,
      rValue: (entry - initSl).abs(),
      actions: actions,
      partialBooked: data['partialBooked'] ?? false,
    );

    // ─────────────────────────────────────
    // BUY SIDE (Cost Basis)
    // ─────────────────────────────────────

    int initialQty = qty;

    for (final a in actions) {
      if (a.kind == TradeActionKind.rBooking) {
        initialQty += a.quantity;
      }
    }

    double totalBuyCost = entry * initialQty;
    int totalBuyQty = initialQty;

    final double averageBuyPrice =
        totalBuyQty > 0 ? totalBuyCost / totalBuyQty : entry;

    // ─────────────────────────────────────
    // Effective Quantity
    // Use only 50% quantity after Partial Book
    // ─────────────────────────────────────

    final int effectiveQty = trade.partialBooked
        ? (qty * 0.5).floor()
        : qty;

    // ─────────────────────────────────────
    // P&L
    // ─────────────────────────────────────

    final double pnlValue =
        (sl - averageBuyPrice) * effectiveQty;

    final double pnlPercent =
        averageBuyPrice == 0
            ? 0
            : ((sl - averageBuyPrice) / averageBuyPrice) * 100;

    final tradeDate = DateTime.parse(data['trade_date']);

    return TradeUiModel(
      id: id,
      name: data['name'],
      status: TradeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TradeStatus.active,
      ),
      trade: trade,
      pnlValue: pnlValue,
      pnlPercent: pnlPercent,
      ageInDays: DateTime.now().difference(tradeDate).inDays,
      tradeDate: tradeDate,
    );
  }
}