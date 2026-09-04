enum TradeStatus {
  waiting,
  active,
  completed,
}

class TradeModel {
  final String id;
  final String symbol;
  final String tradeDate;
  final double entryPrice;
  final double stopLoss;
  final double initialSL;
  final int quantity;
  final TradeStatus status;
  final String? completedAt;
  final String? notes;

  const TradeModel({
    required this.id,
    required this.symbol,
    required this.tradeDate,
    required this.entryPrice,
    required this.stopLoss,
    required this.initialSL,
    required this.quantity,
    required this.status,
    this.completedAt,
    this.notes,
  });

  TradeModel copyWith({
    String? id,
    String? symbol,
    String? tradeDate,
    double? entryPrice,
    double? stopLoss,
    double? initialSL,
    int? quantity,
    TradeStatus? status,
    String? completedAt,
    String? notes,
  }) {
    return TradeModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      tradeDate: tradeDate ?? this.tradeDate,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      initialSL: initialSL ?? this.initialSL,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'tradeDate': tradeDate,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'initialSL': initialSL,
      'quantity': quantity,
      'status': status.name,
      'completedAt': completedAt,
      'notes': notes,
    };
  }

  factory TradeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TradeModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      tradeDate: json['tradeDate'] as String,
      entryPrice: (json['entryPrice'] as num).toDouble(),
      stopLoss: (json['stopLoss'] as num).toDouble(),
      initialSL: (json['initialSL'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      status: TradeStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TradeStatus.waiting,
      ),
      completedAt: json['completedAt'] as String?,
      notes: json['notes'] as String?,
    );
  }
}