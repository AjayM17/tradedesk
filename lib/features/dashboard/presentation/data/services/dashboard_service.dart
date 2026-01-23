import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart'
    show TradeStatus, TradeUiModel;

import '../models/dashboard_metrics.dart';

class DashboardService {
  final TradeFirestoreService _tradeService;

  // 🔒 TEMP: move to Settings later
  static const double totalCapital = 1000000; // ₹10,00,000
  static const double maxPortfolioRiskPercent = 0.03; // 3%

  DashboardService(this._tradeService);

  Future<DashboardMetrics> loadMetrics() async {
    final List<TradeUiModel> trades =
        await _tradeService.getTradesOnce();

    double lossAmount = 0;
    double riskUsed = 0;

    int totalTrades = trades.length;
    int tradesInProfit = 0;
    int tradesInLoss = 0;

    for (final trade in trades) {
      // ─────────────────────
      // PROFIT / LOSS COUNT
      // ─────────────────────
      if (trade.pnlValue > 0) {
        tradesInProfit++;
      } else if (trade.pnlValue < 0) {
        tradesInLoss++;
      }

      // ─────────────────────
      // LOSS AMOUNT (₹)
      // already lost money
      // ─────────────────────
      if (trade.pnlValue < 0) {
        lossAmount += trade.pnlValue.abs();
      }

      // ─────────────────────
      // RISK USED (₹)
      // only ACTIVE trades
      // ─────────────────────
      if (trade.status == TradeStatus.active) {
        riskUsed += trade.remainingRisk;
      }
    }

    final double maxRisk =
        totalCapital * maxPortfolioRiskPercent;

    final double remainingRisk =
        (maxRisk - riskUsed).clamp(0, maxRisk);

    return DashboardMetrics(
      lossAmount: lossAmount,
      remainingRisk: remainingRisk,
      totalTrades: totalTrades,
      tradesInProfit: tradesInProfit,
      tradesInLoss: tradesInLoss,
    );
  }
}
