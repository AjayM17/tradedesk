import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../settings/settings_service.dart';
import '../models/trade_model.dart';
import '../services/trade_rules_service.dart';
import '../services/trade_service.dart';

class AddTradePage extends StatefulWidget {
  final TradeModel? tradeToEdit;

  const AddTradePage({super.key, this.tradeToEdit});

  @override
  State<AddTradePage> createState() => _AddTradePageState();
}

class _AddTradePageState extends State<AddTradePage> {
  final SettingsService _settingsService = SettingsService();

  final TradeService _tradeService = TradeService();

  final TradeRulesService _tradeRulesService = TradeRulesService();

  late final TextEditingController _symbolController;
  late final TextEditingController _tradeDateController;
  late final TextEditingController _entryPriceController;
  late final TextEditingController _stopLossController;
  late final TextEditingController _initialSLController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _initialSLEditable = false;

  double _maxInvest = 300000;
  double _maxRisk = 15000;

  TradeRuleCheckResult? _ruleCheck;

  bool get isEditMode => widget.tradeToEdit != null;

  @override
  void initState() {
    super.initState();

    _symbolController = TextEditingController();

    _tradeDateController = TextEditingController();

    _entryPriceController = TextEditingController();

    _stopLossController = TextEditingController();

    _initialSLController = TextEditingController();

    _quantityController = TextEditingController();

    _notesController = TextEditingController();

    _initialize();
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _tradeDateController.dispose();
    _entryPriceController.dispose();
    _stopLossController.dispose();
    _initialSLController.dispose();
    _quantityController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // =========================================================
  // Initialization
  // =========================================================

  Future<void> _initialize() async {
    final settings = await _settingsService.getSettings();

    if (!mounted) {
      return;
    }

    _maxInvest = settings.maxInvestmentPerTrade;

    _maxRisk = settings.maxRiskPerTrade;

    if (widget.tradeToEdit != null) {
      _loadTradeForEdit(widget.tradeToEdit!);
    } else {
      _tradeDateController.text = _formatDate(DateTime.now());
    }

    setState(() {
      _isLoading = false;
    });

    await _updateRuleCheck();
  }

  void _loadTradeForEdit(TradeModel trade) {
    _symbolController.text = trade.symbol;

    _tradeDateController.text = trade.tradeDate;

    _entryPriceController.text = _formatNumber(trade.entryPrice);

    _stopLossController.text = _formatNumber(trade.stopLoss);

    _initialSLController.text = _formatNumber(trade.initialSL);

    _quantityController.text = trade.quantity.toString();

    _notesController.text = trade.notes ?? '';

    _initialSLEditable = false;
  }

  // =========================================================
  // Input values
  // =========================================================

  double? get _entryPrice {
    return double.tryParse(_entryPriceController.text);
  }

  double? get _stopLoss {
    return double.tryParse(_stopLossController.text);
  }

  double? get _initialSL {
    return double.tryParse(_initialSLController.text);
  }

  int? get _quantity {
    return int.tryParse(_quantityController.text);
  }

  // =========================================================
  // Quantity
  // =========================================================

  int _calculateQuantity() {
    final entryPrice = _entryPrice;
    final stopLoss = _stopLoss;

    if (entryPrice == null || stopLoss == null || entryPrice <= 0) {
      return 0;
    }

    final riskPerShare = entryPrice - stopLoss;

    // SL >= Buy:
    // This is a protected/profitable long trade.
    // Risk does not restrict quantity.
    if (riskPerShare <= 0) {
      return (_maxInvest / entryPrice).floor();
    }

    final quantityByRisk = (_maxRisk / riskPerShare).floor();

    final quantityByInvestment = (_maxInvest / entryPrice).floor();

    return quantityByRisk < quantityByInvestment
        ? quantityByRisk
        : quantityByInvestment;
  }

  void _onEntryPriceChange() {
    if (!isEditMode) {
      final quantity = _calculateQuantity();

      _quantityController.text = quantity.toString();
    }

    _updateRuleCheck();
  }

  void _onStopLossChange() {
    if (!isEditMode) {
      _initialSLController.text = _stopLossController.text;

      final quantity = _calculateQuantity();

      _quantityController.text = quantity.toString();
    }

    _updateRuleCheck();
  }

  void _onTradeDateChange() {
    _updateRuleCheck();
  }

  void _onQuantityChange() {
    _updateRuleCheck();
  }

  void _onInitialSLToggleChange(bool value) {
    setState(() {
      _initialSLEditable = value;

      if (!value && widget.tradeToEdit != null) {
        _initialSLController.text = _formatNumber(
          widget.tradeToEdit!.initialSL,
        );
      }
    });
  }

  // =========================================================
  // Calculations
  // =========================================================

  double get riskPercent {
    final entryPrice = _entryPrice;
    final stopLoss = _stopLoss;

    if (entryPrice == null || stopLoss == null || entryPrice <= 0) {
      return 0;
    }

    final riskPerShare = entryPrice - stopLoss;

    // SL >= Buy = zero risk
    if (riskPerShare <= 0) {
      return 0;
    }

    return (riskPerShare / entryPrice) * 100;
  }

  double get invest {
    final entryPrice = _entryPrice;
    final quantity = _quantity;

    if (entryPrice == null || quantity == null) {
      return 0;
    }

    return entryPrice * quantity;
  }

  double get riskValue {
    final entryPrice = _entryPrice;
    final stopLoss = _stopLoss;
    final quantity = _quantity;

    if (entryPrice == null || stopLoss == null || quantity == null) {
      return 0;
    }

    final riskPerShare = entryPrice - stopLoss;

    // SL >= Buy = zero risk
    if (riskPerShare <= 0) {
      return 0;
    }

    return riskPerShare * quantity;
  }

  // =========================================================
  // Validation
  // =========================================================

  bool get formIsValid {
    return _symbolController.text.trim().isNotEmpty &&
        _tradeDateController.text.trim().isNotEmpty &&
        _entryPrice != null &&
        _entryPrice! > 0 &&
        _stopLoss != null &&
        _stopLoss! > 0 &&
        _initialSL != null &&
        _initialSL! > 0 &&
        _quantity != null &&
        _quantity! > 0;
  }

  int get failedRuleCount {
    final ruleCheck = _ruleCheck;

    if (ruleCheck == null) {
      return 0;
    }

    return ruleCheck.results.where((result) => !result.passed).length;
  }

  bool get canSave {
    return formIsValid &&
        _ruleCheck != null &&
        _ruleCheck!.passed &&
        !_isSaving;
  }

  // =========================================================
  // Rule Check
  // =========================================================

  Future<void> _updateRuleCheck() async {
    final entryPrice = _entryPrice;
    final stopLoss = _stopLoss;
    final quantity = _quantity;
    final tradeDate = _tradeDateController.text.trim();

    if (entryPrice == null ||
        entryPrice <= 0 ||
        stopLoss == null ||
        stopLoss <= 0 ||
        quantity == null ||
        quantity <= 0 ||
        tradeDate.isEmpty) {
      if (mounted) {
        setState(() {
          _ruleCheck = null;
        });
      }

      return;
    }

    final previewTrade = TradeModel(
      id: widget.tradeToEdit?.id ?? 'preview-trade',
      symbol: _symbolController.text.trim().isEmpty
          ? 'Preview'
          : _symbolController.text.trim(),
      tradeDate: tradeDate,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      initialSL: _initialSL ?? stopLoss,
      quantity: quantity,
      status: TradeStatus.active,
      notes: _notesController.text.trim(),
    );

    final existingTrades = await _tradeService.getTrades();

    final result = await _tradeRulesService.checkTrade(
      previewTrade,
      existingTrades,
      excludeTradeId: widget.tradeToEdit?.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _ruleCheck = result;
    });
  }

