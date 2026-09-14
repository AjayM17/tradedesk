import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';

import 'package:trade_desk/trades/add_trade/add_trade_page.dart';
import 'package:trade_desk/trades/details/trade_details_page.dart';
import 'package:trade_desk/trades/models/trade_booking_model.dart';

import 'models/trade_model.dart';
import 'services/trade_rules_service.dart';
import 'services/trade_service.dart';
import 'widgets/trade_card.dart';
import 'widgets/trade_slot_card.dart';

class PartialBookingResult {
  final int quantity;
  final double price;

  const PartialBookingResult({
    required this.quantity,
    required this.price,
  });
}

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesPageState();
}

// =============================================================
// TRADE LOAD SUMMARY
// =============================================================

class _TradeLoadSummary {
  final String tradeId;
  final int bookedQuantity;
  final double realizedProfit;
  final double averageExitPrice;
  final double overallRR;

  const _TradeLoadSummary({
    required this.tradeId,
    required this.bookedQuantity,
    required this.realizedProfit,
    required this.averageExitPrice,
    required this.overallRR,
  });
}

// =============================================================
// STATE
// =============================================================

class _TradesPageState extends State<TradesPage> {
  final TradeService _tradeService = TradeService();

  final TradeRulesService _tradeRulesService = TradeRulesService();

  List<TradeModel> _trades = [];

  // Total quantity already booked for each trade.
  //
  // Key   = trade.id
  // Value = total booked quantity
  final Map<String, int> _bookedQuantities = {};

  // Completed-trade realized P/L.
  final Map<String, double> _realizedProfits = {};

  // Completed-trade average exit prices.
  final Map<String, double> _averageExitPrices = {};

  // Completed-trade overall R.
  final Map<String, double> _overallRRs = {};

  bool _isLoading = true;

  bool _canAddTrade = false;

  String? _addTradeBlockReason;

  int _availableTradeSlots = 0;

  @override
  void initState() {
    super.initState();

    _loadTrades();
  }

  // ===========================================================
  // LOAD TRADES
  // ===========================================================

