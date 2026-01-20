class DashboardMetrics {
  final double lossAmount;
  final double remainingRisk;

  final int totalTrades;
  final int tradesInProfit;
  final int tradesInLoss;

  const DashboardMetrics({
    required this.lossAmount,
    required this.remainingRisk,
    required this.totalTrades,
    required this.tradesInProfit,
    required this.tradesInLoss,
  });
}
