import 'package:flutter/material.dart';
import 'package:trade_desk/watchlist/widgets/watchlist_card.dart';

import 'models/watchlist_model.dart';
import 'services/watchlist_service.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final WatchlistService _watchlistService = WatchlistService();

  List<WatchlistModel> _watchlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      final items = await _watchlistService.getWatchlist();

      if (!mounted) return;

      setState(() {
        _watchlist = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load watchlist: $e'),
        ),
      );
    }
  }

  Future<void> _showAddWatchlistDialog() async {
    final item = await showDialog<WatchlistModel>(
      context: context,
      builder: (dialogContext) {
        return const _AddWatchlistDialog();
      },
    );

    if (item == null) return;

    await _watchlistService.addToWatchlist(item);

    if (!mounted) return;

    await _loadWatchlist();
  }

  Future<void> _showWatchlistMenu(
    WatchlistModel item,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(sheetContext).pop('edit');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text('Remove from Watchlist'),
                onTap: () {
                  Navigator.of(sheetContext).pop('delete');
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (action == 'edit') {
      await _showEditWatchlistDialog(item);
    } else if (action == 'delete') {
      await _watchlistService.deleteFromWatchlist(item.id);

      if (!mounted) return;

      await _loadWatchlist();
    }
  }

  Future<void> _showEditWatchlistDialog(
    WatchlistModel item,
  ) async {
    final updatedItem = await showDialog<WatchlistModel>(
      context: context,
      builder: (dialogContext) {
        return _EditWatchlistDialog(item: item);
      },
    );

    if (updatedItem == null) return;

    await _watchlistService.updateWatchlist(updatedItem);

    if (!mounted) return;

    await _loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            onPressed: _showAddWatchlistDialog,
            tooltip: 'Add to Watchlist',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _watchlist.isEmpty
              ? const Center(
                  child: Text(
                    'No stocks in watchlist',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _watchlist.length,
                  itemBuilder: (context, index) {
                    final item = _watchlist[index];

                    return WatchlistCard(
                      item: item,
                      onAddTradePressed: () {
                        // Add Trade functionality can be connected later.
                      },
                      onMorePressed: () {
                        _showWatchlistMenu(item);
                      },
                    );
                  },
                ),
    );
  }
}

// -----------------------------------------------------------------------------
// Add Watchlist Dialog
// -----------------------------------------------------------------------------

class _AddWatchlistDialog extends StatefulWidget {
  const _AddWatchlistDialog();

  @override
  State<_AddWatchlistDialog> createState() =>
      _AddWatchlistDialogState();
}

class _AddWatchlistDialogState
    extends State<_AddWatchlistDialog> {
  final TextEditingController _symbolController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final symbol = _symbolController.text.trim();

    if (symbol.isEmpty) return;

    final notes = _notesController.text.trim();

    Navigator.of(context).pop(
      WatchlistModel(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        symbol: symbol.toUpperCase(),
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Watchlist'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _symbolController,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Symbol',
                hintText: 'eg. RELIANCE',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Breakout setup',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Edit Watchlist Dialog
// -----------------------------------------------------------------------------

class _EditWatchlistDialog extends StatefulWidget {
  final WatchlistModel item;

  const _EditWatchlistDialog({
    required this.item,
  });

  @override
  State<_EditWatchlistDialog> createState() =>
      _EditWatchlistDialogState();
}

class _EditWatchlistDialogState
    extends State<_EditWatchlistDialog> {
  late final TextEditingController _symbolController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    _symbolController = TextEditingController(
      text: widget.item.symbol,
    );

    _notesController = TextEditingController(
      text: widget.item.notes ?? '',
    );
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final symbol = _symbolController.text.trim();

    if (symbol.isEmpty) return;

    final notes = _notesController.text.trim();

    Navigator.of(context).pop(
      widget.item.copyWith(
        symbol: symbol.toUpperCase(),
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Watchlist'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _symbolController,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Symbol',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}