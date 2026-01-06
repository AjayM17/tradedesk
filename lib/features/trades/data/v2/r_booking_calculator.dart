import '../models/trade_model.dart';

class RBookingCalculator {

  /// Minimum 25% of CURRENT quantity
  static int calculateQty({
    required TradeModel trade,
    double minPercent = 0.25,
  }) {
    final qty = (trade.quantity * minPercent).floor();
    return qty <= 0 ? 0 : qty;
  }
}
