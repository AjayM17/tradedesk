import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart'
    show TradeStatus, TradeUiModel;

import '../models/dashboard_metrics.dart';

class DashboardService {
  final TradeFirestoreService _tradeService;

  static const double totalCapital = 1000000; // ₹10,00,000
  static const double maxPortfolioRiskPercent = 0.05; // 5%

  DashboardService(this._tradeService);

  double _calculateCurrentRisk(TradeUiModel trade) {
    if (trade.effectiveQuantity <= 0) return 0;

    final diff = trade.entryPrice - trade.stopLoss;

    if (diff <= 0) return 0;

    return diff * trade.effectiveQuantity;
  }

  Stream<DashboardMetrics> loadMetrics({
    bool includeProfits = false,
  }) {
    return _tradeService
        .getTradesByStatus(TradeStatus.active)
        .map((trades) {
      double lossAmount = 0;
      double riskUsed = 0;

      int totalTrades = trades.length;
      int tradesInProfit = 0;
      int tradesInLoss = 0;

      for (final trade in trades) {
        // Profit / Loss Count
        if (trade.pnlValue > 0) {
          tradesInProfit++;
        } else if (trade.pnlValue < 0) {
          tradesInLoss++;
        }

        // Loss / Net P&L
        if (includeProfits) {
          lossAmount += trade.pnlValue;
        } else if (trade.pnlValue < 0) {
          lossAmount += trade.pnlValue.abs();
        }

        // Current Risk
        riskUsed += _calculateCurrentRisk(trade);
      }

      final bool isNetProfit =
          includeProfits && lossAmount > 0;

      if (includeProfits) {
        lossAmount = lossAmount.abs();
      }

      final double maxRisk =
          totalCapital * maxPortfolioRiskPercent;

      final double remainingRisk =
          (maxRisk - riskUsed).clamp(0.0, maxRisk);

      return DashboardMetrics(
        lossAmount: lossAmount,
        remainingRisk: remainingRisk,
        totalTrades: totalTrades,
        tradesInProfit: tradesInProfit,
        tradesInLoss: tradesInLoss,
        isNetProfit: isNetProfit,
      );
    });
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