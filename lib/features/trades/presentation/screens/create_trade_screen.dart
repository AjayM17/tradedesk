import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;

import 'package:trade_desk/features/settings/data/settings_state.dart';
import 'package:trade_desk/features/trades/data/models/trade_dto.dart';
import 'package:trade_desk/features/trades/data/models/trade_model.dart';
import 'package:trade_desk/features/trades/data/models/trade_action_step.dart';
import 'package:trade_desk/features/trades/data/services/trade_firestore_service.dart';
import 'package:trade_desk/features/trades/data/services/trade_service.dart';
import 'package:trade_desk/features/trades/data/validators/trade_validator.dart';
import 'package:trade_desk/features/trades/presentation/models/trade_ui_model.dart';

class CreateTradeScreen extends StatefulWidget {
  final TradeUiModel? trade; // null = add, not null = edit
  const CreateTradeScreen({super.key, this.trade});

  @override
  State<CreateTradeScreen> createState() => _CreateTradeScreenState();
}

class _CreateTradeScreenState extends State<CreateTradeScreen> {
  // ───────── Settings ─────────
  double get maxCapitalPerTrade =>
      context.read<SettingsState>().maxCapitalPerStockAmount;

  double get maxRiskValue => context.read<SettingsState>().riskAmountPerTrade;

  double get totalCapital => context.read<SettingsState>().totalCapital;

  static const double maxPortfolioRiskPercent = 6.0;

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

  int _maxQtyByPortfolio = 0;

  bool get isEditMode => widget.trade != null;

  // ───────── Parsed values ─────────
  double get entry => double.tryParse(_entryCtrl.text) ?? 0.0;
  double get sl => double.tryParse(_slCtrl.text) ?? 0.0;
  double get initialSl => double.tryParse(_initSlCtrl.text) ?? 0.0;
  int get qty => int.tryParse(_qtyCtrl.text) ?? 0;

  double get investment => entry * qty;

  double get riskPerShare {
    final r = entry - sl;
    return r > 0 ? r : 0.0;
  }

  double get riskValue => riskPerShare * qty;

  // ───────── Quantity Rules ─────────
  int get maxQtyByCapital {
    if (entry <= 0) return 0;
    return (maxCapitalPerTrade / entry).floor();
  }

  int get maxQtyByRisk {
    if (riskPerShare <= 0) return maxQtyByCapital;
    return (maxRiskValue / riskPerShare).floor();
  }

  int get maxQtyAllowed {
    return max(0, min(maxQtyByCapital, min(maxQtyByRisk, _maxQtyByPortfolio)));
  }

  bool get isSaveEnabled {
    if (_selectedStock == null || qty <= 0) return false;

    final bool qtyValid = isEditMode
        ? qty <= max(maxQtyAllowed, widget.trade!.trade.quantity)
        : qty <= maxQtyAllowed;

    return qtyValid &&
        investment > 0 &&
        investment <= maxCapitalPerTrade &&
        riskValue <= maxRiskValue;
  }

