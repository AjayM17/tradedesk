

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



import 'services/dashboard_analytics_service.dart';



class DashboardPage extends StatefulWidget {

  const DashboardPage({super.key});



  @override

  State<DashboardPage> createState() => _DashboardPageState();

}



class _DashboardPageState extends State<DashboardPage> {

  final DashboardAnalyticsService _analyticsService =

      DashboardAnalyticsService();



  late Future<DashboardAnalytics> _analyticsFuture;

  static const String _pinnedMetricsStorageKey = 'dashboard_pinned_metric_ids';
  final Set<String> _pinnedMetricIds = <String>{};



  @override

  void initState() {
    super.initState();
    _analyticsFuture = _analyticsService.loadAnalytics();
    _loadPinnedMetrics();
  }



  Future<void> _loadPinnedMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_pinnedMetricsStorageKey) ?? <String>[];

    if (!mounted) return;

    setState(() {
      _pinnedMetricIds
        ..clear()
        ..addAll(savedIds);
    });
  }

  Future<void> _toggleMetricPin(_Metric metric) async {
    final wasPinned = _pinnedMetricIds.contains(metric.id);

    setState(() {
      if (wasPinned) {
        _pinnedMetricIds.remove(metric.id);
      } else {
        _pinnedMetricIds.add(metric.id);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _pinnedMetricsStorageKey,
      _pinnedMetricIds.toList(),
    );
  }

  List<_Metric> _unpinned(List<_Metric> metrics) {
    return metrics
        .where((metric) => !_pinnedMetricIds.contains(metric.id))
        .toList();
  }

  Future<void> _refresh() async {

    final future = _analyticsService.loadAnalytics();



    setState(() {

      _analyticsFuture = future;

    });



    await future;

  }



  String _money(double value) {

    final sign = value < 0 ? '-₹' : '₹';

    final formatted = value.abs().toStringAsFixed(2);

    return '$sign${_groupDigits(formatted)}';

  }



  String _groupDigits(String value) {

    final parts = value.split('.');

    final integerPart = parts[0];



    if (integerPart.length <= 3) return value;



    final lastThree = integerPart.substring(integerPart.length - 3);

    var remaining = integerPart.substring(0, integerPart.length - 3);

    final groups = <String>[];



    while (remaining.length > 2) {

      groups.insert(0, remaining.substring(remaining.length - 2));

      remaining = remaining.substring(0, remaining.length - 2);

    }



    if (remaining.isNotEmpty) groups.insert(0, remaining);



    return '${groups.join(',')},$lastThree.${parts[1]}';

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Dashboard'),

        actions: [

          IconButton(

            tooltip: 'Refresh analytics',

            onPressed: _refresh,

            icon: const Icon(Icons.refresh),

          ),

        ],

      ),

      body: FutureBuilder<DashboardAnalytics>(

        future: _analyticsFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting &&

              !snapshot.hasData) {

            return const Center(child: CircularProgressIndicator());

          }



          if (snapshot.hasError) {

            return Center(

              child: Padding(

                padding: const EdgeInsets.all(24),

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Icon(Icons.error_outline, size: 40),

                    const SizedBox(height: 12),

                    const Text(

                      'Unable to load dashboard analytics.',

                    ),

                    const SizedBox(height: 12),

                    FilledButton(

                      onPressed: _refresh,

                      child: const Text('Try again'),

                    ),

                  ],

                ),

              ),

            );

          }



          final data = snapshot.data!;

          final performanceMetrics = [


                  _Metric(
                    'realizedPnl',
                    'Realized P&L',

                    _money(data.realizedPnl),

                    Icons.account_balance_wallet_outlined,

                    valueColor: data.realizedPnl > 0

                        ? Colors.green.shade700

                        : data.realizedPnl < 0

                            ? Colors.red.shade700

                            : null,

                  ),

                  _Metric(
                    'winRate',
                    'Win Rate',

                    '${data.winRate.toStringAsFixed(1)}%',

                    Icons.emoji_events_outlined,

                  ),

                  _Metric(
                    'totalTrades',
                    'Total Trades',

                    '${data.totalTrades}',

                    Icons.swap_horiz,

                  ),

                  _Metric(
                    'completedTrades',
                    'Completed Trades',

                    '${data.completedTrades}',

                    Icons.check_circle_outline,

                  ),

                  _Metric(
                    'winningTrades',
                    'Winning Trades',

                    '${data.winningTrades}',

                    Icons.trending_up,

                    valueColor: Colors.green.shade700,

                  ),

                  _Metric(
                    'losingTrades',
                    'Losing Trades',

                    '${data.losingTrades}',

                    Icons.trending_down,

                    valueColor: Colors.red.shade700,

                  ),

                  _Metric(
                    'breakEvenTrades',
                    'Break-even Trades',

                    '${data.breakEvenTrades}',

                    Icons.horizontal_rule,

                  ),

                  _Metric(
                    'averageProfit',
                    'Avg. Winning Trade',

                    _money(data.averageProfit),

                    Icons.arrow_upward,

                    valueColor: Colors.green.shade700,

                  ),

                  _Metric(
                    'averageLoss',
                    'Avg. Losing Trade',

                    _money(data.averageLoss),

                    Icons.arrow_downward,

                    valueColor: Colors.red.shade700,

                  ),

                
          ];

          final riskMetrics = [


                  _Metric(
                    'portfolioRiskLimit',
                    'Portfolio Risk Limit',

                    _money(data.maxPortfolioRisk),

                    Icons.shield_outlined,

                  ),

                  _Metric(
                    'currentOpenRisk',
                    'Current Open Risk',

                    _money(data.currentOpenRisk),

                    Icons.warning_amber_rounded,

                  ),

                  _Metric(
                    'riskRemaining',
                    'Risk Remaining',

                    _money(data.remainingPortfolioRisk),

                    Icons.shield_moon_outlined,

                  ),

                  _Metric(
                    'largestTradeRisk',
                    'Largest Trade Risk',

                    _money(data.maxSingleTradeRisk),

                    Icons.trending_down,

                  ),

                
          ];

          final capitalMetrics = [


                  _Metric(
                    'totalCapital',
                    'Total Capital',

                    _money(data.settings.totalInvestment),

                    Icons.account_balance,

                  ),

                  _Metric(
                    'deployedCapital',
                    'Deployed Capital',

                    _money(data.deployedCapital),

                    Icons.pie_chart_outline,

                  ),

                  _Metric(
                    'availableCapital',
                    'Available Capital',

                    _money(data.availableCapital),

                    Icons.savings_outlined,

                  ),

                  _Metric(
                    'maxCapitalPerStock',
                    'Max Capital / Stock',

                    _money(data.settings.maxInvestmentPerTrade),

                    Icons.business_center_outlined,

                  ),

                
          ];

          final allMetrics = <_Metric>[
            ...performanceMetrics,
            ...riskMetrics,
            ...capitalMetrics,
          ];
          final pinnedMetrics = allMetrics
              .where((metric) => _pinnedMetricIds.contains(metric.id))
              .toList();



          return RefreshIndicator(

            onRefresh: _refresh,

            child: ListView(

              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),

              children: [

                Text(

                  'Trading Overview',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        fontWeight: FontWeight.w700,

                      ),

                ),

                const SizedBox(height: 4),

                Text(

                  'Performance of trades stored in your account.',

                  style: Theme.of(context).textTheme.bodySmall,

                ),

                if (pinnedMetrics.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Pinned Cards'),
                  const SizedBox(height: 10),
                  _metricGrid(pinnedMetrics),
                ],



                // 1. Trading Performance

                const SizedBox(height: 20),

                _sectionTitle(context, 'Trading Performance'),

                const SizedBox(height: 10),

                _metricGrid(_unpinned(performanceMetrics)),



                // 2. Risk Overview

                const SizedBox(height: 24),

                _sectionTitle(context, 'Risk Overview'),

                const SizedBox(height: 10),

                _metricGrid(_unpinned(riskMetrics)),



                // 3. Capital Allocation

                const SizedBox(height: 24),

                _sectionTitle(context, 'Capital Allocation'),

                const SizedBox(height: 10),

                _metricGrid(_unpinned(capitalMetrics)),



                // 4. Completed Trades

                const SizedBox(height: 24),

                _sectionTitle(context, 'Completed Trades'),

                const SizedBox(height: 4),

                Text(

                  '${data.completedTradeDetails.length} completed positions',

                  style: Theme.of(context).textTheme.bodySmall,

                ),

                const SizedBox(height: 10),



                if (data.completedTradeDetails.isEmpty)

                  _emptyCompletedState()

                else

                  ...data.completedTradeDetails.map(

                    (item) => _completedTradeCard(context, item),

                  ),



                const SizedBox(height: 12),

                Text(

                  'P&L uses actual booking prices. Remaining quantity on '

                  'completed trades is assumed to have exited at the saved '

                  'stop-loss. Weighted average exit may differ from the '

                  'actual market fill. Brokerage, taxes and slippage are '

                  'not included.',

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(

                        color: Theme.of(context)

                            .colorScheme

                            .onSurfaceVariant,

                        height: 1.4,

                      ),

                ),

              ],

            ),

          );

        },

      ),

    );

  }



  Widget _sectionTitle(BuildContext context, String title) {

    return Text(

      title,

      style: Theme.of(context).textTheme.titleMedium?.copyWith(

            fontWeight: FontWeight.w700,

          ),

    );

  }



  Widget _metricGrid(List<_Metric> metrics) {

    return LayoutBuilder(

      builder: (context, constraints) {

        final columns = constraints.maxWidth >= 600 ? 3 : 2;

        final itemWidth =

            (constraints.maxWidth - (columns - 1) * 10) / columns;



        return Wrap(

          spacing: 10,

          runSpacing: 10,

          children: metrics

              .map(

                (metric) => SizedBox(

                  width: itemWidth,

                  child: _metricCard(context, metric),

                ),

              )

              .toList(),

        );

      },

    );

  }



  Widget _metricCard(BuildContext context, _Metric metric) {

    final theme = Theme.of(context);



    return Card(

      elevation: 0,

      margin: EdgeInsets.zero,

      color: theme.colorScheme.surfaceContainerHighest

          .withValues(alpha: 0.45),

      child: Padding(

        padding: const EdgeInsets.all(13),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(
              children: [
                Icon(
                  metric.icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const Spacer(),
                IconButton(
                  tooltip: _pinnedMetricIds.contains(metric.id)
                      ? 'Unpin card'
                      : 'Pin card to top',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _toggleMetricPin(metric),
                  icon: Icon(
                    _pinnedMetricIds.contains(metric.id)
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                    size: 18,
                    color: _pinnedMetricIds.contains(metric.id)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(

              metric.label,

              style: theme.textTheme.bodySmall,

            ),

            const SizedBox(height: 5),

            Text(

              metric.value,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: theme.textTheme.titleMedium?.copyWith(

                fontWeight: FontWeight.w700,

                color: metric.valueColor,

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _completedTradeCard(

    BuildContext context,

    CompletedTradeAnalytics item,

  ) {

    final theme = Theme.of(context);

    final trade = item.trade;

    final pnl = item.totalRealizedPnl;



    final pnlColor = pnl > 0

        ? Colors.green.shade700

        : pnl < 0

            ? Colors.red.shade700

            : theme.colorScheme.onSurface;



    final totalExitedQuantity =

        item.bookedQuantity + item.assumedExitQuantity;



    return Card(

      margin: const EdgeInsets.only(bottom: 10),

      elevation: 0,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(14),

        side: BorderSide(

          color: theme.colorScheme.outlineVariant,

        ),

      ),

      child: Padding(

        padding: const EdgeInsets.all(14),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Expanded(

                  child: Text(

                    trade.symbol,

                    style: theme.textTheme.titleMedium?.copyWith(

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                ),

                Text(

                  _money(pnl),

                  style: theme.textTheme.titleMedium?.copyWith(

                    color: pnlColor,

                    fontWeight: FontWeight.w700,

                  ),

                ),

              ],

            ),

            const SizedBox(height: 4),

            Text(

              pnl > 0

                  ? 'Profit'

                  : pnl < 0

                      ? 'Loss'

                      : 'Break-even',

              style: theme.textTheme.bodySmall?.copyWith(

                color: pnlColor,

              ),

            ),

            const SizedBox(height: 12),

            _detailRow('Entry Price', _money(trade.entryPrice)),

            _detailRow(

              'Weighted Avg. Exit',

              _money(item.weightedAverageExitPrice),

            ),

            _detailRow(

              'Total Exited Quantity',

              '$totalExitedQuantity',

            ),

            _detailRow(

              'Booked Quantity',

              '${item.bookedQuantity}',

            ),

            if (item.assumedExitQuantity > 0)

              _detailRow(

                'Assumed SL Exit Quantity',

                '${item.assumedExitQuantity}',

              ),

            _detailRow(

              'Completion Date',

              trade.completedAt ?? 'Not recorded',

            ),

          ],

        ),

      ),

    );

  }



  Widget _detailRow(String label, String value) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Expanded(

            child: Text(

              label,

              style: const TextStyle(color: Colors.grey),

            ),

          ),

          const SizedBox(width: 12),

          Flexible(

            child: Text(

              value,

              textAlign: TextAlign.end,

              style: const TextStyle(

                fontWeight: FontWeight.w600,

              ),

            ),

          ),

        ],

      ),

    );

  }



  Widget _emptyCompletedState() {

    return const Card(

      elevation: 0,

      child: Padding(

        padding: EdgeInsets.all(24),

        child: Center(

          child: Column(

            children: [

              Icon(Icons.check_circle_outline, size: 36),

              SizedBox(height: 8),

              Text('No completed trades yet'),

              SizedBox(height: 4),

              Text('Completed positions will appear here.'),

            ],

          ),

        ),

      ),

    );

  }

}



class _Metric {
  final String id;
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _Metric(
    this.id,
    this.label,
    this.value,
    this.icon, {
    this.valueColor,
  });
}
