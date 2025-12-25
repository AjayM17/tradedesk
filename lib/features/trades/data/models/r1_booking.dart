class R1Booking {
  final double sellPrice;
  final int quantity;
  final double profit;
  final DateTime bookedAt;

  R1Booking({
    required this.sellPrice,
    required this.quantity,
    required this.profit,
    required this.bookedAt,
  });

  /// Convert Dart object → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'sellPrice': sellPrice,
      'quantity': quantity,
      'profit': profit,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  /// Convert Firestore Map → Dart object
  factory R1Booking.fromMap(Map<String, dynamic> map) {
    return R1Booking(
      sellPrice: (map['sellPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      profit: (map['profit'] as num).toDouble(),
      bookedAt: DateTime.parse(map['bookedAt']),
    );
  }
}
