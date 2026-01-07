import 'package:flutter/material.dart';

import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/v2/r_booking_calculator.dart';
import 'package:trade_desk/features/trades/data/v2/trade_v2_executor.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';

class RBookingV2Dialog extends StatefulWidget {
  final TradeModel trade;

  const RBookingV2Dialog({super.key, required this.trade});

  @override
  State<RBookingV2Dialog> createState() => _RBookingV2DialogState();
}

class _RBookingV2DialogState extends State<RBookingV2Dialog> {
  late final int sellQty;
  late final double targetPrice;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();

    sellQty = RBookingCalculator.calculateQty(trade: widget.trade);
    targetPrice = widget.trade.entryPrice + widget.trade.rValue;

    _priceCtrl = TextEditingController(
      text: targetPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expectedProfit = sellQty * widget.trade.rValue;

    return AlertDialog(
      title: const Text('Confirm R1 Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('R1 Target Price', targetPrice),
          _kv('Quantity to Sell', sellQty),
          _kv('Expected Profit', '₹${expectedProfit.toStringAsFixed(0)}'),
          const Divider(),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Execution Price',
              helperText: 'Adjust only if filled differently',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirm,
          child: const Text('Confirm R1'),
        ),
      ],
    );
  }

  Future<void> _confirm() async {
    try {
      final execPrice = double.parse(_priceCtrl.text);

      final result = TradeV2Executor.executeRBooking(
        trade: widget.trade,
        executionPrice: execPrice,
      );

      await TradeFirestoreService().updateTradeFields(
        tradeId: widget.trade.tradeId!,
        fields: {
          'quantity': result.trade.quantity,
          'actions':
              result.trade.actions.map((a) => a.toMap()).toList(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _kv(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
