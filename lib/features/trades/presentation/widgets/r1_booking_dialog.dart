import 'package:flutter/material.dart';
import 'package:trade_desk/features/trades/data/models/r1_booking.dart';
import '../models/trade_ui_model.dart';

class R1BookingDialog extends StatefulWidget {
  final TradeUiModel trade;

  const R1BookingDialog({super.key, required this.trade});

  @override
  State<R1BookingDialog> createState() => _R1BookingDialogState();
}

class _R1BookingDialogState extends State<R1BookingDialog> {
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;

  late double _defaultTargetPrice;
  late int _defaultQty;

  @override
  void initState() {
    super.initState();

    _defaultTargetPrice =
        widget.trade.buyPrice + widget.trade.oneRTarget;

    _defaultQty = (widget.trade.quantity * 0.25).floor();

    _priceCtrl = TextEditingController(
      text: _defaultTargetPrice.toStringAsFixed(2),
    );
    _qtyCtrl = TextEditingController(
      text: _defaultQty.toString(),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book R1'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Sell Price',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              helperText: 'Default: 25% of total quantity',
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
          onPressed: _onSave,
          child: const Text('Book R1'),
        ),
      ],
    );
  }

  void _onSave() {
    final double? sellPrice =
        double.tryParse(_priceCtrl.text);
    final int? qty =
        int.tryParse(_qtyCtrl.text);

    if (sellPrice == null || qty == null || qty <= 0) {
      return;
    }

    if (qty >= widget.trade.quantity) {
      return;
    }

    final double profit =
        (sellPrice - widget.trade.buyPrice) * qty;

    final r1 = R1Booking(
      sellPrice: sellPrice,
      quantity: qty,
      profit: profit,
      bookedAt: DateTime.now(),
    );

    Navigator.pop(context, r1);
  }
}
