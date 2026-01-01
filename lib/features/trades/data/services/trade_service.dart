import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trade_dto.dart';
import '../models/trade_model.dart';

class TradeService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

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
            doc.id, // ✅ Firestore document id
          ),
        )
        .toList();
  }

  // ---------------------------
  // ACTIVE trades → TradeModel
  // ---------------------------
static Future<List<TradeModel>> getActiveTradeModels() async {
  final snapshot = await _db.collection('holdings').get();

  return snapshot.docs
      .where((doc) => doc.data()['status'] == 'active')
      .map(
        (doc) {
          final data = doc.data();
          return TradeModel(
            tradeId: doc.id, // ✅ THIS IS THE FIX
            entryPrice: (data['entryprice'] as num).toDouble(),
            stopLoss: (data['stoploss'] as num).toDouble(),
            quantity: (data['quantity'] as num).toInt(),
          );
        },
      )
      .toList();
}

}
