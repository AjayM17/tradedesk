import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart'
    show TradeStatus, TradeUiModel;

import '../models/dashboard_metrics.dart';

class DashboardService {
  final TradeFirestoreService _tradeService;

  // 🔒 Move to Settings later
  static const double totalCapital = 1000000; // ₹10,00,000
  static const double maxPortfolioRiskPercent = 0.05; // 5%

  DashboardService(this._tradeService);

  /// ✅ Always compute risk dynamically (no stale data)
double _calculateCurrentRisk(TradeUiModel trade) {
  if (trade.quantity <= 0) return 0;

  final diff = trade.entryPrice - trade.stopLoss;

  if (diff <= 0) return 0; // 🔥 important line

  return diff * trade.quantity;
}
  Future<DashboardMetrics> loadMetrics({
    bool includeProfits = false,
  }) async {
    final List<TradeUiModel> trades = await _tradeService.getTradesOnce();

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
      // LOSS / NET P&L
      // ─────────────────────
      if (includeProfits) {
        lossAmount += trade.pnlValue; // net mode
      } else {
        if (trade.pnlValue < 0) {
          lossAmount += trade.pnlValue.abs(); // loss only
        }
      }

      // ─────────────────────
      // RISK USED (ONLY ACTIVE TRADES)
      // ✅ Dynamic calculation
      // ─────────────────────
      if (trade.status == TradeStatus.active) {
        riskUsed += _calculateCurrentRisk(trade);
      }
    }

    // Normalize for UI
    if (includeProfits) {
      lossAmount = lossAmount.abs();
    }

    final double maxRisk = totalCapital * maxPortfolioRiskPercent;

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

  Future<List<TradeUiModel>> loadLast100Trades() async {
    return _tradeService.getLast100ClosedTrades();
  }

  double calculateWinRate(List<TradeUiModel> trades) {
    if (trades.isEmpty) return 0;

    final wins = trades.where((t) => t.pnlValue > 0).length;

    return (wins / trades.length) * 100;
  }
}