  Future<void> _loadTrades() async {
    final trades = await _tradeService.getTrades();

    final canAddTrade =
        await _tradeRulesService.canStartNewTrade(trades);

    String? blockReason;

    if (!canAddTrade) {
      blockReason =
          await _tradeRulesService.getNewTradeBlockReason(trades);
    }

    final availableTradeSlots =
        await _tradeRulesService.getAvailableTradeSlots(trades);

    // ---------------------------------------------------------
    // LOAD BOOKING AND COMPLETION SUMMARIES
    // ---------------------------------------------------------

    final bookedQuantities = <String, int>{};
    final realizedProfits = <String, double>{};
    final averageExitPrices = <String, double>{};
    final overallRRs = <String, double>{};

    final summaryResults = await Future.wait(
      trades.map((trade) async {
        final bookings =
            await _tradeService.getBookings(trade.id);

        final bookedQuantity = bookings.fold<int>(
          0,
          (total, booking) => total + booking.quantity,
        );

        double realizedProfit = 0;
        double totalExitValue = 0;

        // -----------------------------------------------------
        // PARTIAL BOOKING P/L
        // -----------------------------------------------------

        for (final booking in bookings) {
          realizedProfit +=
              (booking.price - trade.entryPrice) *
                  booking.quantity;

          totalExitValue +=
              booking.price * booking.quantity;
        }

        // -----------------------------------------------------
        // COMPLETED TRADE
        //
        // Any quantity not partially booked is considered
        // exited at the current stop-loss.
        // -----------------------------------------------------

        final unbookedQuantity =
            trade.quantity - bookedQuantity;

        if (trade.status == TradeStatus.completed &&
            unbookedQuantity > 0) {
          realizedProfit +=
              (trade.stopLoss - trade.entryPrice) *
                  unbookedQuantity;

          totalExitValue +=
              trade.stopLoss * unbookedQuantity;
        }

        // A completed trade is considered to have exited
        // the complete original quantity.
        final exitedQuantity =
            trade.status == TradeStatus.completed
                ? trade.quantity
                : bookedQuantity;

        final averageExitPrice = exitedQuantity > 0
            ? totalExitValue / exitedQuantity
            : 0.0;

        // -----------------------------------------------------
        // OVERALL R
        //
        // Overall R is calculated against the original risk:
        //
        // Entry - Initial SL
        // multiplied by original quantity.
        // -----------------------------------------------------

        final initialRiskPerShare =
            trade.entryPrice - trade.initialSL;

        final initialRisk = initialRiskPerShare > 0
            ? initialRiskPerShare * trade.quantity
            : 0.0;

        final overallRR = initialRisk > 0
            ? realizedProfit / initialRisk
            : 0.0;

        return _TradeLoadSummary(
          tradeId: trade.id,
          bookedQuantity: bookedQuantity,
          realizedProfit: realizedProfit,
          averageExitPrice: averageExitPrice,
          overallRR: overallRR,
        );
      }),
    );

    // ---------------------------------------------------------
    // STORE CALCULATED VALUES
    // ---------------------------------------------------------

    for (final summary in summaryResults) {
      bookedQuantities[summary.tradeId] =
          summary.bookedQuantity;

      realizedProfits[summary.tradeId] =
          summary.realizedProfit;

      averageExitPrices[summary.tradeId] =
          summary.averageExitPrice;

      overallRRs[summary.tradeId] =
          summary.overallRR;
    }

    // ---------------------------------------------------------
    // UPDATE STATE
    // ---------------------------------------------------------

    if (!mounted) {
      return;
    }

    setState(() {
      _trades = trades;

      _bookedQuantities
        ..clear()
        ..addAll(bookedQuantities);

      _realizedProfits
        ..clear()
        ..addAll(realizedProfits);

      _averageExitPrices
        ..clear()
        ..addAll(averageExitPrices);

      _overallRRs
        ..clear()
        ..addAll(overallRRs);

      _canAddTrade = canAddTrade;

      _addTradeBlockReason = blockReason;

      _availableTradeSlots = availableTradeSlots;

      _isLoading = false;
    });
  }

  // ===========================================================
  // QUANTITY HELPERS
  // ===========================================================

  int _getBookedQuantity(TradeModel trade) {
    return _bookedQuantities[trade.id] ?? 0;
  }

  int _getRemainingQuantity(TradeModel trade) {
    final bookedQuantity = _getBookedQuantity(trade);

    final remaining = trade.quantity - bookedQuantity;

    if (remaining <= 0) {
      return 0;
    }

    if (remaining > trade.quantity) {
      return trade.quantity;
    }

    return remaining;
  }

  // ===========================================================
  // KITE
  // ===========================================================

  Future<void> openKite() async {
    final apps = await InstalledApps.getInstalledApps();

    final kiteApps = apps.where(
      (app) => app.name.toLowerCase() == 'kite',
    );

    if (kiteApps.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kite app is not installed'),
        ),
      );

