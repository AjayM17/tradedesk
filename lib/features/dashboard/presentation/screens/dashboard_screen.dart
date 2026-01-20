import 'package:flutter/material.dart';
import 'package:trade_desk/features/dashboard/presentation/data/models/dashboard_metrics.dart';
import 'package:trade_desk/features/dashboard/presentation/data/services/dashboard_service.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_page_layout.dart';

import '../../../trades/data/services/trade_firestore_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardService =
        DashboardService(TradeFirestoreService());

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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ───────── EMPTY / ERROR ─────────
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No data available'),
              );
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
                          title: 'Loss Amount',
                          value: '₹${data.lossAmount.toStringAsFixed(0)}',
                          valueColor: AppTheme.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.shield_outlined,
                          title: 'Remaining Risk',
                          value:
                              '₹${data.remainingRisk.toStringAsFixed(0)}',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
