import 'package:flutter/material.dart';
// import 'package:trade_desk/features/dashboard/presentation/data/models/dashboard_metrics.dart';
import 'package:trade_desk/features/dashboard/presentation/data/services/dashboard_service.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';

import '../../../dashboard/presentation/widgets/summary_card.dart';
import '../../data/services/trade_firestore_service.dart';
import '../models/trade_ui_model.dart';
import '../widgets/trade_card.dart';

enum TradeFilter { active, profit, loss, completed }

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  bool _includeProfits = false;
  TradeFilter _selectedFilter = TradeFilter.active;
  final ScrollController _filterController = ScrollController();

  String _getLabel(TradeFilter filter) {
    switch (filter) {
      case TradeFilter.active:
        return 'Active';
      case TradeFilter.profit:
        return 'Profit';
      case TradeFilter.loss:
        return 'Loss';
      // case TradeFilter.partial:
      //   return 'Partial';
      case TradeFilter.completed:
        return 'Completed';
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Include Profit in Risk'),
                Switch(
                  value: _includeProfits,
                  onChanged: (val) {
                    setState(() {
                      _includeProfits = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: TradesBody(
        includeProfits: _includeProfits,
        filter: _selectedFilter,
        controller: _filterController,
        getLabel: _getLabel,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTradeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TradesBody extends StatelessWidget {
  final bool includeProfits;
  final TradeFilter filter;
  final Function(TradeFilter) onFilterChanged;
  final String Function(TradeFilter) getLabel;
  final ScrollController controller;

  const TradesBody({
    super.key,
    required this.includeProfits,
    required this.filter,
    required this.controller,
    required this.onFilterChanged,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tradeService = TradeFirestoreService();
    final dashboardService = DashboardService(tradeService);

    return StreamBuilder<List<TradeUiModel>>(
      stream: tradeService.getAllTrades(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('========== ACTIVE ERROR ==========');
        debugPrint(snapshot.error.toString());

if (snapshot.stackTrace != null) {
  debugPrint(snapshot.stackTrace.toString());
}

          return const Center(
            child: Text('Something went wrong while loading active trades'),
          );
        }

final allTrades = snapshot.data ?? [];

final activeTrades = allTrades
    .where((t) => t.status == TradeStatus.active)
    .toList();

final completedTrades = allTrades
    .where((t) => t.status == TradeStatus.closed)
    .toList();

         

            final counts = {
              TradeFilter.active: activeTrades.length,
              TradeFilter.profit: activeTrades
                  .where((t) => t.isInProfit)
                  .length,
              TradeFilter.loss: activeTrades.where((t) => t.isInLoss).length,
              // TradeFilter.partial: activeTrades
              //     .where((t) => t.partialBooked)
              //     .length,
              TradeFilter.completed: completedTrades.length,
            };

            final filteredTrades = switch (filter) {
              TradeFilter.active => activeTrades,

              TradeFilter.profit =>
                activeTrades.where((t) => t.isInProfit).toList(),

              TradeFilter.loss =>
                activeTrades.where((t) => t.isInLoss).toList(),

              // TradeFilter.partial =>
              //   activeTrades.where((t) => t.partialBooked).toList(),

              TradeFilter.completed => completedTrades,
            };

      final data = dashboardService.calculateMetrics(
  filteredTrades,
  includeProfits: includeProfits,
);

            filteredTrades.sort((a, b) => b.pnlValue.compareTo(a.pnlValue));

            if (filteredTrades.isEmpty) {
              String message;

              switch (filter) {
                case TradeFilter.active:
                  message = 'No active trades';
                  break;
                case TradeFilter.profit:
                  message = 'No profitable trades';
                  break;
                case TradeFilter.loss:
                  message = 'No losing trades';
                  break;
                // case TradeFilter.partial:
                //   message = 'No partial booked trades';
                  // break;
                case TradeFilter.completed:
                  message = 'No completed trades';
                  break;
              }

              return Column(
                children: [
                  _buildFilterChips(counts),
                  Expanded(child: Center(child: Text(message))),
                ],
              );
            }

            return Column(
              children: [
                _buildFilterChips(counts),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.trending_down,
                          title: 'Risk Amount',
                          value: '₹${data.lossAmount.toStringAsFixed(0)}',
                          valueColor: includeProfits
                              ? (data.isNetProfit ? Colors.green : Colors.red)
                              : Colors.red,
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
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTrades.length,
                    itemBuilder: (context, index) {
                      return TradeCard(trade: filteredTrades[index]);
                    },
                  ),
                ),
              ],
            );
        
      },
    );
  }

  Widget _buildFilterChips(Map<TradeFilter, int> counts) {
    return SingleChildScrollView(
      key: const PageStorageKey('trade_filters'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: TradeFilter.values.map((tradeFilter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              label: Text(
                '${getLabel(tradeFilter)} (${counts[tradeFilter] ?? 0})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: filter == tradeFilter,
              onSelected: (_) => onFilterChanged(tradeFilter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
