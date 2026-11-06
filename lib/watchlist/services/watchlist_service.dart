import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/watchlist_model.dart';

class WatchlistService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _watchlistCollection {
    return _firestore.collection('watchlist');
  }

  Future<List<WatchlistModel>> getWatchlist() async {
    final snapshot = await _watchlistCollection.get();

    return snapshot.docs
        .map(
          (doc) => WatchlistModel.fromJson(doc.data()),
        )
        .toList();
  }

  Future<WatchlistModel?> getWatchlistItem(String id) async {
    final doc = await _watchlistCollection.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return WatchlistModel.fromJson(doc.data()!);
  }

  Future<void> addToWatchlist(
    WatchlistModel item,
  ) async {
    await _watchlistCollection
        .doc(item.id)
        .set(item.toJson());
  }

  Future<void> updateWatchlist(
    WatchlistModel item,
  ) async {
    await _watchlistCollection
        .doc(item.id)
        .set(item.toJson());
  }

  Future<void> deleteFromWatchlist(String id) async {
    await _watchlistCollection.doc(id).delete();
  }
}