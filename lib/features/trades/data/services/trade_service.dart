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
        .map((doc) => TradeDTO.fromMap(doc.data()))
        .toList();
  }

  // ---------------------------
  // ACTIVE trades → TradeModel
  // ---------------------------
  static Future<List<TradeModel>> getActiveTradeModels() async {
    final allTrades = await getAllTradesOnce();

    return allTrades
        .where((t) => t.status == 'active')
        .map(
          (t) => TradeModel(
            entryPrice: t.entryPrice,
            stopLoss: t.stopLoss,
            quantity: t.quantity,
          ),
        )
        .toList();
  }
}