  // =========================================================
  // Save
  // =========================================================

  Future<void> _saveTrade() async {
    if (!canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final trade = TradeModel(
      id: widget.tradeToEdit?.id ?? _generateId(),
      symbol: _symbolController.text.trim(),
      tradeDate: _tradeDateController.text,
      entryPrice: _entryPrice!,
      stopLoss: _stopLoss!,
      initialSL: _initialSL!,
      quantity: _quantity!,
      status: TradeStatus.active,
      notes: _notesController.text.trim(),
    );

    final existingTrades = await _tradeService.getTrades();

    // Final authoritative Rule Engine check.
    final finalRuleCheck = await _tradeRulesService.checkTrade(
      trade,
      existingTrades,
      excludeTradeId: widget.tradeToEdit?.id,
    );

    if (!finalRuleCheck.passed) {
      if (mounted) {
        setState(() {
          _ruleCheck = finalRuleCheck;
          _isSaving = false;
        });
      }

      await _showRuleFailure(finalRuleCheck.results);

      return;
    }

    if (isEditMode) {
      await _tradeService.updateTrade(trade);
    } else {
      await _tradeService.addTrade(trade);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(trade);
  }

  // =========================================================
  // Rule Failure
  // =========================================================

  Future<void> _showRuleFailure(List<TradeRuleResult> results) async {
    final failedRules = results.where((result) => !result.passed).toList();

    final message = failedRules
        .map((rule) => '${rule.label}: ${rule.message}')
        .join('\n\n');

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trade Not Allowed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Review Trade'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isEditMode ? 'Edit Trade' : 'Add Trade')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(isEditMode ? 'Edit Trade' : 'Add Trade'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForm(),

              const SizedBox(height: 4),

              Text(
                'Risk: ${riskPercent.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141A2E),
                ),
              ),

              const SizedBox(height: 14),

              _buildQuantityField(),

              _buildLimits(),

              if (_ruleCheck != null) _buildRuleCheck(),

              const SizedBox(height: 20),

              _buildCalculatedSection(),

              const SizedBox(height: 24),

              _buildNotes(),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: canSave ? _saveTrade : null,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditMode ? 'Update Trade' : 'Save Trade'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Form
  // =========================================================

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'Symbol',
          placeholder: 'Enter symbol',
          controller: _symbolController,
        ),

        _buildTextField(
          label: 'Trade Date',
          controller: _tradeDateController,
          readOnly: true,
          onTap: _selectTradeDate,
        ),

        _buildTextField(
          label: 'Entry Price',
          placeholder: 'Enter entry price',
          controller: _entryPriceController,
          number: true,
          onChanged: (_) {
            _onEntryPriceChange();
          },
        ),

        _buildTextField(
          label: 'Stop Loss',
          placeholder: 'Enter stop loss',
          controller: _stopLossController,
          number: true,
          onChanged: (_) {
            _onStopLossChange();
          },
        ),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Initial Stop Loss',
                controller: _initialSLController,
                number: true,
                readOnly: isEditMode && !_initialSLEditable,
              ),
            ),

            if (isEditMode)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Switch(
                  value: _initialSLEditable,
                  onChanged: _onInitialSLToggleChange,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildTextField(
            label: 'Quantity',
            placeholder: 'Enter quantity',
            controller: _quantityController,
            number: true,
            integer: true,
            onChanged: (_) {
              _onQuantityChange();
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Tooltip(
            message: 'Quantity is auto-calculated but can be edited',
            child: Text(
              'ⓘ',
              style: TextStyle(fontSize: 20, color: Color(0xFF74798A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    bool number = false,
    bool integer = false,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        keyboardType: number
            ? TextInputType.numberWithOptions(decimal: !integer)
            : TextInputType.text,
        inputFormatters: number
            ? [
                FilteringTextInputFormatter.allow(
                  integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
                ),
              ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          filled: true,
          fillColor: const Color(0xFFF0F0F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD4D4DA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD4D4DA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF141A2E)),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Limits
  // =========================================================

  Widget _buildLimits() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Max Investment: '
            '₹${_maxInvest.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF74798A)),
          ),
          const SizedBox(width: 8),
          const Text('|', style: TextStyle(color: Color(0xFF74798A))),
          const SizedBox(width: 8),
          Text(
            'Max Risk: '
            '₹${_maxRisk.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF74798A)),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Rule Check
  // =========================================================

  Widget _buildRuleCheck() {
    final ruleCheck = _ruleCheck!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4D4DA)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rule Check',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF141A2E),
                    ),
                  ),
                  Text(
                    failedRuleCount > 0
                        ? '$failedRuleCount Failed'
                        : 'All Passed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: failedRuleCount > 0
                          ? const Color(0xFFC6284A)
                          : const Color(0xFF21883B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E4)),
          ...ruleCheck.results.asMap().entries.map((entry) {
            final rule = entry.value;

            return _buildRuleRow(rule, entry.key > 0);
          }),
        ],
      ),
    );
  }

  Widget _buildRuleRow(TradeRuleResult rule, bool hasTopBorder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: rule.passed ? Colors.white : const Color(0xFFFFF8FA),
        border: hasTopBorder
            ? const Border(top: BorderSide(color: Color(0xFFEEEEF1)))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            rule.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 18,
            color: rule.passed
                ? const Color(0xFF21883B)
                : const Color(0xFFC6284A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.label,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rule.message,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: rule.passed
                        ? const Color(0xFF74798A)
                        : const Color(0xFFA33A53),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Calculated values
  // =========================================================

  Widget _buildCalculatedSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4D4DA)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildCalculatedRow('Investment', '₹${invest.toStringAsFixed(2)}'),
          _buildCalculatedRow(
            'Risk Amount',
            '₹${riskValue.toStringAsFixed(2)}',
            border: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedRow(
    String label,
    String value, {
    bool border = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: border
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE0E0E4))),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF666B7A)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF141A2E),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Notes
  // =========================================================

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Notes ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141A2E),
                  ),
                ),
                TextSpan(
                  text: '(Optional)',
                  style: TextStyle(fontSize: 13, color: Color(0xFF74798A)),
                ),
              ],
            ),
          ),
        ),
        _buildTextField(
          label: 'Notes',
          placeholder: 'Add notes about this trade...',
          controller: _notesController,
        ),
      ],
    );
  }

  // =========================================================
  // Date Picker
  // =========================================================

  Future<void> _selectTradeDate() async {
    final currentDate = _parseDate(_tradeDateController.text);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    _tradeDateController.text = _formatDate(selectedDate);

    await _updateRuleCheck();

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // Helpers
  // =========================================================

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('-');

    if (parts.length != 3) {
      return null;
    }

    try {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
