enum TradeStatus {
  active,
  free,
  closed,
}

class TradeUiModel {
  // ── Identity
  final String name;
  final TradeStatus status;

  // ── Position
  final int quantity;
  final int partialQuantity; // 25% qty
  final double investedAmount;

  // ── Performance
  final double pnlValue; // ₹
  final double pnlPercent; // %

  // ── Prices & Risk
  final double buyPrice;
  final double stopLoss;
  final double initialStopLoss;
  final double oneRTarget;

  // ── Meta
  final int ageInDays;
  final bool isPartialProfitBooked;

  const TradeUiModel({
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
    required this.isPartialProfitBooked,
  });
}
