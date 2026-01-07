import 'package:flutter/material.dart';

import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/v2/trade_v2_executor.dart';
import 'package:trade_desk/features/trades/data/validators/trade_v2_addon_validator.dart';
import 'package:trade_desk/features/trades/presentation/screens/create_trade_screen.dart';
import 'package:trade_desk/features/trades/presentation/widgets/add_on_v2_dialog.dart';
import 'package:trade_desk/features/trades/presentation/widgets/r_booking_v2_dialog.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/trade_ui_model.dart';
import '../../data/v2/trade_action_log.dart';

class TradeCard extends StatelessWidget {
  final TradeUiModel trade;

  const TradeCard({super.key, required this.trade});

  // ───────── HELPERS ─────────

  /// Entry quantity (used ONLY for add-on cap)
  int _originalQuantity() {
    int qty = trade.trade.quantity;

    for (final a in trade.actions) {
      if (a.kind == TradeActionKind.rBooking) {
        qty += a.quantity;
      } else if (a.kind == TradeActionKind.addOn) {
        qty -= a.quantity;
      }
    }
    return qty;
  }

  int _rBookingCount() =>
      trade.actions.where((a) => a.kind == TradeActionKind.rBooking).length;

  int _addOnCount() =>
      trade.actions.where((a) => a.kind == TradeActionKind.addOn).length;

  TradeActionKind? _lastActionKind() =>
      trade.actions.isEmpty ? null : trade.actions.last.kind;

  @override
  Widget build(BuildContext context) {
    final t = trade.trade;
    final textTheme = Theme.of(context).textTheme;
    final bool isProfit = trade.pnlValue >= 0;

    final int rCount = _rBookingCount();
    final int addOnCount = _addOnCount();
    final lastKind = _lastActionKind();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
                      style: textTheme.titleSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  'Actions ${trade.actions.length}/4',
                  style: textTheme.bodySmall!.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ───────── KEY METRICS ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metric('Qty', t.quantity),
                _metric(
                  'Buy (Avg)',
                  trade.averageBuyPrice.toStringAsFixed(2),
                ),
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
                _smallKv('Age', '${trade.ageInDays}d'),
              ],
            ),

            const SizedBox(height: 10),

            // ───────── P&L ─────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isProfit
                    ? AppTheme.success.withOpacity(0.08)
                    : AppTheme.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'P&L: ${trade.pnlValue.toStringAsFixed(0)} '
                '(${trade.pnlPercent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: isProfit
                      ? AppTheme.success
                      : AppTheme.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ───────── ACTION HISTORY ─────────
            _actionSummaries(),

            const Divider(height: 20),

            // ───────── ACTION BAR ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Utility
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateTradeScreen(trade: trade),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                // Strategy buttons
                Row(
                  children: [
                    if (trade.actions.isEmpty)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                RBookingV2Dialog(trade: t),
                          );
                        },
                        child: const Text('Book R1'),
                      ),

                    if (rCount == 1 &&
                        addOnCount == 0 &&
                        lastKind == TradeActionKind.rBooking)
                      TextButton(
                        onPressed: () {
                          final result =
                              TradeV2AddOnValidator.canOpenAddOn(
                            trade: t,
                          );

                          if (!result.isAllowed) {
                            _showInfoAlert(
                              context,
                              result.reason!,
                            );
                            return;
                          }

                          final maxAddOnQty =
                              (_originalQuantity() * 0.25).floor();

                          showDialog(
                            context: context,
                            builder: (_) => AddOnV2Dialog(
                              trade: t,
                              maxAddOnQty: maxAddOnQty,
                            ),
                          );
                        },
                        child: const Text('Add-On'),
                      ),

                    if (rCount == 1 &&
                        addOnCount == 1 &&
                        lastKind == TradeActionKind.addOn)
                      TextButton(
                        onPressed: () {
                          _showInfoAlert(
                            context,
                            'R2 booking will be available in next phase.',
                          );
                        },
                        child: const Text('Book R2'),
                      ),
                  ],
                ),
              ],
            ),

            // ───────── UNDO ─────────
            if (trade.actions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmUndo(context),
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo Last Action'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────── INFO ALERT ─────────
  void _showInfoAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
  Future<void> _confirmUndo(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Undo Last Action'),
        content: const Text(
          'This will revert the most recent action.\n\nThis cannot be redone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Undo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final reverted =
        TradeV2Executor.undoLastAction(trade: trade.trade);

    final lastAction = trade.trade.actions.last;

    await TradeFirestoreService().undoLastAction(
      tradeId: trade.id,
      updatedTradeFields: {
        'quantity': reverted.quantity,
        'actions': reverted.actions.map((a) => a.toMap()).toList(),
      },
      lastActionMap: lastAction.toMap(),
    );
  }

  // ───────── ACTION LIST ─────────
  Widget _actionSummaries() {
    if (trade.actions.isEmpty) return const SizedBox.shrink();

    final List<Widget> rows = [];
    int rCount = 0;

    for (final a in trade.actions) {
      if (a.kind == TradeActionKind.rBooking) {
        rCount++;
        rows.add(
          _iconRow(
            Icons.emoji_events,
            Colors.orange,
            'R$rCount @ ${a.price.toStringAsFixed(0)}'
            ' | Qty: ${a.quantity}'
            ' | +₹${a.pnl.toStringAsFixed(0)}',
          ),
        );
      }

      if (a.kind == TradeActionKind.addOn) {
        rows.add(
          _iconRow(
            Icons.add_circle,
            Colors.blue,
            'Add-On @ ${a.price.toStringAsFixed(0)}'
            ' | Qty: ${a.quantity}',
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _iconRow(IconData icon, Color color, String text) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
