class TradeModel {
  final double entryPrice;
  final double stopLoss;
  final int quantity;

  TradeModel({
    required this.entryPrice,
    required this.stopLoss,
    required this.quantity,
  });

  /// Risk per share
  double get riskPerShare =>
      (entryPrice - stopLoss).abs();

  /// Total risk for this trade
  double get totalRisk =>
      riskPerShare * quantity;

  /// Capital deployed
  double get investedAmount =>
      entryPrice * quantity;
}
