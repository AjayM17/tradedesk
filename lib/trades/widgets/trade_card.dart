import 'package:flutter/material.dart';

import '../models/trade_model.dart';

class TradeCard extends StatelessWidget {
  final TradeModel trade;
  final VoidCallback? onTap;

  const TradeCard({
    super.key,
    required this.trade,
    this.onTap,
  });

  double get investmentValue {
    return trade.entryPrice * trade.quantity;
  }

  double get riskValue {
    final riskPerShare =
        (trade.entryPrice - trade.stopLoss).abs();

    return riskPerShare * trade.quantity;
  }

  double get riskPercent {
    if (trade.entryPrice <= 0) {
      return 0;
    }

    final riskPerShare =
        (trade.entryPrice - trade.stopLoss).abs();

    return (riskPerShare / trade.entryPrice) * 100;
  }

  double get slBuyValue {
    return trade.stopLoss - trade.entryPrice;
  }

  String getTradeAge() {
    final tradeDate = _parseDateOnly(trade.tradeDate);
    final today = _parseDateOnly(_dateToString(DateTime.now()));

    final days = today.difference(tradeDate).inDays;

    if (days <= 0) {
      return 'Today';
    }

    return '$days ${days == 1 ? 'day' : 'days'}';
  }

  DateTime _parseDateOnly(String dateString) {
    final parts = dateString
        .split('-')
        .map(int.parse)
        .toList();

    return DateTime(
      parts[0],
      parts[1],
      parts[2],
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

  @override
  Widget build(BuildContext context) {
    final isPositive = slBuyValue >= 0;

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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                    child: Text(
                      trade.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101A31),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Main values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metric(
                    'Qty',
                    trade.quantity.toString(),
                  ),
                  _metric(
                    'Buy',
                    trade.entryPrice.toStringAsFixed(2),
                  ),
                  _metric(
                    'SL',
                    trade.stopLoss.toStringAsFixed(2),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Secondary values
              Row(
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

              const SizedBox(height: 10),

              // Risk badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFEDF9F1)
                      : const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPositive
                      ? '₹${riskValue.toStringAsFixed(0)} • '
                          '${riskPercent.toStringAsFixed(1)}%'
                      : '-₹${riskValue.toStringAsFixed(0)} • '
                          '${riskPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF28A64D)
                        : const Color(0xFFC6284A),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),

              // Notes
              if (trade.notes != null &&
                  trade.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
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