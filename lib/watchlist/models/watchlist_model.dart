class WatchlistModel {
  final String id;
  final String symbol;
  final String? notes;

  const WatchlistModel({
    required this.id,
    required this.symbol,
    this.notes,
  });

  WatchlistModel copyWith({
    String? id,
    String? symbol,
    String? notes,
  }) {
    return WatchlistModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'notes': notes,
    };
  }

  factory WatchlistModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WatchlistModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      notes: json['notes'] as String?,
    );
  }
}