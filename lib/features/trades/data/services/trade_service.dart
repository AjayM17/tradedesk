import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trade_dto.dart';

class TradeService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static Future<void> addTrade(TradeDTO trade) async {
    await _db.collection('holdings').add(trade.toMap());
  }
}
