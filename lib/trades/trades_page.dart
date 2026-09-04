import 'package:flutter/material.dart';
import 'package:trade_desk/trades/add_trade/add_trade_page.dart';

import 'models/trade_model.dart';
import 'services/trade_rules_service.dart';
import 'services/trade_service.dart';
import 'widgets/trade_card.dart';

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends State<TradesPage> {
  final TradeService _tradeService = TradeService();
  final TradeRulesService _tradeRulesService =
      TradeRulesService();

  List<TradeModel> _trades = [];

  bool _isLoading = true;
  bool _canAddTrade = false;
  String? _addTradeBlockReason;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  // =========================================================
  // Page lifecycle
  // =========================================================

  Future<void> _loadTrades() async {
    final trades = await _tradeService.getTrades();

    final canAddTrade =
        await _tradeRulesService.canStartNewTrade(
      trades,
    );

    String? blockReason;

    if (!canAddTrade) {
      blockReason =
          await _tradeRulesService.getNewTradeBlockReason(
        trades,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _trades = trades;
      _canAddTrade = canAddTrade;
      _addTradeBlockReason = blockReason;
      _isLoading = false;
    });
  }

  // =========================================================
  // Add Trade
  // =========================================================

Future<void> addTrade() async {
  if (!_canAddTrade) {
    await showAddTradeBlockReason();
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const AddTradePage(),
    ),
  );

  if (!mounted) return;

  await _loadTrades();
}

  Future<void> showAddTradeBlockReason() async {
    final reason = _addTradeBlockReason;

    if (reason == null || reason.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reason),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =========================================================
  // Trade Actions
  // =========================================================

  Future<void> openTradeActions(
    TradeModel trade,
  ) async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  trade.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                ),
                title: const Text('Edit Trade'),
                onTap: () {
                  Navigator.of(context).pop();
                  editTrade(trade);
                },
              ),

           if (trade.status == TradeStatus.active)
  ListTile(
    leading: const Icon(
      Icons.check_circle_outline,
    ),
    title: const Text('Complete Trade'),
    onTap: () async {
      Navigator.of(context).pop();

      final tradeDate = DateTime.parse(trade.tradeDate);
      final today = DateTime.now();

      final selectedDate = await showDatePicker(
        context: this.context,
        initialDate: today,
        firstDate: tradeDate,
        lastDate: today,
      );

      if (selectedDate == null) {
        return;
      }

      final completedAt =
          '${selectedDate.year.toString().padLeft(4, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}';

      await completeTrade(
        trade,
        completedAt,
      );
    },
  ),

              if (trade.status !=
                  TradeStatus.active)
                ListTile(
                  leading: const Icon(
                    Icons.play_circle_outline,
                  ),
                  title: const Text('Make Active'),
                  onTap: () {
                    Navigator.of(context).pop();
                    makeActive(trade);
                  },
                ),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                ),
                title: const Text('Delete Trade'),
                textColor: Theme.of(context)
                    .colorScheme
                    .error,
                iconColor: Theme.of(context)
                    .colorScheme
                    .error,
                onTap: () {
                  Navigator.of(context).pop();
                  deleteTrade(trade);
                },
              ),

              const SizedBox(height: 8),

              ListTile(
                title: const Center(
                  child: Text('Cancel'),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // Make Active
  // =========================================================

  Future<void> makeActive(
    TradeModel trade,
  ) async {
    final existingTrades =
        await _tradeService.getTrades();

    final ruleCheck =
        await _tradeRulesService.checkReactivation(
      trade,
      existingTrades,
    );

    if (!ruleCheck.passed) {
      await _showReactivationRuleFailure(
        ruleCheck.results,
      );

      return;
    }

    final activeTrade = trade.copyWith(
      status: TradeStatus.active,
    );

    await _tradeService.updateTrade(
      activeTrade,
    );

    await _loadTrades();
  }

  // =========================================================
  // Reactivation Rule Failure
  // =========================================================

  Future<void> _showReactivationRuleFailure(
    List<TradeRuleResult> results,
  ) async {
    final failedRules = results
        .where(
          (result) => !result.passed,
        )
        .toList();

    final message = failedRules
        .map(
          (rule) =>
              '${rule.label}: ${rule.message}',
        )
        .join('\n\n');

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Trade Cannot Be Activated',
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Review'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // Complete Trade
  // =========================================================

  Future<void> completeTrade(
    TradeModel trade,
    String completedAt,
  ) async {
    final completedTrade = trade.copyWith(
      status: TradeStatus.completed,
      completedAt: completedAt,
    );

    await _tradeService.updateTrade(
      completedTrade,
    );

    await _loadTrades();
  }

  // =========================================================
  // Delete Trade
  // =========================================================

  Future<void> deleteTrade(
    TradeModel trade,
  ) async {
    if (!mounted) {
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Trade?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '${trade.symbol}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _tradeService.deleteTrade(
      trade.id,
    );

    await _loadTrades();
  }

  // =========================================================
  // Edit Trade
  // =========================================================

Future<void> editTrade(
  TradeModel trade,
) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AddTradePage(
        tradeToEdit: trade,
      ),
    ),
  );

  await _loadTrades();
}

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trades'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trades'),
        actions: [
          FilledButton(
            onPressed:
                _canAddTrade ? addTrade : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Add Trade',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (!_canAddTrade)
            IconButton(
              tooltip:
                  "Why can't I add a trade?",
              onPressed:
                  showAddTradeBlockReason,
              icon: const Icon(
                Icons.info_outline,
              ),
            ),

          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: _trades.isEmpty
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  24,
                ),
                child: _buildEmptyState(),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  24,
                ),
                itemCount: _trades.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (
                  context,
                  index,
                ) {
                  final trade = _trades[index];

                  return TradeCard(
                    trade: trade,
                    onTap: () {
                      openTradeActions(trade);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE0E0E4),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'No trades yet.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF141A2E),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add your first trade to start tracking.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF74798A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}