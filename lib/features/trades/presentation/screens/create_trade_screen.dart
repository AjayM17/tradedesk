import 'dart:math';
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
  final TradeUiModel? trade;
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
  bool get isEditMode => widget.trade != null;

  int _maxQtyByPortfolio = 0;

  // ───────── Parsed values ─────────
  double get entry => double.tryParse(_entryCtrl.text) ?? 0;
  double get sl => double.tryParse(_slCtrl.text) ?? 0;
  double get initialSl => double.tryParse(_initSlCtrl.text) ?? 0;
  int get qty => int.tryParse(_qtyCtrl.text) ?? 0;

  double get investment => entry * qty;

  double get riskPerShare {
    final r = entry - sl;
    return r > 0 ? r : 0;
  }

  double get riskValue => riskPerShare * qty;

  // ───────── Quantity rules ─────────
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

    final qtyValid = isEditMode
        ? qty <= max(maxQtyAllowed, widget.trade!.trade.quantity)
        : qty <= maxQtyAllowed;

    return qtyValid &&
        investment > 0 &&
        investment <= maxCapitalPerTrade &&
        riskValue <= maxRiskValue;
  }

  // ───────── Lifecycle ─────────
  @override
  void initState() {
    super.initState();
    updateInitialSl = !isEditMode;

    if (isEditMode) {
      final ui = widget.trade!;
      final t = ui.trade;

      _stockCtrl.text = ui.name;
      _selectedStock = ui.name;

      _entryCtrl.text = ui.buyPrice.toStringAsFixed(2);
      _slCtrl.text = t.stopLoss.toStringAsFixed(2);
      _initSlCtrl.text = t.initialStopLoss.toStringAsFixed(2);
      _qtyCtrl.text = t.quantity.toString();

      _tradeDate = ui.tradeDate;
      _status = ui.status.name;
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

  // ───────── Portfolio risk ─────────
  Future<void> _recalculatePortfolioQty() async {
    if (riskPerShare <= 0) {
      if (!mounted) return;
      setState(() => _maxQtyByPortfolio = maxQtyByCapital);
      return;
    }

    final activeTrades = await TradeService.getActiveTradeModels();
    if (!mounted) return;

    double usedRisk = 0;
    for (final t in activeTrades) {
      if (isEditMode && t.tradeId == widget.trade!.trade.tradeId) continue;
      usedRisk += t.totalRisk;
    }

    final maxPortfolioRisk = (totalCapital * maxPortfolioRiskPercent) / 100;

    final remainingRisk = maxPortfolioRisk - usedRisk;

    final int portfolioQty = remainingRisk > 0
        ? (remainingRisk / riskPerShare).floor()
        : 0;

    final int existingQty = isEditMode ? widget.trade!.trade.quantity : 0;

    setState(() {
      // ✅ KEY FIX
      _maxQtyByPortfolio = isEditMode
          ? max(portfolioQty, existingQty)
          : portfolioQty;
    });
  }

  void _onRiskInputsChanged() {
    if (entry > 0 && sl > 0 && entry > sl) {
      _recalculatePortfolioQty();
    } else {
      setState(() => _maxQtyByPortfolio = maxQtyByCapital);
    }
  }

  // ───────── Save ─────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Cache dependencies BEFORE await
    final settings = context.read<SettingsState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final resolvedInitialSl = updateInitialSl ? sl : initialSl;
    final rValue = (entry - resolvedInitialSl).abs();

    final trade = TradeModel(
      tradeId: isEditMode ? widget.trade!.trade.tradeId : null,
      entryPrice: entry,
      stopLoss: sl,
      quantity: qty,
      initialStopLoss: resolvedInitialSl,
      rValue: rValue,
    );

    final basic = TradeValidator.validateNewTrade(
      trade: trade,
      settings: settings,
    );

    if (!basic.isValid) {
      messenger.showSnackBar(SnackBar(content: Text(basic.error!)));
      return;
    }

    // ⏳ async
    final activeTrades = await TradeService.getActiveTradeModels();

    if (!mounted) return; // ✅ REQUIRED

    final portfolio = TradeValidator.validatePortfolioRisk(
      newTrade: trade,
      activeTrades: activeTrades,
      settings: settings,
      editingTradeId: isEditMode ? widget.trade!.trade.tradeId : null,
    );

    if (!portfolio.isValid) {
      messenger.showSnackBar(SnackBar(content: Text(portfolio.error!)));
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
        await TradeFirestoreService().updateTrade(tradeId: dto.id!, trade: dto);
      } else {
        await TradeService.addTrade(dto);
      }

      if (!mounted) return; // ✅ REQUIRED
      navigator.pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Trade' : 'Add Trade')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _stockField(),
            _datePicker(),
            _numberField(
              _entryCtrl,
              'Entry Price',
              onChanged: (_) => _onRiskInputsChanged(),
            ),
            _numberField(
              _slCtrl,
              'Stop Loss',
              onChanged: (v) {
                if (updateInitialSl) _initSlCtrl.text = v;
                _onRiskInputsChanged();
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
                  : const Text('Save Trade'),
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
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: 'Quantity (Max: $maxQtyAllowed)',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showQtyInfo,
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _showQtyInfo() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Max Quantity Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Capital limit: $maxQtyByCapital'),
            Text('Trade risk limit: $maxQtyByRisk'),
            Text('Portfolio risk limit: $_maxQtyByPortfolio'),
            const Divider(),
            Text(
              'Final allowed: $maxQtyAllowed',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _limitsInfo() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      'Max Invest: ₹${maxCapitalPerTrade.toStringAsFixed(0)}  |  '
      'Max Risk: ₹${maxRiskValue.toStringAsFixed(0)}',
      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
    ),
  );

  Widget _stockField() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: _stockCtrl,
      decoration: const InputDecoration(
        labelText: 'Stock Name',
        border: OutlineInputBorder(),
      ),
      onChanged: (v) {
        setState(() {
          _selectedStock = v.trim().isEmpty ? null : v.trim();
        });
      },
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    ),
  );

  Widget _datePicker() => ListTile(
    title: const Text('Trade Date'),
    subtitle: Text(
      '${_tradeDate.year}-${_tradeDate.month.toString().padLeft(2, '0')}-${_tradeDate.day.toString().padLeft(2, '0')}',
    ),
    trailing: const Icon(Icons.calendar_today),
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: _tradeDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (d != null) setState(() => _tradeDate = d);
    },
  );

  Widget _initialSlToggle() => SwitchListTile(
    title: const Text('Link Initial SL with SL'),
    value: updateInitialSl,
    onChanged: (v) {
      setState(() {
        updateInitialSl = v;
        if (v) _initSlCtrl.text = _slCtrl.text;
      });
    },
  );

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) => Padding(
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

  Widget _info(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      '$label: ${value.toStringAsFixed(2)}',
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
