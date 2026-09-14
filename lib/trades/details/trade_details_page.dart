import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trade_desk/trades/widgets/chart_link_button.dart';

import '../models/trade_booking_model.dart';
import '../models/trade_model.dart';

class TradeDetailsPage extends StatelessWidget {
  final TradeModel trade;
  final List<TradeBookingModel> bookings;

  const TradeDetailsPage({
    super.key,
    required this.trade,
    required this.bookings,
  });

  // =========================================================
  // QUANTITY CALCULATIONS
  // =========================================================

  int get bookedQuantity {
    return bookings.fold<int>(
      0,
      (total, booking) => total + booking.quantity,
    );
  }

  int get remainingQuantity {
    return math.max(
      trade.quantity - bookedQuantity,
      0,
    ).toInt();
  }

  int get stopLossExitQuantity {
    if (trade.status != TradeStatus.completed) {
      return 0;
    }

    return remainingQuantity;
  }

  int get finalExitQuantity {
    return bookedQuantity + stopLossExitQuantity;
  }

  // =========================================================
  // RISK CALCULATIONS
  // =========================================================

  double get riskPerShare {
    return math.max(
      trade.entryPrice - trade.initialSL,
      0.0,
    ).toDouble();
  }

  double get originalTotalRisk {
    return riskPerShare * trade.quantity;
  }

  double get currentRiskPerShare {
    return math.max(
      trade.entryPrice - trade.stopLoss,
      0.0,
    ).toDouble();
  }

  double get remainingRisk {
    return currentRiskPerShare * remainingQuantity;
  }

  double get unreleasedProtectedRisk {
    final originalRemainingRisk =
        riskPerShare * remainingQuantity;

    return math.max(
      originalRemainingRisk - remainingRisk,
      0.0,
    ).toDouble();
  }

  // =========================================================
  // PROFIT CALCULATIONS
  // =========================================================

  double _bookingProfit(TradeBookingModel booking) {
    return (booking.price - trade.entryPrice) *
        booking.quantity;
  }

  double get releasedProfit {
    return bookings.fold<double>(
      0.0,
      (total, booking) {
        return total + _bookingProfit(booking);
      },
    );
  }

  double get stopLossExitProfit {
    if (trade.status != TradeStatus.completed ||
        stopLossExitQuantity <= 0) {
      return 0.0;
    }

    return (trade.stopLoss - trade.entryPrice) *
        stopLossExitQuantity;
  }

  double get finalRealizedProfit {
    return releasedProfit + stopLossExitProfit;
  }

  double get overallRR {
    if (originalTotalRisk <= 0) {
      return 0.0;
    }

    if (trade.status == TradeStatus.completed) {
      return finalRealizedProfit / originalTotalRisk;
    }

    return (releasedProfit + unreleasedProtectedRisk) /
        originalTotalRisk;
  }

  String get tradeResult {
    if (trade.status != TradeStatus.completed) {
      return 'In Progress';
    }

    return overallRR <= 0.0
        ? 'Loss Trade'
        : 'Winning Trade';
  }

  // =========================================================
  // EXIT PRICE CALCULATIONS
  // =========================================================

  double get averageExitPrice {
    if (finalExitQuantity <= 0) {
      return 0.0;
    }

    double totalExitValue = 0.0;

    for (final booking in bookings) {
      totalExitValue += booking.price * booking.quantity;
    }

    if (stopLossExitQuantity > 0) {
      totalExitValue +=
          trade.stopLoss * stopLossExitQuantity;
    }

    return totalExitValue / finalExitQuantity;
  }