  @override
  void initState() {
    super.initState();

    updateInitialSl = !isEditMode;

    if (isEditMode) {
      final ui = widget.trade!;
      final domain = ui.trade;

      _stockCtrl.text = ui.name;
      _selectedStock = ui.name;

      _entryCtrl.text = ui.buyPrice.toStringAsFixed(2);
      _slCtrl.text = domain.stopLoss.toStringAsFixed(2);
      _initSlCtrl.text = domain.initialStopLoss.toStringAsFixed(2);
      _qtyCtrl.text = domain.quantity.toString();

      _status = ui.status.name;
      _tradeDate = ui.tradeDate;
    }

    _recalculatePortfolioQty();
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

  // ───────── Portfolio Risk ─────────
  Future<void> _recalculatePortfolioQty() async {
    if (riskPerShare <= 0) {
      setState(() => _maxQtyByPortfolio = maxQtyByCapital);
      return;
    }

    final activeTrades = await TradeService.getActiveTradeModels();

    double usedRisk = 0;
    for (final t in activeTrades) {
      if (isEditMode && t.tradeId == widget.trade!.trade.tradeId) continue;
      usedRisk += t.totalRisk;
    }

    final maxPortfolioRisk = (totalCapital * maxPortfolioRiskPercent) / 100;

    final remainingRisk = maxPortfolioRisk - usedRisk;

    setState(() {
      _maxQtyByPortfolio = remainingRisk > 0
          ? (remainingRisk / riskPerShare).floor()
          : 0;
    });
  }

  // ───────── SAVE ─────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);

    final resolvedInitialSl = updateInitialSl ? sl : initialSl;
    final rValue = (entry - resolvedInitialSl).abs();

    final trade = TradeModel(
      tradeId: isEditMode ? widget.trade!.trade.tradeId : null,
      entryPrice: entry,
      stopLoss: sl,
      quantity: qty,
      initialStopLoss: resolvedInitialSl,
      rValue: rValue,
      // actions default to []
    );

    final basicResult = TradeValidator.validateNewTrade(
      trade: trade,
      settings: context.read<SettingsState>(),
    );

    if (!basicResult.isValid) {
      messenger.showSnackBar(SnackBar(content: Text(basicResult.error!)));
      return;
    }

    final activeTrades = await TradeService.getActiveTradeModels();

    final portfolioResult = TradeValidator.validatePortfolioRisk(
      newTrade: trade,
      activeTrades: activeTrades,
      settings: context.read<SettingsState>(),
      editingTradeId: isEditMode ? widget.trade!.trade.tradeId : null,
    );

    if (!portfolioResult.isValid) {
      messenger.showSnackBar(SnackBar(content: Text(portfolioResult.error!)));
      return;
    }

    setState(() => _isSaving = true);

    final dto = TradeDTO(
      id: isEditMode ? widget.trade!.trade.tradeId : null,
      name: _selectedStock!.split('.').first,
      symbol: _selectedStock!,
      entryPrice: entry,
      stopLoss: sl,
      initialStopLoss: resolvedInitialSl,
      quantity: qty,
      status: _status,
      tradeDate:
          '${_tradeDate.year}-${_tradeDate.month.toString().padLeft(2, '0')}-${_tradeDate.day.toString().padLeft(2, '0')}',
    );

    try {
      if (isEditMode) {
        await TradeFirestoreService().updateTrade(
          tradeId: widget.trade!.trade.tradeId!,
          trade: dto,
        );
      } else {
        await TradeService.addTrade(dto);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Trade' : 'Add Trade')),
      body: Form(
        key: _formKey,
        onChanged: () {
          _recalculatePortfolioQty();
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _stockField(),
            _datePicker(),
            _numberField(_entryCtrl, 'Entry Price'),
            _numberField(
              _slCtrl,
              'Stop Loss',
              onChanged: (v) {
                if (updateInitialSl) _initSlCtrl.text = v;
              },
            ),
            _initialSlToggle(),
            _numberField(
              _initSlCtrl,
              'Initial Stop Loss',
              enabled: updateInitialSl,
            ),
            _quantityField(),
            _limitsInfo(),
            _info('Investment', investment),
            _info('Risk Value', riskValue),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaveEnabled && !_isSaving ? _save : null,
              child: _isSaving
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Text(isEditMode ? 'Update Trade' : 'Save Trade'),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Widgets ─────────

  Widget _quantityField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _qtyCtrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Quantity (Max: $maxQtyAllowed)',
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _limitsInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Max Invest: ₹${maxCapitalPerTrade.toStringAsFixed(0)}  |  '
        'Max Risk: ₹${maxRiskValue.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }

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
        if (picked != null) setState(() => _tradeDate = picked);
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
          if (v) _initSlCtrl.text = _slCtrl.text;
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
}
