import 'package:flutter/material.dart';

import 'models/settings_model.dart';
import 'settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService =
      SettingsService();

  SettingsModel? _settings;

  bool _isLoading = true;
  bool _isSaving = false;

  late final TextEditingController
      _maxActiveTradesController;

  late final TextEditingController
      _maxTradesPerMonthController;

  late final TextEditingController
      _maxTradesPerThreeMonthsController;

  late final TextEditingController
      _maxRiskPerTradeController;

  late final TextEditingController
      _maxRiskPercentPerTradeController;

  late final TextEditingController
      _maxInvestmentPerTradeController;

  late final TextEditingController
      _totalInvestmentController;

  late final TextEditingController
      _maxPortfolioRiskPercentController;

  @override
  void initState() {
    super.initState();

    _maxActiveTradesController =
        TextEditingController();

    _maxTradesPerMonthController =
        TextEditingController();

    _maxTradesPerThreeMonthsController =
        TextEditingController();

    _maxRiskPerTradeController =
        TextEditingController();

    _maxRiskPercentPerTradeController =
        TextEditingController();

    _maxInvestmentPerTradeController =
        TextEditingController();

    _totalInvestmentController =
        TextEditingController();

    _maxPortfolioRiskPercentController =
        TextEditingController();

    _loadSettings();
  }

  @override
  void dispose() {
    _maxActiveTradesController.dispose();
    _maxTradesPerMonthController.dispose();
    _maxTradesPerThreeMonthsController.dispose();
    _maxRiskPerTradeController.dispose();
    _maxRiskPercentPerTradeController.dispose();
    _maxInvestmentPerTradeController.dispose();
    _totalInvestmentController.dispose();
    _maxPortfolioRiskPercentController.dispose();

    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings =
        await _settingsService.getSettings();

    if (!mounted) return;

    _setControllerValues(settings);

    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  void _setControllerValues(
    SettingsModel settings,
  ) {
    _maxActiveTradesController.text =
        settings.maxActiveTrades.toString();

    _maxTradesPerMonthController.text =
        settings.maxTradesPerMonth.toString();

    _maxTradesPerThreeMonthsController.text =
        settings.maxTradesPerThreeMonths.toString();

    _maxRiskPerTradeController.text =
        settings.maxRiskPerTrade.toString();

    _maxRiskPercentPerTradeController.text =
        settings.maxRiskPercentPerTrade.toString();

    _maxInvestmentPerTradeController.text =
        settings.maxInvestmentPerTrade.toString();

    _totalInvestmentController.text =
        settings.totalInvestment.toString();

    _maxPortfolioRiskPercentController.text =
        settings.maxPortfolioRiskPercent.toString();
  }

  SettingsModel? _buildSettingsFromFields() {
    final maxActiveTrades =
        int.tryParse(
      _maxActiveTradesController.text,
    );

    final maxTradesPerMonth =
        int.tryParse(
      _maxTradesPerMonthController.text,
    );

    final maxTradesPerThreeMonths =
        int.tryParse(
      _maxTradesPerThreeMonthsController.text,
    );

    final maxRiskPerTrade =
        double.tryParse(
      _maxRiskPerTradeController.text,
    );

    final maxRiskPercentPerTrade =
        double.tryParse(
      _maxRiskPercentPerTradeController.text,
    );

    final maxInvestmentPerTrade =
        double.tryParse(
      _maxInvestmentPerTradeController.text,
    );

    final totalInvestment =
        double.tryParse(
      _totalInvestmentController.text,
    );

    final maxPortfolioRiskPercent =
        double.tryParse(
      _maxPortfolioRiskPercentController.text,
    );

    if (maxActiveTrades == null ||
        maxTradesPerMonth == null ||
        maxTradesPerThreeMonths == null ||
        maxRiskPerTrade == null ||
        maxRiskPercentPerTrade == null ||
        maxInvestmentPerTrade == null ||
        totalInvestment == null ||
        maxPortfolioRiskPercent == null) {
      return null;
    }

    return SettingsModel(
      maxActiveTrades: maxActiveTrades,
      maxTradesPerMonth: maxTradesPerMonth,
      maxTradesPerThreeMonths:
          maxTradesPerThreeMonths,
      maxRiskPerTrade: maxRiskPerTrade,
      maxRiskPercentPerTrade:
          maxRiskPercentPerTrade,
      maxInvestmentPerTrade:
          maxInvestmentPerTrade,
      totalInvestment: totalInvestment,
      maxPortfolioRiskPercent:
          maxPortfolioRiskPercent,
    );
  }

  void _updateSettings() {
    final settings =
        _buildSettingsFromFields();

    if (settings == null) {
      return;
    }

    setState(() {
      _settings = settings;
    });
  }

  Future<void> _saveSettings() async {
    final settings =
        _buildSettingsFromFields();

    if (settings == null ||
        !settings.canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
      _settings = settings;
    });

    await _settingsService.saveSettings(
      settings,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 12,
      ),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        onChanged: (_) {
          _updateSettings();
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioRisk() {
    final settings = _settings;

    if (settings == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline,
        ),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Maximum Portfolio Risk',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
          Text(
            '₹${settings.maxPortfolioRisk.toStringAsFixed(0)}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final settings = _settings;

    if (settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: Text(
            'Unable to load settings',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 24),

              // Trade Limits

              _buildSectionTitle(
                'Trade Limits',
              ),

              _buildNumberField(
                label: 'Max Active Trades',
                controller:
                    _maxActiveTradesController,
              ),

              _buildNumberField(
                label: 'Max Trades per Month',
                controller:
                    _maxTradesPerMonthController,
              ),

              _buildNumberField(
                label:
                    'Max Trades per Quarter',
                controller:
                    _maxTradesPerThreeMonthsController,
              ),

              const SizedBox(height: 16),

              // Risk & Investment

              _buildSectionTitle(
                'Risk & Investment',
              ),

              _buildNumberField(
                label: 'Max Risk per Trade',
                controller:
                    _maxRiskPerTradeController,
              ),

              _buildNumberField(
                label:
                    'Max Risk Percentage per Trade (%)',
                controller:
                    _maxRiskPercentPerTradeController,
              ),

              _buildNumberField(
                label:
                    'Max Investment per Trade',
                controller:
                    _maxInvestmentPerTradeController,
              ),

              _buildNumberField(
                label:
                    'Total Investment Capital',
                controller:
                    _totalInvestmentController,
              ),

              _buildNumberField(
                label:
                    'Max Portfolio Risk (%)',
                controller:
                    _maxPortfolioRiskPercentController,
              ),

              _buildPortfolioRisk(),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed:
                      (_isSaving ||
                              !settings.canSave)
                          ? null
                          : _saveSettings,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Settings',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}