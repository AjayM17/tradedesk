import 'package:trade_desk/features/trades/data/models/r1_booking.dart';

enum TradeStatus {
  active,
  free,
  closed,
}

class TradeUiModel {
  final String id;
  final String name;
  final TradeStatus status;
  final int quantity;
  final int partialQuantity;
  final double pnlValue;
  final double pnlPercent;
  final double buyPrice;
  final double stopLoss;
  final double initialStopLoss;
  final double oneRTarget;
  final int ageInDays;
  final DateTime tradeDate;
  final R1Booking? r1;

  TradeUiModel({
    required this.id,
    required this.name,
    required this.status,
    required this.quantity,
    required this.partialQuantity,
    required this.pnlValue,
    required this.pnlPercent,
    required this.buyPrice,
    required this.stopLoss,
    required this.initialStopLoss,
    required this.oneRTarget,
    required this.ageInDays,
    required this.tradeDate,
    required this.r1,
  });

  /// Remaining open quantity
  int get remainingQuantity {
    if (r1 == null) return quantity;
    return quantity - r1!.quantity;
  }

  /// ✅ ACTIVE capital at risk (FINAL RULE)
  double get investedAmount => buyPrice * remainingQuantity;
}
