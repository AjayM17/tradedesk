import '../models/trade_model.dart';
import 'trade_action_log.dart';

class TradeV2ExecutionResult {
  final TradeModel trade;
  final TradeActionLog actionLog;

  TradeV2ExecutionResult({
    required this.trade,
    required this.actionLog,
  });
}
