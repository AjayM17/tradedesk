
import 'dart:math' as math;

import 'package:trade_desk/settings/models/settings_model.dart';
import 'package:trade_desk/settings/settings_service.dart';
import 'package:trade_desk/trades/models/trade_booking_model.dart';
import 'package:trade_desk/trades/models/trade_model.dart';
import 'package:trade_desk/trades/services/trade_service.dart';

class ActiveTradeAnalytics {
  final TradeModel trade;
  final int remainingQuantity;
  final double realizedPnl;
  final double openRisk;
  final double deployedCapital;

  const ActiveTradeAnalytics({
    required this.trade,
    required this.remainingQuantity,
    required this.realizedPnl,
    required this.openRisk,
    required this.deployedCapital,
  });
}

class CompletedTradeAnalytics {
  final TradeModel trade;
  final int bookedQuantity;
  final int assumedExitQuantity;
  final double totalRealizedPnl;
  final double weightedAverageExitPrice;

  const CompletedTradeAnalytics({
    required this.trade,
    required this.bookedQuantity,
    required this.assumedExitQuantity,
    required this.totalRealizedPnl,
    required this.weightedAverageExitPrice,
  });
}

class DashboardAnalytics {
  final SettingsModel settings;
  final int totalTrades;
  final int activeTrades;
  final int completedTrades;
  final int winningTrades;
  final int losingTrades;
  final int breakEvenTrades;
  final double realizedPnl;
  final double averageProfit;
  final double averageLoss;
  final double winRate;
  final double currentOpenRisk;
  final double remainingPortfolioRisk;
  final double deployedCapital;
  final double availableCapital;
  final double maxSingleTradeRisk;
  final List<ActiveTradeAnalytics> activeTradeDetails;
  final List<CompletedTradeAnalytics> completedTradeDetails;

  const DashboardAnalytics({
    required this.settings,
    required this.totalTrades,
    required this.activeTrades,
    required this.completedTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.breakEvenTrades,
    required this.realizedPnl,
    required this.averageProfit,
    required this.averageLoss,
    required this.winRate,
    required this.currentOpenRisk,
    required this.remainingPortfolioRisk,
    required this.deployedCapital,
    required this.availableCapital,
    required this.maxSingleTradeRisk,
    required this.activeTradeDetails,
    required this.completedTradeDetails,
  });

  double get maxPortfolioRisk => settings.maxPortfolioRisk;
}

class DashboardAnalyticsService {
  final TradeService _tradeService;
  final SettingsService _settingsService;

  DashboardAnalyticsService({
    TradeService? tradeService,
    SettingsService? settingsService,
  })  : _tradeService = tradeService ?? TradeService(),
        _settingsService = settingsService ?? SettingsService();

