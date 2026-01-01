import 'package:cloud_firestore/cloud_firestore.dart';

class TradeDTO {
  final String? id; // 🔑 Firestore document id (NOT stored)
  final String name;
  final String symbol;
  final double entryPrice;
  final double stopLoss;
  final double initialStopLoss;
  final int quantity;
  final String status;
  final String tradeDate;
  final bool isR1Booked;

  TradeDTO({
    required this.id, // ✅ nullable but REQUIRED in constructor
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

  // ---------------------------
  // Firestore → DTO
  // ---------------------------
  factory TradeDTO.fromFirestore(
    Map<String, dynamic> map,
    String docId,
  ) {
    return TradeDTO(
      id: docId, // ✅ comes from Firestore
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      entryPrice: (map['entryprice'] as num).toDouble(),
      stopLoss: (map['stoploss'] as num).toDouble(),
      initialStopLoss:
          (map['initial_stoploss'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      status: map['status'] ?? 'active',
      tradeDate: map['trade_date'] ?? '',
      isR1Booked: map['isR1Booked'] ?? false,
    );
  }

  // ---------------------------
  // DTO → Firestore
  // ---------------------------
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
