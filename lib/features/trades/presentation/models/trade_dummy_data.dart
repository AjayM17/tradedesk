import 'trade_ui_model.dart';

final List<TradeUiModel> dummyTrades = [
  TradeUiModel(
    name: 'RELIANCE',
    status: TradeStatus.active,
    quantity: 100,
    partialQuantity: 25,
    investedAmount: 245000,
    pnlValue: 4500,
    pnlPercent: 3.2,
    buyPrice: 2450,
    stopLoss: 2300,
    initialStopLoss: 2200,
    oneRTarget: 1500,
    ageInDays: 12,
    isPartialProfitBooked: true,
  ),
  TradeUiModel(
    name: 'TCS',
    status: TradeStatus.free,
    quantity: 50,
    partialQuantity: 12,
    investedAmount: 180000,
    pnlValue: -3200,
    pnlPercent: -1.8,
    buyPrice: 3600,
    stopLoss: 3500,
    initialStopLoss: 3450,
    oneRTarget: 2000,
    ageInDays: 5,
    isPartialProfitBooked: false,
  ),
];