  Future<DashboardAnalytics> loadAnalytics() async {
    final results = await Future.wait<Object>([
      _tradeService.getTrades(),
      _settingsService.getSettings(),
    ]);

    final trades = results[0] as List<TradeModel>;
    final settings = results[1] as SettingsModel;

    final bookingResults = await Future.wait(
      trades.map((trade) => _tradeService.getBookings(trade.id)),
    );

    var activeCount = 0;
    var completedCount = 0;
    var winningCount = 0;
    var losingCount = 0;
    var breakEvenCount = 0;

    var totalRealizedPnl = 0.0;
    var totalWinningPnl = 0.0;
    var totalLosingPnl = 0.0;
    var openRisk = 0.0;
    var deployedCapital = 0.0;
    var maxSingleTradeRisk = 0.0;

    final activeDetails = <ActiveTradeAnalytics>[];
    final completedDetails = <CompletedTradeAnalytics>[];

    for (var i = 0; i < trades.length; i++) {
      final trade = trades[i];
      final bookings = bookingResults[i];

      final bookedQuantity = bookings.fold<int>(
        0,
        (sum, booking) => sum + booking.quantity,
      );

      final remainingQuantity = math
          .max(0, trade.quantity - bookedQuantity)
          .toInt();

      final bookingPnl = _calculateBookingPnl(trade, bookings);

      if (trade.status == TradeStatus.completed) {
        // Assumption: any remaining shares exited at the saved stop loss.
        final assumedExitQuantity = remainingQuantity;
        final assumedExitPnl =
            (trade.stopLoss - trade.entryPrice) * assumedExitQuantity;

        final tradeRealizedPnl = bookingPnl + assumedExitPnl;

        completedCount++;
        totalRealizedPnl += tradeRealizedPnl;

        if (tradeRealizedPnl > 0.005) {
          winningCount++;
          totalWinningPnl += tradeRealizedPnl;
        } else if (tradeRealizedPnl < -0.005) {
          losingCount++;
          totalLosingPnl += tradeRealizedPnl;
        } else {
          breakEvenCount++;
        }

        final totalExitValue = bookings.fold<double>(
          0.0,
          (sum, booking) =>
              sum + booking.price * booking.quantity,
        ) + trade.stopLoss * assumedExitQuantity;

        final totalExitedQuantity =
            bookedQuantity + assumedExitQuantity;

        final averageExitPrice = totalExitedQuantity > 0
            ? totalExitValue / totalExitedQuantity
            : 0.0;

        completedDetails.add(
          CompletedTradeAnalytics(
            trade: trade,
            bookedQuantity: bookedQuantity,
            assumedExitQuantity: assumedExitQuantity,
            totalRealizedPnl: tradeRealizedPnl,
            weightedAverageExitPrice: averageExitPrice,
          ),
        );
      } else {
        // Booked profit/loss counts as realized even if the trade is active.
        totalRealizedPnl += bookingPnl;
      }

      if (trade.status != TradeStatus.active) {
        continue;
      }

      activeCount++;

      final riskPerShare = math
          .max(0.0, trade.entryPrice - trade.stopLoss)
          .toDouble();

      final tradeOpenRisk = riskPerShare * remainingQuantity;
      final tradeDeployedCapital =
          trade.entryPrice * remainingQuantity;

      openRisk += tradeOpenRisk;
      deployedCapital += tradeDeployedCapital;

      maxSingleTradeRisk = math
          .max(maxSingleTradeRisk, tradeOpenRisk)
          .toDouble();

      activeDetails.add(
        ActiveTradeAnalytics(
          trade: trade,
          remainingQuantity: remainingQuantity,
          realizedPnl: bookingPnl,
          openRisk: tradeOpenRisk,
          deployedCapital: tradeDeployedCapital,
        ),
      );
    }

    final availableCapital = math
        .max(0.0, settings.totalInvestment - deployedCapital)
        .toDouble();

    final remainingPortfolioRisk = math
        .max(0.0, settings.maxPortfolioRisk - openRisk)
        .toDouble();

    // Break-even trades are included in the denominator.
    final winRate = completedCount == 0
        ? 0.0
        : winningCount / completedCount * 100;

    completedDetails.sort((a, b) {
      final dateComparison = (b.trade.completedAt ?? '')
          .compareTo(a.trade.completedAt ?? '');

      if (dateComparison != 0) return dateComparison;

      return b.trade.tradeDate.compareTo(a.trade.tradeDate);
    });

    return DashboardAnalytics(
      settings: settings,
      totalTrades: trades.length,
      activeTrades: activeCount,
      completedTrades: completedCount,
      winningTrades: winningCount,
      losingTrades: losingCount,
      breakEvenTrades: breakEvenCount,
      realizedPnl: totalRealizedPnl,
      averageProfit: winningCount == 0
          ? 0.0
          : totalWinningPnl / winningCount,
      averageLoss: losingCount == 0
          ? 0.0
          : totalLosingPnl / losingCount,
      winRate: winRate,
      currentOpenRisk: openRisk,
      remainingPortfolioRisk: remainingPortfolioRisk,
      deployedCapital: deployedCapital,
      availableCapital: availableCapital,
      maxSingleTradeRisk: maxSingleTradeRisk,
      activeTradeDetails: activeDetails,
      completedTradeDetails: completedDetails,
    );
  }

  double _calculateBookingPnl(
    TradeModel trade,
    List<TradeBookingModel> bookings,
  ) {
    return bookings.fold<double>(
      0.0,
      (sum, booking) =>
          sum + (booking.price - trade.entryPrice) * booking.quantity,
    );
  }
}
