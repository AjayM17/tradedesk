import 'package:flutter/material.dart';
import 'package:trade_desk/features/stocks/data/stock_service.dart';
import 'package:trade_desk/features/stocks/models/stock.dart';
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
  // Temporary limits (will come from Settings later)
  static const double maxInvestValue = 200000; // ₹2L
  static const double maxRiskValue = 5000; // ₹5k
  final _stockCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _entryCtrl = TextEditingController();
  final _slCtrl = TextEditingController();
  final _initSlCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  DateTime _tradeDate = DateTime.now();
  String _status = 'active';

  /// Stores FULL symbol internally (e.g. TCS.NS / TCS.BO)
  String? _selectedStock;

  // ───────── Calculations ─────────

  double get entry => double.tryParse(_entryCtrl.text) ?? 0;
  double get sl => double.tryParse(_slCtrl.text) ?? 0;
  int get qty => int.tryParse(_qtyCtrl.text) ?? 0;

  double get investment => entry * qty;
  double get riskValue => (entry - sl) * qty;
  double get riskPercent =>
      investment == 0 ? 0 : (riskValue / investment) * 100;

  bool get isSaveEnabled =>
      _selectedStock != null &&
      investment > 0 &&
      riskValue > 0 &&
      investment <= maxInvestValue &&
      riskValue <= maxRiskValue;

  bool _isSearching = false;
  bool _isSaving = false;
  bool get isEditMode => widget.trade != null;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Trade')),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _stockSearch(),
            _datePicker(),
            _statusDropdown(),

            _numberField(_entryCtrl, 'Entry Price'),
            _numberField(
              _slCtrl,
              'Stop Loss',
              onChanged: (v) => _initSlCtrl.text = v,
            ),
            _numberField(_initSlCtrl, 'Initial Stop Loss'),
            _numberField(_qtyCtrl, 'Quantity'),

            const SizedBox(height: 16),

            _infoRow('Investment', investment),
            _infoRow('Risk Value', riskValue),
            _infoRow('Risk %', riskPercent, isPercent: true),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isSaveEnabled && !_isSaving ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Trade'),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Widgets ─────────

  Widget _stockSearch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _stockCtrl,
        decoration: const InputDecoration(
          labelText: 'Stock Name',
          hintText: 'Enter stock name',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _selectedStock = value.trim().isEmpty ? null : value.trim();
          setState(() {});
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Stock name is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _stockSearchOld() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Autocomplete<Stock>(
        displayStringForOption: (s) => s.symbol.split('.').first,
        optionsBuilder: (TextEditingValue text) async {
          if (text.text.isEmpty) {
            return const <Stock>[];
          }

          setState(() => _isSearching = true);

          final results = await StockService.search(text.text);

          setState(() => _isSearching = false);

          return results;
        },
        onSelected: (stock) {
          setState(() {
            _selectedStock = stock.symbol;
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'Stock Name',
              hintText: 'Search & select stock',
              border: const OutlineInputBorder(),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              if (value != _selectedStock) {
                _selectedStock = null;
              }
              setState(() {});
            },
            validator: (_) =>
                _selectedStock == null ? 'Select stock from list' : null,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : options.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No results found'),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (_, i) {
                          final stock = options.elementAt(i);
                          return ListTile(
                            dense: true,
                            title: Text(stock.symbol.split('.').first),
                            subtitle: Text(
                              stock.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(stock),
                          );
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
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
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            setState(() => _tradeDate = picked);
          }
        },
      ),
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

  Widget _numberField(
    TextEditingController controller,
    String label, {
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) {
          onChanged?.call(v);
          setState(() {});
        },
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _infoRow(String label, double value, {bool isPercent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}${isPercent ? '%' : ''}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final tradeData = {
      'name': _selectedStock!.split('.').first,
      'symbol': _selectedStock!,
      'entryprice': entry,
      'stoploss': sl,
      'initial_stoploss': double.tryParse(_initSlCtrl.text) ?? sl,
      'quantity': qty,
      'status': _status,
      'trade_date':
          '${_tradeDate.year}-${_tradeDate.month.toString().padLeft(2, '0')}-${_tradeDate.day.toString().padLeft(2, '0')}',
    };

    try {
      if (isEditMode) {
        await TradeFirestoreService().updateTrade(widget.trade!.id, tradeData);
      } else {
        final trade = TradeDTO(
          name: _selectedStock!.split('.').first,
          symbol: _selectedStock!,
          entryPrice: entry,
          stopLoss: sl,
          initialStopLoss: double.tryParse(_initSlCtrl.text) ?? sl,
          quantity: qty,
          status: _status,
          tradeDate:
              '${_tradeDate.year}-${_tradeDate.month.toString().padLeft(2, '0')}-${_tradeDate.day.toString().padLeft(2, '0')}',
        );

        await TradeService.addTrade(trade);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Trade updated successfully'
                : 'Trade saved successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
