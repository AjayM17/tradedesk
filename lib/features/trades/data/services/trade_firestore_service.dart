import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_desk/features/trades/data/models/r1_booking.dart';
import 'package:trade_desk/features/trades/data/models/trade_dto.dart';
import '../models/trade_firestore_dto.dart';
import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TradeUiModel>> getTrades() {
    return _firestore.collection('holdings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TradeFirestoreDto(id: doc.id, data: doc.data()).toUiModel();
      }).toList();
    });
  }

  Future<void> updateTrade({
    required String tradeId,
    required TradeDTO trade,
    required bool clearR1,
  }) async {
    final data = trade.toMap();

    if (clearR1) {
      data['r1'] = FieldValue.delete();
    }

    data['updated_at'] = DateTime.now().toIso8601String();

    await _firestore.collection('holdings').doc(tradeId).update(data);
  }

  Future<void> updateR1Booked(String tradeId, bool isBooked) async {
    await _firestore.collection('holdings').doc(tradeId).update({
      'isPartialProfitBooked': isBooked,
    });
  }

  Future<void> deleteTrade(String tradeId) async {
    await _firestore.collection('holdings').doc(tradeId).delete();
  }

  Future<void> bookR1({required String tradeId, required R1Booking r1}) async {
    await _firestore.collection('holdings').doc(tradeId).update({
      'r1': r1.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> undoR1(String tradeId) async {
    await _firestore.collection('holdings').doc(tradeId).update({
      'r1': FieldValue.delete(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<TradeUiModel>> getTradesOnce() async {
  final snapshot = await _firestore.collection('holdings').get();

  return snapshot.docs.map((doc) {
    return TradeFirestoreDto(
      id: doc.id,
      data: doc.data(),
    ).toUiModel();
  }).toList();
}

}
