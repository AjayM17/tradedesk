import 'package:flutter/material.dart';
import 'package:trade_desk/features/dashboard/presentation/data/models/dashboard_metrics.dart';
import 'package:trade_desk/features/dashboard/presentation/data/services/dashboard_service.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_page_layout.dart';

import '../../../trades/data/services/trade_firestore_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardService = DashboardService(TradeFirestoreService());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        toolbarHeight: 48,
        titleSpacing: 16,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: AppPageLayout(
        child: FutureBuilder<DashboardMetrics>(
          future: dashboardService.loadMetrics(),
          builder: (context, snapshot) {
            // ───────── LOADING ─────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ───────── EMPTY / ERROR ─────────
            if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─────────────────────
                  // Summary Amounts
                  // ─────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.trending_down,
                          title: 'Risk Amount',
                          value: '₹${data.lossAmount.toStringAsFixed(0)}',
                          valueColor: AppTheme.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.shield_outlined,
                          title: 'Remaining Risk',
                          value: '₹${data.remainingRisk.toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─────────────────────
                  // Trade Counts
                  // ─────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Trades',
                          value: data.totalTrades.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'In Profit',
                          value: data.tradesInProfit.toString(),
                          valueColor: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'In Loss',
                          value: data.tradesInLoss.toString(),
                          valueColor: AppTheme.danger,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  FutureBuilder<List<TradeUiModel>>(
                    future: dashboardService.loadLast100Trades(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final trades = snapshot.data!;
                      final winRate = dashboardService.calculateWinRate(trades);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Section Title
                          const Text(
                            'Last 100 Closed Trades',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// Win Rate Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Win Rate',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${winRate.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: winRate >= 50
                                        ? AppTheme.success
                                        : AppTheme.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Trade List
                          ...trades.take(10).map((trade) {
                            final isProfit = trade.pnlValue >= 0;

                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(trade.name),
                              trailing: Text(
                                '₹${trade.pnlValue.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isProfit
                                      ? AppTheme.success
                                      : AppTheme.danger,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
