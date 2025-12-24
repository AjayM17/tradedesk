import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> updateTrade(String tradeId, Map<String, dynamic> data) async {
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
}
