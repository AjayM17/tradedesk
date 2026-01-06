import 'package:flutter/material.dart';
import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/models/trade_action_type.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/v2/trade_v2_executor.dart';

class AddOnV2Dialog extends StatefulWidget {
  final TradeModel trade;

  const AddOnV2Dialog({
    super.key,
    required this.trade,
  });

  @override
  State<AddOnV2Dialog> createState() => _AddOnV2DialogState();
}

class _AddOnV2DialogState extends State<AddOnV2Dialog> {
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Add-On'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(_qtyCtrl, 'Quantity'),
          _field(_priceCtrl, 'Add Price'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _confirmAddOn,
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _confirmAddOn() async {
    try {
      final int qty = int.parse(_qtyCtrl.text);
      final double price = double.parse(_priceCtrl.text);

      // 1️⃣ Execute V2 domain logic
      final result = TradeV2Executor.execute(
        trade: widget.trade,
        action: TradeActionType.addOn,
        addQty: qty,
        addPrice: price,
      );

      // 2️⃣ Persist UPDATED trade (quantity + actions)
      await TradeFirestoreService().updateTradeFields(
        tradeId: widget.trade.tradeId!,
        fields: {
          'quantity': result.trade.quantity,
          'actions': result.trade.actions.map((a) => a.toMap()).toList(),
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

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