      return;
    }

    final kite = kiteApps.first;

    await InstalledApps.startApp(kite.packageName);
  }

  // ===========================================================
  // ADD TRADE
  // ===========================================================

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

    if (!mounted) {
      return;
    }

    await _loadTrades();
  }

  // ===========================================================
  // BLOCK REASON
  // ===========================================================

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

  // ===========================================================
  // TRADE ACTIONS
  // ===========================================================

  Future<void> openTradeActions(TradeModel trade) async {
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

              // EDIT
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Trade'),
                onTap: () {
                  Navigator.of(context).pop();

                  editTrade(trade);
                },
              ),

              // PARTIAL BOOK
              if (trade.status == TradeStatus.active)
                ListTile(
                  leading: Icon(
                    _getBookedQuantity(trade) > 0
                        ? Icons.undo_outlined
                        : Icons.call_split_outlined,
                  ),
                  title: Text(
                    _getBookedQuantity(trade) > 0
                        ? 'Undo Partial'
                        : 'Partial Book',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();

                    if (_getBookedQuantity(trade) > 0) {
                      undoPartialBooking(trade);
                    } else {
                      showPartialBookDialog(trade);
                    }
                  },
                ),

              // COMPLETE
              if (trade.status == TradeStatus.active)
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                  ),
                  title: const Text('Complete Trade'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    final tradeDate =
                        DateTime.parse(trade.tradeDate);

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

                    await completeTrade(trade, completedAt);
                  },
                ),

              // MAKE ACTIVE
              if (trade.status != TradeStatus.active)
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

              // DELETE
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Trade'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  Navigator.of(context).pop();

                  deleteTrade(trade);
                },
              ),

              const SizedBox(height: 8),

              // CANCEL
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

  // ===========================================================
  // TRADE DETAILS
  // ===========================================================

  Future<void> openTradeDetails(TradeModel trade) async {
    final bookings =
        await _tradeService.getBookings(trade.id);

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TradeDetailsPage(
          trade: trade,
          bookings: bookings,
        ),
      ),
    );
  }

  // ===========================================================
  // UNDO PARTIAL BOOKING
  // ===========================================================

  Future<void> undoPartialBooking(TradeModel trade) async {
    final bookings =
        await _tradeService.getBookings(trade.id);

    if (bookings.isEmpty) {
      await _loadTrades();
      return;
    }

    if (!mounted) {
      return;
    }

    final shouldUndo = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bookedQuantity = bookings.fold<int>(
          0,
          (total, booking) => total + booking.quantity,
        );

        return AlertDialog(
          title: const Text('Undo Partial Booking?'),
          content: Text(
            'This will remove the partial booking of '
            '$bookedQuantity quantity for '
            '${trade.symbol}.\n\n'
            'The original quantity will be restored.',
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
              child: const Text('Undo'),
            ),
          ],
        );
      },
    );

    if (shouldUndo != true) {
      return;
    }

    for (final booking in bookings) {
      await _tradeService.deleteBooking(
        trade.id,
        booking.id,
      );
    }

    await _loadTrades();
  }

  // ===========================================================
  // PARTIAL BOOK
  // ===========================================================

