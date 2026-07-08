import 'package:flutter/material.dart';

import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/v2/r_booking_calculator.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/trade_ui_model.dart';
import '../../data/v2/trade_action_log.dart';
import 'package:provider/provider.dart';
import 'package:trade_desk/features/settings/data/settings_state.dart';

class TradeCard extends StatelessWidget {
  final TradeUiModel trade;

  const TradeCard({super.key, required this.trade});

  // ───────── HELPERS ─────────

  @override
  Widget build(BuildContext context) {
    final t = trade.trade;
    final textTheme = Theme.of(context).textTheme;
    final bool isProfit = trade.pnlValue >= 0;

    // final double targetPrice = RBookingCalculator.calculateTargetPrice(
    //   trade: t,
    // );
    final riskPerShare = trade.averageBuyPrice - t.initialStopLoss;

    final targetR = context.select<SettingsState, double>((s) => s.targetR);

    final targetPrice = trade.averageBuyPrice + (riskPerShare * targetR);

    final int t1Qty = RBookingCalculator.calculateQty(trade: t);

    return GestureDetector(
      onTap: () => _showActionSheet(context),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────── HEADER ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _StatusIcon(status: trade.status),
                      const SizedBox(width: 6),
                      Text(
                        trade.name,
                        style: textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (trade.partialBooked)
                    const Tooltip(
                      message: 'Partial Booked',
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
                  // Text(
                  //   'Actions ${trade.actions.length}/4',
                  //   style: textTheme.bodySmall!.copyWith(
                  //     color: const Color(0xFF6B7280),
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 10),

              // ───────── KEY METRICS ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metric('Qty', trade.effectiveQuantity),
                  _metric('Buy', trade.averageBuyPrice.toStringAsFixed(2)),
                  _metric('SL', t.stopLoss),
                ],
              ),

              const SizedBox(height: 8),

              // ───────── SECONDARY INFO ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _smallKv('Init SL', t.initialStopLoss),
                  _smallKv(
                    'Invested',
                    '₹${trade.investedAmount.toStringAsFixed(0)}',
                  ),
                  _smallKv(
                    'Age',
                    trade.ageInDays < 7
                        ? '${trade.ageInDays}d'
                        : '${(trade.ageInDays / 7).floor()}w',
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ───────── P&L + TARGETS ─────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? AppTheme.success.withOpacity(0.08)
                          : AppTheme.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'P&L: ₹${trade.pnlValue.toStringAsFixed(0)} '
                      '(${trade.pnlPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: isProfit ? AppTheme.success : AppTheme.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        if (!trade.partialBooked)
                          buildRTag(
                            label:
                                '${targetR.toStringAsFixed(targetR % 1 == 0 ? 0 : 1)}R',
                            qty: t1Qty,
                            price: targetPrice,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // const Divider(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRTag({
    required String label,
    required int qty,
    required double price,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label • Qty $qty • ₹${price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ───────── INFO ALERT ─────────

  void _showActionSheet(BuildContext context) {
    final t = trade.trade;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔒 IF CLOSED → ONLY DELETE
                if (trade.status == TradeStatus.closed) ...[
                  ListTile(
                    leading: const Icon(Icons.refresh, color: Colors.blue),
                    title: const Text('Mark as Active'),
                    onTap: () async {
                      Navigator.pop(context);

                      await TradeFirestoreService().updateTradeStatus(
                        tradeId: trade.id,
                        status: TradeStatus.active,
                      );
                    },
                  ),
                ] else ...[
                  /// EDIT
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Trade'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateTradeScreen(trade: trade),
                        ),
                      );
                    },
                  ),

                  /// DELETE
                  // ListTile(
                  //   leading: const Icon(Icons.delete, color: Colors.red),
                  //   title: const Text('Delete Trade'),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     _confirmDelete(context);
                  //   },
                  // ),

                  /// R BOOKING
                  if (trade.actions.isEmpty)
                    ListTile(
                      leading: Icon(
                        trade.partialBooked ? Icons.undo : Icons.emoji_events,
                        color: trade.partialBooked
                            ? Colors.grey
                            : Colors.orange,
                      ),
                      title: Text(
                        trade.partialBooked
                            ? 'Undo Partial Book'
                            : 'Partial Book',
                      ),
                      onTap: () async {
                        Navigator.pop(context);

                        await TradeFirestoreService().updatePartialBooked(
                          tradeId: trade.id,
                          value: !trade.partialBooked, // 🔁 toggle
                        );
                      },
                    ),

                  ListTile(
                    leading: Icon(
                      trade.status == TradeStatus.active
                          ? Icons.check_circle
                          : Icons.refresh,
                      color: trade.status == TradeStatus.active
                          ? Colors.green
                          : Colors.blue,
                    ),
                    title: Text(
                      trade.status == TradeStatus.active
                          ? 'Mark as Completed'
                          : 'Mark as Active',
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      await TradeFirestoreService().updateTradeStatus(
                        tradeId: trade.id,
                        status: trade.status == TradeStatus.active
                            ? TradeStatus.closed
                            : TradeStatus.active,
                      );
                    },
                  ),

                  /// UNDO
                  // if (trade.actions.isNotEmpty)
                  //   ListTile(
                  //     leading: const Icon(Icons.undo),
                  //     title: const Text('Undo Last Action'),
                  //     onTap: () {
                  //       Navigator.pop(context);
                  //       _confirmUndo(context);
                  //     },
                  //   ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────── DELETE ─────────
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trade'),
        content: const Text(
          'This trade and all its actions will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TradeFirestoreService().deleteTrade(trade.id);
    }
  }

  // ───────── UNDO ─────────

  // ───────── UI HELPERS ─────────
  Widget _metric(String label, dynamic value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
      Text(
        '$value',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ],
  );

  Widget _smallKv(String label, dynamic value) => Text(
    '$label: $value',
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFF6B7280),
    ),
  );
}

// ───────── STATUS ICON ─────────
class _StatusIcon extends StatelessWidget {
  final TradeStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      size: 10,
      color: switch (status) {
        TradeStatus.active => Colors.green,
        TradeStatus.free => Colors.blue,
        TradeStatus.closed => Colors.grey,
      },
    );
  }
}
