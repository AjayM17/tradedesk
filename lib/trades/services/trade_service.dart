import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_desk/trades/models/trade_booking_model.dart';

import '../models/trade_model.dart';

class TradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tradesCollection {
    return _firestore.collection('trades');
  }

  /// Returns all trades.
  Future<List<TradeModel>> getTrades() async {
    final snapshot = await _tradesCollection.get();

    return snapshot.docs.map((doc) => TradeModel.fromJson(doc.data())).toList();
  }

  /// Returns a trade by ID.
  Future<TradeModel?> getTrade(String id) async {
    final doc = await _tradesCollection.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return TradeModel.fromJson(doc.data()!);
  }

  /// Adds a new trade.
  Future<void> addTrade(TradeModel trade) async {
    await _tradesCollection.doc(trade.id).set(trade.toJson());
  }

  /// Updates an existing trade by ID.
  Future<void> updateTrade(TradeModel updatedTrade) async {
    await _tradesCollection.doc(updatedTrade.id).set(updatedTrade.toJson());
  }

  /// Deletes a trade by ID.
  Future<void> deleteTrade(String id) async {
    await _tradesCollection.doc(id).delete();
  }

  CollectionReference<Map<String, dynamic>> _bookingsCollection(
    String tradeId,
  ) {
    return _tradesCollection.doc(tradeId).collection('bookings');
  }

  Future<List<TradeBookingModel>> getBookings(String tradeId) async {
    final snapshot = await _bookingsCollection(
      tradeId,
    ).orderBy('bookedAt').get();

    return snapshot.docs
        .map((doc) => TradeBookingModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> addBooking(TradeBookingModel booking) async {
    await _bookingsCollection(
      booking.tradeId,
    ).doc(booking.id).set(booking.toJson());
  }

  Future<void> updateBooking(TradeBookingModel booking) async {
    await _bookingsCollection(
      booking.tradeId,
    ).doc(booking.id).set(booking.toJson());
  }

  Future<void> deleteBooking(String tradeId, String bookingId) async {
    await _bookingsCollection(tradeId).doc(bookingId).delete();
  }

  int getRemainingQuantity(TradeModel trade, List<TradeBookingModel> bookings) {
    final bookedQuantity = bookings.fold<int>(
      0,
      (total, booking) => total + booking.quantity,
    );

    return trade.quantity - bookedQuantity;
  }
}
