import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trade_firestore_dto.dart';
import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TradeUiModel>> getTrades() {
    return _firestore.collection('holdings').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return TradeFirestoreDto(
            id: doc.id,
            data: doc.data(),
          ).toUiModel();
        }).toList();
      },
    );
  }
}
