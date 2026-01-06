enum TradeActionKind {
  rBooking,
  addOn,
}

class TradeActionLog {
  final TradeActionKind kind;
  final int quantity;
  final double price;
  final double pnl;
  final DateTime timestamp;

  const TradeActionLog({
    required this.kind,
    required this.quantity,
    required this.price,
    required this.pnl,
    required this.timestamp,
  });

  TradeActionLog copyWith({
    int? actionIndex,
    TradeActionKind? kind,
    int? quantity,
    double? price,
    double? pnl,
    DateTime? timestamp,
  }) {
    return TradeActionLog(
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      pnl: pnl ?? this.pnl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kind': kind.name,
      'quantity': quantity,
      'price': price,
      'pnl': pnl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TradeActionLog.fromMap(Map<String, dynamic> map) {
    return TradeActionLog(
      kind: TradeActionKind.values.firstWhere(
        (e) => e.name == map['kind'],
      ),
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
      pnl: (map['pnl'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
