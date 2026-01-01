class TradeModel {
  final String? tradeId;
  final double entryPrice;
  final double stopLoss;
  final int quantity;

  TradeModel({
    required this.tradeId,
    required this.entryPrice,
    required this.stopLoss,
    required this.quantity,
  });

   /// Risk per share (ONLY downside risk)
  double get riskPerShare {
    final risk = entryPrice - stopLoss;
    return risk > 0 ? risk : 0;
  }

  double get totalRisk =>
      riskPerShare * quantity;

  double get investedAmount =>
      entryPrice * quantity;
}
