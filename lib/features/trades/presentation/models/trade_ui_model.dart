import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/v2/trade_action_log.dart';

enum TradeStatus { active, free, closed }

class TradeUiModel {
  final String id;
  final String name;
  final TradeStatus status;
  final TradeModel trade;

  final double pnlValue;
  final double pnlPercent;
  final int ageInDays;
  final DateTime tradeDate;

  const TradeUiModel({
    required this.id,
    required this.name,
    required this.status,
    required this.trade,
    required this.pnlValue,
    required this.pnlPercent,
    required this.ageInDays,
    required this.tradeDate,
  });

  int get quantity => trade.quantity;
  double get buyPrice => trade.entryPrice;
  double get stopLoss => trade.stopLoss;
  double get initialStopLoss => trade.initialStopLoss;

  double get investedAmount =>
      trade.entryPrice * trade.quantity;

  List<TradeActionLog> get actions => trade.actions;

  bool get isLocked => trade.actions.length >= 4;
}
