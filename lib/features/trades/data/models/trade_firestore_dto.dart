import 'package:trade_desk/features/trades/data/models/r1_booking.dart';
import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreDto {
  final String id;
  final Map<String, dynamic> data;

  TradeFirestoreDto({required this.id, required this.data});

  TradeUiModel toUiModel() {
    final double entryPrice = (data['entryprice'] as num).toDouble();
    final int quantity = data['quantity'] as int;
    final double stopLoss = (data['stoploss'] as num).toDouble();
    final double initialStopLoss =
        (data['initial_stoploss'] as num).toDouble();

    // ───────── R1 ─────────
    final Map<String, dynamic>? r1Data =
        data['r1'] != null ? Map<String, dynamic>.from(data['r1']) : null;

    final R1Booking? r1 =
        r1Data != null ? R1Booking.fromMap(r1Data) : null;

    // ───────── Quantities ─────────
    final int remainingQuantity =
        r1 == null ? quantity : quantity - r1.quantity;

    final int partialQuantity = (quantity * 0.25).floor();

    // ───────── P&L (ACTIVE POSITION ONLY) ─────────
    final double pnlValue =
        (stopLoss - entryPrice) * remainingQuantity;

    final double pnlPercent = remainingQuantity == 0
        ? 0
        : (pnlValue / (entryPrice * remainingQuantity)) * 100;

    // ───────── 1R target (per unit) ─────────
    final double oneRTarget =
        (entryPrice - initialStopLoss).abs();

    // ───────── Trade age ─────────
    final DateTime tradeDate = DateTime.parse(data['trade_date']);
    final int ageInDays =
        DateTime.now().difference(tradeDate).inDays;

    return TradeUiModel(
      id: id,
      name: data['name'] as String,
      status: TradeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TradeStatus.active,
      ),
      quantity: quantity,
      partialQuantity: partialQuantity,
      pnlValue: pnlValue,
      pnlPercent: pnlPercent,
      buyPrice: entryPrice,
      stopLoss: stopLoss,
      initialStopLoss: initialStopLoss,
      oneRTarget: oneRTarget,
      ageInDays: ageInDays,
      tradeDate: tradeDate,
      r1: r1,
    );
  }
}
