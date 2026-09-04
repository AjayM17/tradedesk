import 'package:flutter/material.dart';

class CompleteTradePage extends StatefulWidget {
  final String tradeDate;

  const CompleteTradePage({
    super.key,
    required this.tradeDate,
  });

  @override
  State<CompleteTradePage> createState() =>
      _CompleteTradePageState();
}

class _CompleteTradePageState
    extends State<CompleteTradePage> {
  late String _selectedDate;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _selectedDate = _getToday();
  }

  String _getToday() {
    final today = DateTime.now();

    return '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  void _onCompletionDateChange(String value) {
    setState(() {
      _errorMessage = '';
      _selectedDate = value;
    });

    if (value.isEmpty) {
      return;
    }

    final today = _getToday();

    if (value.compareTo(widget.tradeDate) < 0) {
      setState(() {
        _errorMessage =
            'Completion date cannot be before ${widget.tradeDate}.';
      });
      return;
    }

    if (value.compareTo(today) > 0) {
      setState(() {
        _errorMessage =
            'Completion date cannot be after today.';
      });
    }
  }

  bool get _canComplete {
    if (_selectedDate.isEmpty) {
      return false;
    }

    if (_selectedDate.compareTo(widget.tradeDate) < 0) {
      return false;
    }

    if (_selectedDate.compareTo(_getToday()) > 0) {
      return false;
    }

    return true;
  }

  Future<void> _selectDate() async {
    final initialDate =
        DateTime.tryParse(_selectedDate) ?? DateTime.now();

    final firstDate =
        DateTime.tryParse(widget.tradeDate) ?? initialDate;

    final lastDate = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
              ? lastDate
              : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected == null) {
      return;
    }

    final value =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';

    _onCompletionDateChange(value);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _complete() {
    if (!_canComplete) {
      return;
    }

    Navigator.of(context).pop({
      'completedAt': _selectedDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        title: const Text('Complete Trade'),
        actions: [
          TextButton(
            onPressed: _canComplete ? _complete : null,
            child: const Text('Complete'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Completion Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDate.isEmpty
                      ? 'Select date'
                      : _selectedDate,
                ),
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 20),

            Text(
              'Trade Date: ${widget.tradeDate}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Today: ${_getToday()}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}