import 'package:flutter/material.dart';
import 'package:trade_desk/trades/widgets/chart_link_button.dart';

import '../models/trade_model.dart';

class TradeCard extends StatelessWidget {
  final TradeModel trade;

  /// Quantity still open after partial bookings.
  final int remainingQuantity;

  /// True when at least one partial booking exists.
  final bool hasPartialBooking;

  /// Completed-trade calculated values.
  final double? realizedProfit;
  final double? averageExitPrice;
  final double? overallRR;

  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const TradeCard({
    super.key,
    required this.trade,
    required this.remainingQuantity,
    this.hasPartialBooking = false,
    this.realizedProfit,
    this.averageExitPrice,
    this.overallRR,
    this.onTap,
    this.onMorePressed,
  });

  bool get isCompleted => trade.status == TradeStatus.completed;

  int get displayedQuantity {
    return isCompleted ? trade.quantity : remainingQuantity;
  }

  double get investmentValue {
    return trade.entryPrice * displayedQuantity;
  }

  double get riskValue {
    final riskPerShare = trade.entryPrice - trade.stopLoss;

    if (riskPerShare <= 0) {
      return 0;
    }

    return riskPerShare * remainingQuantity;
  }

  double get riskPercent {
    if (trade.entryPrice <= 0) {
      return 0;
    }

    final riskPerShare = trade.entryPrice - trade.stopLoss;

    if (riskPerShare <= 0) {
      return 0;
    }

    return (riskPerShare / trade.entryPrice) * 100;
  }

  double get slBuyValue {
    return (trade.stopLoss - trade.entryPrice) * remainingQuantity;
  }

  double get slBuyPercent {
    if (trade.entryPrice <= 0) {
      return 0;
    }

    return ((trade.stopLoss - trade.entryPrice) / trade.entryPrice) * 100;
  }

String getTradeAge() {
  final tradeDate = _parseDateOnly(trade.tradeDate);

  if (tradeDate == null) {
    return '-';
  }

  final endDate = isCompleted && trade.completedAt != null
      ? _parseDateOnly(trade.completedAt!)
      : _parseDateOnly(_dateToString(DateTime.now()));

  if (endDate == null) {
    return '-';
  }

  final days = endDate.difference(tradeDate).inDays;

  if (days <= 0) {
    return 'Today';
  }

  return '$days ${days == 1 ? 'day' : 'days'}';
}

 DateTime? _parseDateOnly(String dateString) {
  final parsed = DateTime.tryParse(dateString);

  if (parsed == null) {
    return null;
  }

  return DateTime(
    parsed.year,
    parsed.month,
    parsed.day,
  );
}

String _dateToString(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

  Color _statusColor() {
    switch (trade.status) {
      case TradeStatus.active:
        return const Color(0xFF42B85C);

      case TradeStatus.completed:
        return const Color(0xFF2563EB);

      case TradeStatus.waiting:
        return const Color(0xFFAEB3BD);
    }
  }

  String _formatMoney(double value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign₹${value.abs().toStringAsFixed(0)}';
  }

  Widget _buildCompletedBadge() {
    final profit = realizedProfit ?? 0;
    final rr = overallRR ?? 0;
    final isWinning = rr >= 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isWinning
            ? const Color(0xFFEDF9F1)
            : const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${isWinning ? 'Winning Trade' : 'Loss Trade'} • '
        '${_formatMoney(profit)} • '
        '${rr.toStringAsFixed(2)}R',
        style: TextStyle(
          color: isWinning
              ? const Color(0xFF28A64D)
              : const Color(0xFFC6284A),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActiveBadge() {
    final isProtected = trade.stopLoss >= trade.entryPrice;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isProtected
            ? const Color(0xFFEDF9F1)
            : const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isProtected
            ? '+₹${slBuyValue.toStringAsFixed(0)} • '
                '+${slBuyPercent.toStringAsFixed(1)}%'
            : '-₹${riskValue.toStringAsFixed(0)} • '
                '${riskPercent.toStringAsFixed(1)}%',
        style: TextStyle(
          color: isProtected
              ? const Color(0xFF28A64D)
              : const Color(0xFFC6284A),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            trade.symbol,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ChartLinkButton(symbol: trade.symbol),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasPartialBooking && !isCompleted)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.call_split_outlined,
                            size: 16,
                            color: Color(0xFFD98A00),
                          ),
                        ),

                      if (hasPartialBooking && !isCompleted)
                        const SizedBox(width: 4),

                      SizedBox(
                        width: 28,
                        height: 32,
                        child: IconButton(
                          onPressed: onMorePressed,
                          tooltip: 'Trade actions',
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            maxWidth: 28,
                            minHeight: 32,
                            maxHeight: 32,
                          ),
                          icon: const Icon(
                            Icons.more_vert,
                            size: 22,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // MAIN VALUES
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric(
                      isCompleted ? 'Exited Qty' : 'Qty',
                      displayedQuantity.toString(),
                    ),
                    _metric(
                      'Buy',
                      trade.entryPrice.toStringAsFixed(2),
                    ),
                    _metric(
                      isCompleted ? 'Avg Exit' : 'SL',
                      isCompleted
                          ? (averageExitPrice ?? 0).toStringAsFixed(2)
                          : trade.stopLoss.toStringAsFixed(2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // SECONDARY VALUES
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _smallKv(
                      'Init SL',
                      trade.initialSL.toStringAsFixed(2),
                    ),
                    _smallKv(
                      'Invested',
                      '₹${investmentValue.toStringAsFixed(0)}',
                    ),
                    _smallKv(
                      'Age',
                      getTradeAge(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // BADGE
              isCompleted
                  ? _buildCompletedBadge()
                  : _buildActiveBadge(),

              // NOTES
              if (trade.notes != null && trade.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFEEEEF1),
                        ),
                      ),
                    ),
                    child: Text(
                      'Note: ${trade.notes}',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
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
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101A31),
          ),
        ),
      ],
    );
  }

  Widget _smallKv(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
      ),
    );
  }
}