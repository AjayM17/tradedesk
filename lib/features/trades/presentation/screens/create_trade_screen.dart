import 'package:flutter/material.dart';
import 'package:trade_desk/features/trades/data/models/trade_dto.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/services/trade_service.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart';

class CreateTradeScreen extends StatefulWidget {
  final TradeUiModel? trade; // null = create, not null = edit
  const CreateTradeScreen({super.key, this.trade});

  @override
  State<CreateTradeScreen> createState() => _CreateTradeScreenState();
}

class _CreateTradeScreenState extends State<CreateTradeScreen> {
  // Limits (later from settings)
  static const double maxInvestValue = 200000;
  static const double maxRiskValue = 5000;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _stockCtrl = TextEditingController();
  final _entryCtrl = TextEditingController();
  final _slCtrl = TextEditingController();
  final _initSlCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  DateTime _tradeDate = DateTime.now();
  String _status = 'active';
  String? _selectedStock;

  bool _isSaving = false;
  bool updateInitialSl = false;

  // Original values (edit mode)
  late double _oEntry;
  late double _oSl;
  late double _oInitSl;
  late int _oQty;

  bool get isEditMode => widget.trade != null;

  // ───────── Calculations ─────────
  double get entry => double.tryParse(_entryCtrl.text) ?? 0;
  double get sl => double.tryParse(_slCtrl.text) ?? 0;
  double get initialSl => double.tryParse(_initSlCtrl.text) ?? 0;
  int get qty => int.tryParse(_qtyCtrl.text) ?? 0;

  double get investment => entry * qty;
  double get riskValue => (entry - sl).abs() * qty;

  bool get isSaveEnabled =>
      _selectedStock != null &&
      investment > 0 &&
      riskValue > 0 &&
      investment <= maxInvestValue &&
      riskValue <= maxRiskValue;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final t = widget.trade!;

      _stockCtrl.text = t.name;
      _selectedStock = t.name;

      _entryCtrl.text = t.buyPrice.toStringAsFixed(2);
      _slCtrl.text = t.stopLoss.toStringAsFixed(2);
      _initSlCtrl.text = t.initialStopLoss.toStringAsFixed(2);
      _qtyCtrl.text = t.quantity.toString();

      _status = t.status.name;
      _tradeDate = t.tradeDate;

      // Store originals
      _oEntry = t.buyPrice;
      _oSl = t.stopLoss;
      _oInitSl = t.initialStopLoss;
      _oQty = t.quantity;
    }
  }

  @override
  void dispose() {
    _stockCtrl.dispose();
    _entryCtrl.dispose();
    _slCtrl.dispose();
    _initSlCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Trade' : 'Add Trade'),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _stockField(),
            _datePicker(),
            _statusDropdown(),

            _numberField(_entryCtrl, 'Entry Price'),
            _numberField(_slCtrl, 'Stop Loss'),

            _initialSlToggle(),
            _numberField(
              _initSlCtrl,
              'Initial Stop Loss',
              enabled: updateInitialSl,
            ),

            _numberField(_qtyCtrl, 'Quantity'),

            const SizedBox(height: 16),
            _info('Investment', investment),
            _info('Risk Value', riskValue),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaveEnabled && !_isSaving ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditMode ? 'Update Trade' : 'Save Trade'),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Widgets ─────────

  Widget _stockField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _stockCtrl,
        decoration: const InputDecoration(
          labelText: 'Stock Name',
          border: OutlineInputBorder(),
        ),
        onChanged: (v) {
          _selectedStock = v.trim().isEmpty ? null : v.trim();
          setState(() {});
        },
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _datePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Trade Date'),
      subtitle: Text(
        '${_tradeDate.year}-${_tradeDate.month.toString().padLeft(2, '0')}-${_tradeDate.day.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _tradeDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _tradeDate = picked);
        }
      },
    );
  }

  Widget _statusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _status,
        items: const [
          DropdownMenuItem(value: 'active', child: Text('Active')),
          DropdownMenuItem(value: 'waiting', child: Text('Waiting')),
          DropdownMenuItem(value: 'completed', child: Text('Completed')),
        ],
        onChanged: (v) => setState(() => _status = v!),
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _initialSlToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Update Initial Stop Loss'),
      value: updateInitialSl,
      onChanged: (v) {
        setState(() => updateInitialSl = v);
      },
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _info(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // ───────── SAVE LOGIC ─────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final bool hasR1 = widget.trade?.r1 != null;

    final bool breakingChange = hasR1 &&
        (entry != _oEntry ||
            sl != _oSl ||
            qty != _oQty ||
            (updateInitialSl && initialSl != _oInitSl));

    if (breakingChange) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('R1 will be cleared'),
          content: const Text(
            'You changed trade parameters that affect R1.\n\n'
            'Continuing will clear R1 execution.\n\n'
            'Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isSaving = true);

    final dto = TradeDTO(
      name: _selectedStock!.split('.').first,
      symbol: _selectedStock!,
      entryPrice: entry,
      stopLoss: sl,
      initialStopLoss: initialSl,
      quantity: qty,
      status: _status,
      tradeDate:
          '${_tradeDate.year}-${_tradeDate.month.toString().padLeft(2, '0')}-${_tradeDate.day.toString().padLeft(2, '0')}',
    );

    try {
      if (isEditMode) {
        await TradeFirestoreService().updateTrade(
          tradeId: widget.trade!.id,
          trade: dto,
          clearR1: breakingChange,
        );
      } else {
        await TradeService.addTrade(dto);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
