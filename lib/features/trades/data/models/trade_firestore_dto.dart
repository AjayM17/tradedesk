import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreDto {
  final String id;
  final Map<String, dynamic> data;

  TradeFirestoreDto({
    required this.id,
    required this.data,
  });

  TradeUiModel toUiModel() {
    final double entryPrice = (data['entryprice'] as num).toDouble();
    final int quantity = data['quantity'] as int;
    final double stopLoss = (data['stoploss'] as num).toDouble();
    final double initialStopLoss =
        (data['initial_stoploss'] as num).toDouble();

    // ── Derived values
    final int partialQuantity = (quantity * 0.25).floor();
    final double investedAmount = entryPrice * quantity;

    // P&L based on SL (as per your rule)
    final double pnlValue = (stopLoss - entryPrice) * quantity;
    final double pnlPercent =
        investedAmount == 0 ? 0 : (pnlValue / investedAmount) * 100;

    // 1R target (per-unit, NOT multiplied by quantity)
    final double oneRTarget = (entryPrice - initialStopLoss).abs();

    // Trade age calculation
    final DateTime tradeDate = DateTime.parse(data['trade_date']);
    final int ageInDays =
        DateTime.now().difference(tradeDate).inDays;

    return TradeUiModel(
      id:id,
      name: data['name'] as String,
      status: TradeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TradeStatus.active,
      ),
      quantity: quantity,
      partialQuantity: partialQuantity,
      investedAmount: investedAmount,
      pnlValue: pnlValue,
      pnlPercent: pnlPercent,
      buyPrice: entryPrice,
      stopLoss: stopLoss,
      initialStopLoss: initialStopLoss,
      oneRTarget: oneRTarget,
      ageInDays: ageInDays,
      tradeDate:tradeDate,
      isR1Booked:
          (data['isPartialProfitBooked'] as bool?) ?? false,
    );
  }
}