  // =========================================================
  // FORMATTING
  // =========================================================

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  String _formatDate(String? value) {
    final date = _parseDate(value);

    if (date == null) {
      return '—';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatMoney(double value) {
    final sign = value < 0 ? '-₹' : '₹';

    return '$sign${value.abs().toStringAsFixed(2)}';
  }

  String _formatRR(double value) {
    return '${value.toStringAsFixed(2)}R';
  }

 String _formatAge() {
  final start = _parseDate(trade.tradeDate);

  if (start == null) {
    return '—';
  }

  final DateTime end;

  if (trade.status == TradeStatus.completed) {
    final completedDate = _parseDate(trade.completedAt);

    // A completed trade must use completedAt.
    if (completedDate == null) {
      return '—';
    }

    end = completedDate;
  } else {
    end = DateTime.now();
  }

  final startDate = DateTime(
    start.year,
    start.month,
    start.day,
  );

  final endDate = DateTime(
    end.year,
    end.month,
    end.day,
  );

  final days = endDate.difference(startDate).inDays;

  if (days <= 0) {
    return 'Today';
  }

  if (days == 1) {
    return '1 day';
  }

  return '$days days';
}

  // =========================================================
  // STATUS
  // =========================================================

  Color _statusColor() {
    switch (trade.status) {
      case TradeStatus.waiting:
        return Colors.orange;
      case TradeStatus.active:
        return Colors.blue;
      case TradeStatus.completed:
        return Colors.green;
    }
  }

  String _statusText() {
    switch (trade.status) {
      case TradeStatus.waiting:
        return 'Waiting';
      case TradeStatus.active:
        return 'Active';
      case TradeStatus.completed:
        return 'Completed';
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trade.symbol),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          28,
        ),
        children: [
          _buildTradeHeader(),
          const SizedBox(height: 16),
          _buildTradeInformationCard(),
          const SizedBox(height: 16),
          _buildPerformanceCard(),
          const SizedBox(height: 16),
          _buildBookingHistoryCard(),
        ],
      ),
    );
  }

  // =========================================================
  // TRADE HEADER
  // =========================================================

  Widget _buildTradeHeader() {
    final statusColor = _statusColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                trade.symbol.isNotEmpty
                    ? trade.symbol
                        .substring(0, 1)
                        .toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          trade.symbol,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ChartLinkButton(
                        symbol: trade.symbol,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(trade.tradeDate),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusText(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TRADE INFORMATION
  // =========================================================

  Widget _buildTradeInformationCard() {
    final isCompleted =
        trade.status == TradeStatus.completed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'TRADE INFORMATION',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            _infoRow(
              'Entry Price',
              _formatMoney(trade.entryPrice),
            ),
            _infoRow(
              'Initial Stop Loss',
              _formatMoney(trade.initialSL),
            ),
            _infoRow(
              'Current Stop Loss',
              _formatMoney(trade.stopLoss),
            ),
            _infoRow(
              'Original Quantity',
              '${trade.quantity}',
            ),
            _infoRow(
              'Booked Quantity',
              '$bookedQuantity',
            ),
            if (isCompleted)
              _infoRow(
                'Stop-Loss Exit Quantity',
                '$stopLossExitQuantity',
              ),
            _infoRow(
              'Final Exit Quantity',
              '$finalExitQuantity',
            ),
            if (!isCompleted)
              _infoRow(
                'Remaining Quantity',
                '$remainingQuantity',
              ),
            if (isCompleted)
              _infoRow(
                'Average Exit Price',
                _formatMoney(averageExitPrice),
              ),
            _infoRow(
              'Trade Age',
              _formatAge(),
            ),
            _infoRow(
              'Created Date',
              _formatDate(trade.tradeDate),
            ),
            _infoRow(
              'Completed Date',
              _formatDate(trade.completedAt),
            ),
            if (trade.notes != null &&
                trade.notes!.trim().isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(trade.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PERFORMANCE
  // =========================================================

  Widget _buildPerformanceCard() {
    final isCompleted =
        trade.status == TradeStatus.completed;

    final totalRisk = originalTotalRisk;
    final scale = math.max(totalRisk, 1.0).toDouble();

    final redFraction = isCompleted
        ? 0.0
        : math.min(
            remainingRisk / scale,
            1.0,
          ).toDouble();

    final orangeFraction = isCompleted
        ? 0.0
        : math.min(
            unreleasedProtectedRisk / scale,
            1.0,
          ).toDouble();

    final greenValue = isCompleted
        ? math.max(finalRealizedProfit, 0.0)
        : math.max(releasedProfit, 0.0);

    final greenFraction = math.min(
      greenValue / scale,
      1.0,
    ).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              isCompleted
                  ? 'FINAL PERFORMANCE'
                  : 'RISK PERFORMANCE',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Overall R',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  _formatRR(overallRR),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 8),
              _infoRow(
                'Realized Profit/Loss',
                _formatMoney(finalRealizedProfit),
              ),
              _infoRow(
                'Average Exit Price',
                _formatMoney(averageExitPrice),
              ),
              _infoRow(
                'Result',
                tradeResult,
              ),
            ] else ...[
              const SizedBox(height: 8),
              _infoRow(
                'Original Total Risk',
                _formatMoney(originalTotalRisk),
              ),
              _infoRow(
                'Remaining Exposed Risk',
                _formatMoney(remainingRisk),
              ),
              _infoRow(
                'Unreleased Protection',
                _formatMoney(unreleasedProtectedRisk),
              ),
              _infoRow(
                'Released Profit/Loss',
                _formatMoney(releasedProfit),
              ),
            ],
            const SizedBox(height: 14),
            if (!isCompleted)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 28,
                  child: Row(
                    children: [
                      if (redFraction > 0)
                        Expanded(
                          flex: math.max(
                            (redFraction * 1000).round(),
                            1,
                          ),
                          child: Container(
                            color: const Color(0xFFD32F2F),
                          ),
                        ),
                      if (orangeFraction > 0)
                        Expanded(
                          flex: math.max(
                            (orangeFraction * 1000).round(),
                            1,
                          ),
                          child: Container(
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                      if (greenFraction > 0)
                        Expanded(
                          flex: math.max(
                            (greenFraction * 1000).round(),
                            1,
                          ),
                          child: Container(
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              _legendRow(
                color: const Color(0xFFD32F2F),
                label: 'Remaining Risk',
                value: _formatMoney(remainingRisk),
              ),
              _legendRow(
                color: const Color(0xFFFF9800),
                label: 'Unreleased Protection',
                value: _formatMoney(
                  unreleasedProtectedRisk,
                ),
              ),
              _legendRow(
                color: const Color(0xFF2E7D32),
                label: 'Released Profit/Loss',
                value: _formatMoney(releasedProfit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendRow({
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOOKING HISTORY
  // =========================================================

  Widget _buildBookingHistoryCard() {
    final sortedBookings = [...bookings]
      ..sort(
        (a, b) => b.bookedAt.compareTo(a.bookedAt),
      );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'PROFIT BOOKING HISTORY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            if (sortedBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    'No profit bookings yet.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...sortedBookings.map(_buildBookingTile),
            if (trade.status == TradeStatus.completed &&
                stopLossExitQuantity > 0) ...[
              if (sortedBookings.isNotEmpty)
                const Divider(height: 24),
              _buildStopLossExitTile(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStopLossExitTile() {
    final profit = stopLossExitProfit;
    final bookingRisk =
        riskPerShare * stopLossExitQuantity;

    final bookingRR = bookingRisk > 0
        ? profit / bookingRisk
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Stop-Loss Exit',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatMoney(profit),
                style: TextStyle(
                  color: profit >= 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(
            'Quantity',
            '$stopLossExitQuantity',
          ),
          _infoRow(
            'Exit Price',
            _formatMoney(trade.stopLoss),
          ),
          _infoRow(
            'Exit R:R',
            _formatRR(bookingRR),
          ),
          _infoRow(
            'Exit Date',
            _formatDate(trade.completedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTile(
    TradeBookingModel booking,
  ) {
    final profit = _bookingProfit(booking);
    final bookingRisk =
        riskPerShare * booking.quantity;

    final bookingRR = bookingRisk > 0
        ? profit / bookingRisk
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(booking.bookedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatMoney(profit),
                style: TextStyle(
                  color: profit >= 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(
            'Quantity',
            '${booking.quantity}',
          ),
          _infoRow(
            'Book Price',
            _formatMoney(booking.price),
          ),
          _infoRow(
            'Booked R:R',
            _formatRR(bookingRR),
          ),
        ],
      ),
    );
  }
}