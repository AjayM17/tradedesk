import 'package:cloud_firestore/cloud_firestore.dart';

class TradeDTO {
  final String name; // Display name (TCS)
  final String symbol; // Full symbol (TCS.NS / TCS.BO)
  final double entryPrice;
  final double stopLoss;
  final double initialStopLoss;
  final int quantity;
  final String status;
  final String tradeDate;
  final bool isR1Booked;

  TradeDTO({
    required this.name,
    required this.symbol,
    required this.entryPrice,
    required this.stopLoss,
    required this.initialStopLoss,
    required this.quantity,
    required this.status,
    required this.tradeDate,
    this.isR1Booked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'symbol': symbol,
      'entryprice': entryPrice,
      'stoploss': stopLoss,
      'initial_stoploss': initialStopLoss,
      'quantity': quantity,
      'status': status,
      'trade_date': tradeDate,
      'isR1Booked': isR1Booked,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
