class TradeBookingModel {
  final String id;
  final String tradeId;
  final int quantity;
  final double price;
  final String bookedAt;

  const TradeBookingModel({
    required this.id,
    required this.tradeId,
    required this.quantity,
    required this.price,
    required this.bookedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tradeId': tradeId,
      'quantity': quantity,
      'price': price,
      'bookedAt': bookedAt,
    };
  }

  factory TradeBookingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TradeBookingModel(
      id: json['id'] as String,
      tradeId: json['tradeId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      bookedAt: json['bookedAt'] as String,
    );
  }

  TradeBookingModel copyWith({
    String? id,
    String? tradeId,
    int? quantity,
    double? price,
    String? bookedAt,
  }) {
    return TradeBookingModel(
      id: id ?? this.id,
      tradeId: tradeId ?? this.tradeId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }
}