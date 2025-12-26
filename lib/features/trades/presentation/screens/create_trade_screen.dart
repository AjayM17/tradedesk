import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:trade_desk/features/settings/data/settings_state.dart';
import 'package:trade_desk/features/trades/data/models/trade_dto.dart';
import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/services/trade_service.dart';
import 'package:trade_desk/features/trades/data/validators/trade_validator.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart';

class CreateTradeScreen extends StatefulWidget {
  final TradeUiModel? trade; // null = create, not null = edit
  const CreateTradeScreen({super.key, this.trade});

  @override
  State<CreateTradeScreen> createState() => _CreateTradeScreenState();
}

class _CreateTradeScreenState extends State<CreateTradeScreen> {
  // ───────── Settings-based limits ─────────
  double get maxCapitalPerTrade =>
      context.read<SettingsState>().maxCapitalPerStockAmount;

  double get maxRiskValue =>
      context.read<SettingsState>().riskAmountPerTrade;

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

  /// Toggle = link Initial SL with SL
  bool updateInitialSl = false;

  // Original values (edit mode)
  late double _oEntry;
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
      investment <= maxCapitalPerTrade &&
      riskValue <= maxRiskValue;

  @override
  void initState() {
    super.initState();

    // ✅ Default toggle behavior
    updateInitialSl = !isEditMode; // add=true, edit=false

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
      _oInitSl = t.initialStopLoss;
      _oQty = t.quantity;
    } else {
      // Add trade → sync Initial SL with SL once user enters SL
      _initSlCtrl.text = _slCtrl.text;
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
      appBar: AppBar(title: Text(isEditMode ? 'Edit Trade' : 'Add Trade')),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _stockField(),
            _datePicker(),

            _numberField(_entryCtrl, 'Entry Price'),

            // SL field (master)
            _numberField(
              _slCtrl,
              'Stop Loss',
              onChanged: (v) {
                if (updateInitialSl) {
                  _initSlCtrl.text = v; // SL → Initial SL
                }
              },
            ),

            _initialSlToggle(),

            _numberField(
              _initSlCtrl,
              'Initial Stop Loss',
              enabled: updateInitialSl, // ✅ editable ONLY when toggle ON
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
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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

  Widget _initialSlToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Link Initial SL with SL'),
      value: updateInitialSl,
      onChanged: (v) {
        setState(() {
          updateInitialSl = v;

          if (v) {
            _initSlCtrl.text = _slCtrl.text; // one-time sync
          }
        });
      },
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
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

    final settings = context.read<SettingsState>();
    final messenger = ScaffoldMessenger.of(context);

    final bool hasR1 = widget.trade?.r1 != null;

    final bool breakingChange =
        hasR1 &&
        (entry != _oEntry ||
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

    final trade = TradeModel(entryPrice: entry, stopLoss: sl, quantity: qty);

    final basicResult = TradeValidator.validateNewTrade(
      trade: trade,
      settings: settings,
    );

    if (!basicResult.isValid) {
      messenger.showSnackBar(SnackBar(content: Text(basicResult.error!)));
      return;
    }

    final activeTrades = await TradeService.getActiveTradeModels();

    final portfolioResult = TradeValidator.validatePortfolioRisk(
      newTrade: trade,
      activeTrades: activeTrades,
      settings: settings,
    );

    if (!portfolioResult.isValid) {
      messenger.showSnackBar(SnackBar(content: Text(portfolioResult.error!)));
      return;
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
