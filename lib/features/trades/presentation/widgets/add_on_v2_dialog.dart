import 'package:flutter/material.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/v2/trade_v2_executor.dart';
import 'package:trade_desk/features/trades/data/validators/trade_v2_action_validator.dart';
import '../../data/models/trade_model.dart';

class AddOnV2Dialog extends StatefulWidget {
  final TradeModel trade;
  final int maxAddOnQty;

  const AddOnV2Dialog({
    super.key,
    required this.trade,
    required this.maxAddOnQty,
  });

  @override
  State<AddOnV2Dialog> createState() => _AddOnV2DialogState();
}

class _AddOnV2DialogState extends State<AddOnV2Dialog> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;

  int? _calculatedMaxQty;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController();
    _qtyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  // ───────── CALCULATE MAX QTY ─────────
  void _calculateMaxQty() {
    final double? price = double.tryParse(_priceCtrl.text);
    if (price == null || price <= 0) {
      _showError('Enter a valid Add-On price');
      return;
    }

    final int existingQty = widget.trade.quantity;
    final double entry = widget.trade.entryPrice;
    final double sl = widget.trade.stopLoss;

    // 10% safety boundary
    final double maxAllowedWap = sl / 1.10;

    // Very safe price → allow full cap
    if (price <= maxAllowedWap) {
      _calculatedMaxQty = widget.maxAddOnQty;
      _qtyCtrl.text = _calculatedMaxQty.toString();
      setState(() {});
      return;
    }

    final double numerator =
        (maxAllowedWap - entry) * existingQty;
    final double denominator =
        price - maxAllowedWap;

    if (denominator <= 0) {
      _showError('Add-On not allowed at this price');
      return;
    }

    final int maxQty = (numerator / denominator).floor();

    if (maxQty <= 0) {
      _showError('Add-On not allowed at this price');
      return;
    }

    _calculatedMaxQty =
        maxQty.clamp(1, widget.maxAddOnQty);
    _qtyCtrl.text = _calculatedMaxQty.toString();
    setState(() {});
  }

  // ───────── CONFIRM ─────────
  Future<void> _confirm() async {
    try {
      final double price = double.parse(_priceCtrl.text);
      final int qty = int.parse(_qtyCtrl.text);

      final int allowedMax =
          _calculatedMaxQty ?? widget.maxAddOnQty;

      if (qty <= 0 || qty > allowedMax) {
        _showError(
          'Maximum allowed quantity at this price is $allowedMax',
        );
        return;
      }

      // Final safety validation (authoritative)
      final result =
          TradeV2ActionValidator.validateAddOnConfirm(
        trade: widget.trade,
        addOnPrice: price,
        addOnQuantity: qty,
      );

      if (!result.isAllowed) {
        _showError(result.reason!);
        return;
      }

      final execResult = TradeV2Executor.executeAddOn(
        trade: widget.trade,
        quantity: qty,
        price: price,
      );

      await TradeFirestoreService().updateTradeFields(
        tradeId: widget.trade.tradeId!,
        fields: {
          'quantity': execResult.trade.quantity,
          'actions': execResult.trade.actions
              .map((a) => a.toMap())
              .toList(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add-On not allowed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add-On Position'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ───────── PRICE ─────────
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Add-On Price',
            ),
          ),

          const SizedBox(height: 14),

          // ───────── CALCULATE BUTTON (ALIGNED) ─────────
          ElevatedButton(
            onPressed: _calculateMaxQty,
            child: const Text('Calculate Max Quantity'),
          ),

          const SizedBox(height: 14),

          // ───────── QTY ─────────
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _calculatedMaxQty == null
                  ? 'Quantity'
                  : 'Quantity (Max $_calculatedMaxQty)',
              helperText:
                  'You may reduce quantity if needed',
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
          child: const Text('Confirm Add-On'),
        ),
      ],
    );
  }
}
