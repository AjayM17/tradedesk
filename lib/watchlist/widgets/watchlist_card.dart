import 'package:flutter/material.dart';

import '../../trades/widgets/chart_link_button.dart';
import '../models/watchlist_model.dart';

class WatchlistCard extends StatelessWidget {
  final WatchlistModel item;
  final VoidCallback? onAddTradePressed;
  final VoidCallback? onMorePressed;

  const WatchlistCard({
    super.key,
    required this.item,
    this.onAddTradePressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Symbol icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                item.symbol.isNotEmpty
                    ? item.symbol.substring(0, 1)
                    : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Symbol + notes
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.symbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (item.notes != null &&
                      item.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Chartink
            ChartLinkButton(
              symbol: item.symbol,
            ),

            const SizedBox(width: 4),

            // Add Trade
            // FilledButton.tonal(
            //   onPressed: onAddTradePressed,
            //   child: const Text('Add Trade'),
            // ),

            const SizedBox(width: 4),

            // More
            IconButton(
              onPressed: onMorePressed,
              tooltip: 'More',
              icon: const Icon(
                Icons.more_vert,
              ),
            ),
          ],
        ),
      ),
    );
  }
}