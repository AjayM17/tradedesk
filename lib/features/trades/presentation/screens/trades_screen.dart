import 'package:flutter/material.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';

import '../../data/services/trade_firestore_service.dart';
import '../models/trade_ui_model.dart';
import '../widgets/trade_card.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  TradeStatus _selectedStatus = TradeStatus.active;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedStatus == TradeStatus.active
              ? 'Active Trades'
              : 'Completed Trades',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<TradeStatus>(
              segments: const [
                ButtonSegment(
                  value: TradeStatus.active,
                  label: Text('Active'),
                ),
                ButtonSegment(
                  value: TradeStatus.closed,
                  label: Text('Completed'),
                ),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedStatus = value.first;
                });
              },
            ),
          ),
        ),
      ),
      body: TradesBody(status: _selectedStatus),
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
  final TradeStatus status;

  const TradesBody({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final TradeFirestoreService service = TradeFirestoreService();

    return StreamBuilder<List<TradeUiModel>>(
      stream: service.getTradesByStatus(status),
      builder: (context, snapshot) {
        // 🔄 Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong while loading trades'),
          );
        }

        final List<TradeUiModel> trades = snapshot.data ?? [];

        // 📭 Empty
        if (trades.isEmpty) {
          return TradesEmptyState(status: status);
        }

        // 📋 List
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            return TradeCard(trade: trades[index]);
          },
        );
      },
    );
  }
}

class TradesEmptyState extends StatelessWidget {
  final TradeStatus status;

  const TradesEmptyState({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            status == TradeStatus.active
                ? 'No active trades'
                : 'No completed trades',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            status == TradeStatus.active
                ? 'Tap + to add your first trade'
                : 'Completed trades will appear here',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}