import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trade_dto.dart';
import '../models/trade_firestore_dto.dart';
import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // READ (STREAM)
  // ─────────────────────────────────────────────
  Stream<List<TradeUiModel>> getTrades() {
    return _firestore.collection('holdings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TradeFirestoreDto(
          id: doc.id,
          data: doc.data(),
        ).toUiModel();
      }).toList();
    });
  }

  // ─────────────────────────────────────────────
  // READ (ONCE)
  // ─────────────────────────────────────────────
  Future<List<TradeUiModel>> getTradesOnce() async {
    final snapshot = await _firestore.collection('holdings').get();

    return snapshot.docs.map((doc) {
      return TradeFirestoreDto(
        id: doc.id,
        data: doc.data(),
      ).toUiModel();
    }).toList();
  }

  // ─────────────────────────────────────────────
  // CREATE / UPDATE (V1 + BASE DATA)
  // ─────────────────────────────────────────────
Future<void> updateTrade({
  required String tradeId,
  required TradeDTO trade,
}) async {
  await _firestore
      .collection('holdings')
      .doc(tradeId)
      .update(trade.toMap());
}


  // ─────────────────────────────────────────────
  // V2: UPDATE TRADE FIELDS (EXECUTOR RESULT)
  // ─────────────────────────────────────────────
  Future<void> updateTradeFields({
    required String tradeId,
    required Map<String, dynamic> fields,
  }) async {
    fields['updated_at'] = DateTime.now().toIso8601String();

    await _firestore
        .collection('holdings')
        .doc(tradeId)
        .update(fields);
  }

  // ─────────────────────────────────────────────
  // V2: APPEND ACTION LOG (READ-ONLY HISTORY)
  // ─────────────────────────────────────────────
  Future<void> appendActionLog({
    required String tradeId,
    required Map<String, dynamic> log,
  }) async {
    await _firestore
        .collection('holdings')
        .doc(tradeId)
        .update({
      'actions': FieldValue.arrayUnion([log]),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<void> deleteTrade(String tradeId) async {
    await _firestore
        .collection('holdings')
        .doc(tradeId)
        .delete();
  }


  Future<void> undoLastAction({
  required String tradeId,
  required Map<String, dynamic> updatedTradeFields,
  required Map<String, dynamic> lastActionMap,
}) async {
  await _firestore.collection('holdings').doc(tradeId).update({
    ...updatedTradeFields,
    'actions': FieldValue.arrayRemove([lastActionMap]),
    'updated_at': DateTime.now().toIso8601String(),
  });
}

}