Future<void> showPartialBookDialog(TradeModel trade) async {
  final bookings = await _tradeService.getBookings(trade.id);

  if (!mounted) return;

  final bookedQuantity = bookings.fold<int>(
    0,
    (total, booking) => total + booking.quantity,
  );

  final remainingQuantity = trade.quantity - bookedQuantity;

  if (remainingQuantity <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No remaining quantity available for partial booking.',
        ),
      ),
    );

    return;
  }

  final defaultQuantity = (remainingQuantity / 2).floor();

  final quantityController = TextEditingController(
    text: defaultQuantity.toString(),
  );

  final priceController = TextEditingController();

  try {
    final result = await showDialog<PartialBookingResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final quantity = int.tryParse(
              quantityController.text.trim(),
            );

            final price = double.tryParse(
              priceController.text.trim(),
            );

            final isQuantityValid =
                quantity != null &&
                quantity > 0 &&
                quantity <= remainingQuantity;

            final isPriceValid = price != null && price > 0;

            final canBook = isQuantityValid && isPriceValid;

            String? quantityError;

            if (quantityController.text.trim().isNotEmpty) {
              if (quantity == null || quantity <= 0) {
                quantityError = 'Quantity must be greater than 0';
              } else if (quantity > remainingQuantity) {
                quantityError = 'Maximum is $remainingQuantity';
              }
            }

            String? priceError;

            if (priceController.text.trim().isNotEmpty) {
              if (price == null || price <= 0) {
                priceError = 'Price must be greater than 0';
              }
            }

            return AlertDialog(
              title: const Text('Partial Book'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Remaining Qty: $remainingQuantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: const OutlineInputBorder(),
                        errorText: quantityError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Book Price',
                        border: const OutlineInputBorder(),
                        errorText: priceError,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: canBook
                      ? () {
                          Navigator.of(dialogContext).pop(
                            PartialBookingResult(
                              quantity: quantity!,
                              price: price!,
                            ),
                          );
                        }
                      : null,
                  child: const Text('Book'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final booking = TradeBookingModel(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      tradeId: trade.id,
      quantity: result.quantity,
      price: result.price,
      bookedAt: _dateToString(DateTime.now()),
    );

    await _tradeService.addBooking(booking);

    if (!mounted) return;

    await _loadTrades();
  } finally {
    quantityController.dispose();
    priceController.dispose();
  }
}
  // ===========================================================
  // DATE
  // ===========================================================

  String _dateToString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ===========================================================
  // MAKE ACTIVE
  // ===========================================================

  Future<void> makeActive(TradeModel trade) async {
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

    await _tradeService.updateTrade(activeTrade);

    await _loadTrades();
  }

  // ===========================================================
  // REACTIVATION FAILURE
  // ===========================================================

  Future<void> _showReactivationRuleFailure(
    List<TradeRuleResult> results,
  ) async {
    final failedRules =
        results.where((result) => !result.passed).toList();

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

  // ===========================================================
  // COMPLETE TRADE
  // ===========================================================

  Future<void> completeTrade(
    TradeModel trade,
    String completedAt,
  ) async {
    final completedTrade = trade.copyWith(
      status: TradeStatus.completed,
      completedAt: completedAt,
    );

    await _tradeService.updateTrade(completedTrade);

    await _loadTrades();
  }

  // ===========================================================
  // DELETE TRADE
  // ===========================================================

  Future<void> deleteTrade(TradeModel trade) async {
    if (!mounted) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Trade?'),
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

    await _tradeService.deleteTrade(trade.id);

    await _loadTrades();
  }

  // ===========================================================
  // EDIT TRADE
  // ===========================================================

  Future<void> editTrade(TradeModel trade) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTradePage(
          tradeToEdit: trade,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadTrades();
  }

  // ===========================================================
  // BUILD
  // ===========================================================

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

    final totalItems =
        _trades.length + _availableTradeSlots;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trades'),
        actions: [
          TextButton.icon(
            onPressed: openKite,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Launch Kite'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: totalItems == 0
            ? _buildNoSlotsState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  24,
                ),
                itemCount: totalItems,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // EXISTING TRADE
                  if (index < _trades.length) {
                    final trade = _trades[index];

                    final bookedQuantity =
                        _getBookedQuantity(trade);

                    final remainingQuantity =
                        _getRemainingQuantity(trade);

                    final hasPartialBooking =
                        bookedQuantity > 0;

                    return TradeCard(
                      trade: trade,
                      remainingQuantity: remainingQuantity,
                      hasPartialBooking: hasPartialBooking,

                      realizedProfit:
                          _realizedProfits[trade.id],

                      averageExitPrice:
                          _averageExitPrices[trade.id],

                      overallRR:
                          _overallRRs[trade.id],

                      onTap: () {
                        openTradeDetails(trade);
                      },

                      onMorePressed: () {
                        openTradeActions(trade);
                      },
                    );
                  }

                  // EMPTY TRADE SLOT
                  return TradeSlotCard(
                    enabled: _canAddTrade,
                    disabledReason: _addTradeBlockReason,
                    onTap: addTrade,
                  );
                },
              ),
      ),
    );
  }

  // ===========================================================
  // NO SLOTS STATE
  // ===========================================================

  Widget _buildNoSlotsState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        24,
      ),
      child: Container(
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
        child: Column(
          children: [
            const Text(
              'No Trade Slots Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF141A2E),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _addTradeBlockReason ??
                  'No new trade slots are currently available.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF74798A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}