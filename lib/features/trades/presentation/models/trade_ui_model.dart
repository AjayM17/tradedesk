enum TradeStatus {
  active,
  free,
  closed,
}

class TradeUiModel {
  final String id;
  final String name;
  final TradeStatus status;
  final int quantity;
  final int partialQuantity;
  final double investedAmount;
  final double pnlValue;
  final double pnlPercent;
  final double buyPrice;
  final double stopLoss;
  final double initialStopLoss;
  final double oneRTarget;
  final int ageInDays;
  final bool isR1Booked;
  final DateTime tradeDate; // ✅ ADD THIS

  TradeUiModel({
    required this.id,
    required this.name,
    required this.status,
    required this.quantity,
    required this.partialQuantity,
    required this.investedAmount,
    required this.pnlValue,
    required this.pnlPercent,
    required this.buyPrice,
    required this.stopLoss,
    required this.initialStopLoss,
    required this.oneRTarget,
    required this.ageInDays,
    required this.isR1Booked,
    required this.tradeDate, // ✅
  });
}
