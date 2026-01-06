import '../models/trade_model.dart';
import '../v2/trade_action_log.dart';
import '../../presentation/models/trade_ui_model.dart';

class TradeFirestoreDto {
  final String id;
  final Map<String, dynamic> data;

  TradeFirestoreDto({required this.id, required this.data});

  TradeUiModel toUiModel() {
    final entry = (data['entryprice'] as num).toDouble();
    final sl = (data['stoploss'] as num).toDouble();
    final initSl = (data['initial_stoploss'] as num).toDouble();
    final qty = (data['quantity'] as num).toInt();

    final actions = (data['actions'] as List<dynamic>? ?? [])
        .map((e) => TradeActionLog.fromMap(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    final trade = TradeModel(
      tradeId: id,
      entryPrice: entry,
      stopLoss: sl,
      quantity: qty,
      initialStopLoss: initSl,
      rValue: (entry - initSl).abs(),
      actions: actions,
    );

    final tradeDate = DateTime.parse(data['trade_date']);

    return TradeUiModel(
      id: id,
      name: data['name'],
      status: TradeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TradeStatus.active,
      ),
      trade: trade,
      pnlValue: (sl - entry) * qty,
      pnlPercent:
          qty == 0 ? 0 : ((sl - entry) / entry) * 100,
      ageInDays: DateTime.now().difference(tradeDate).inDays,
      tradeDate: tradeDate,
    );
  }
}
