import 'package:flutter/material.dart';
import 'package:trade_desk/features/dashboard/presentation/data/models/dashboard_metrics.dart';
import 'package:trade_desk/features/dashboard/presentation/data/services/dashboard_service.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';

import '../../../dashboard/presentation/widgets/summary_card.dart';
import '../../data/services/trade_firestore_service.dart';
import '../models/trade_ui_model.dart';
import '../widgets/trade_card.dart';

enum TradeFilter {
  all,
  profit,
  loss,
  partial,
}

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  bool _includeProfits = false;
  TradeFilter _selectedFilter = TradeFilter.all;

  String _getLabel(TradeFilter filter) {
    switch (filter) {
      case TradeFilter.all:
        return 'All';
      case TradeFilter.profit:
        return 'Profit';
      case TradeFilter.loss:
        return 'Loss';
      case TradeFilter.partial:
        return 'Partial';
    }
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
            MaterialPageRoute(
              builder: (_) => const CreateTradeScreen(),
            ),
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

  const TradesBody({
    super.key,
    required this.includeProfits,
    required this.filter,
    required this.onFilterChanged,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tradeService = TradeFirestoreService();
    final dashboardService = DashboardService(tradeService);

    return FutureBuilder<DashboardMetrics>(
      future: dashboardService.loadMetrics(
        includeProfits: includeProfits,
      ),
      builder: (context, metricsSnapshot) {
        if (metricsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!metricsSnapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = metricsSnapshot.data!;

        return StreamBuilder<List<TradeUiModel>>(
          stream: tradeService.getTradesByStatus(TradeStatus.active),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong while loading trades'),
              );
            }

            final trades = snapshot.data ?? [];

            final counts = {
              TradeFilter.all: trades.length,
              TradeFilter.profit:
                  trades.where((t) => t.isInProfit).length,
              TradeFilter.loss:
                  trades.where((t) => t.isInLoss).length,
              TradeFilter.partial:
                  trades.where((t) => t.partialBooked).length,
            };

            final filteredTrades = trades.where((trade) {
              switch (filter) {
                case TradeFilter.profit:
                  return trade.isInProfit;
                case TradeFilter.loss:
                  return trade.isInLoss;
                case TradeFilter.partial:
                  return trade.partialBooked;
                case TradeFilter.all:
                default:
                  return true;
              }
            }).toList();

            filteredTrades.sort(
              (a, b) => b.pnlValue.compareTo(a.pnlValue),
            );

            if (filteredTrades.isEmpty) {
              String message;

              switch (filter) {
                case TradeFilter.profit:
                  message = 'No profitable trades';
                  break;
                case TradeFilter.loss:
                  message = 'No losing trades';
                  break;
                case TradeFilter.partial:
                  message = 'No partial booked trades';
                  break;
                case TradeFilter.all:
                default:
                  message = 'No active trades';
              }

              return Column(
                children: [
                  _buildFilterChips(counts),
                  Expanded(
                    child: Center(
                      child: Text(message),
                    ),
                  ),
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
                          value:
                              '₹${data.lossAmount.toStringAsFixed(0)}',
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
                          value:
                              '₹${data.remainingRisk.toStringAsFixed(0)}',
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
                      return TradeCard(
                        trade: filteredTrades[index],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

Widget _buildFilterChips(Map<TradeFilter, int> counts) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: TradeFilter.values.map((tradeFilter) {
        return ChoiceChip(
          showCheckmark: false,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          label: Text(
            '${getLabel(tradeFilter)} (${counts[tradeFilter] ?? 0})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: filter == tradeFilter,
          onSelected: (_) => onFilterChanged(tradeFilter),
        );
      }).toList(),
    ),
  );
}
}