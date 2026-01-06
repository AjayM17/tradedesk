import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trade_dto.dart';
import '../models/trade_model.dart';
import '../v2/trade_action_log.dart';

class TradeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------
  // CREATE
  // ---------------------------
  static Future<void> addTrade(TradeDTO trade) async {
    await _db.collection('holdings').add(trade.toMap());
  }

  // ---------------------------
  // READ (for validation only)
  // ---------------------------
  static Future<List<TradeDTO>> getAllTradesOnce() async {
    final snapshot = await _db.collection('holdings').get();

    return snapshot.docs
        .map(
          (doc) => TradeDTO.fromFirestore(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }

  // ---------------------------
  // ACTIVE trades → TradeModel (V2)
  // ---------------------------
  static Future<List<TradeModel>> getActiveTradeModels() async {
    final snapshot = await _db.collection('holdings').get();

    return snapshot.docs
        .where((doc) => doc.data()['status'] == 'active')
        .map((doc) {
          final data = doc.data();

          final double entryPrice =
              (data['entryprice'] as num).toDouble();
          final double stopLoss =
              (data['stoploss'] as num).toDouble();
          final int quantity =
              (data['quantity'] as num).toInt();

          // Initial SL (immutable R reference)
          final double initialStopLoss =
              (data['initial_stoploss'] as num?)?.toDouble() ??
                  stopLoss;

          final double rValue =
              (entryPrice - initialStopLoss).abs();

          // ---------------------------
          // ACTIONS (SOURCE OF TRUTH)
          // ---------------------------
          final List<TradeActionLog> actions =
              (data['actions'] as List<dynamic>? ?? [])
                  .map(
                    (e) => TradeActionLog.fromMap(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList();

          return TradeModel(
            tradeId: doc.id,
            entryPrice: entryPrice,
            stopLoss: stopLoss,
            quantity: quantity,
            initialStopLoss: initialStopLoss,
            rValue: rValue,
            actions: actions,
          );
        })
        .toList();
  }
}
