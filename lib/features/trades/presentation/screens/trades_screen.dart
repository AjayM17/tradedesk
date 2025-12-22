import 'package:flutter/material.dart';

import '../../data/services/trade_firestore_service.dart';
import '../models/trade_ui_model.dart';
import '../widgets/trade_card.dart';

class TradesScreen extends StatelessWidget {
  const TradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trades'),
      ),
      body: const TradesBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Trade screen (v2)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TradesBody extends StatelessWidget {
  const TradesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final TradeFirestoreService service = TradeFirestoreService();

    return StreamBuilder<List<TradeUiModel>>(
      stream: service.getTrades(),
      builder: (context, snapshot) {
        // 1️⃣ Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 2️⃣ Error state
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong while loading trades'),
          );
        }

        // 3️⃣ Data state
        final List<TradeUiModel> trades = snapshot.data ?? [];

        if (trades.isEmpty) {
          return const TradesEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            return TradeCard(
              trade: trades[index],
            );
          },
        );
      },
    );
  }
}

class TradesEmptyState extends StatelessWidget {
  const TradesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.show_chart,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No trades yet',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first trade',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
