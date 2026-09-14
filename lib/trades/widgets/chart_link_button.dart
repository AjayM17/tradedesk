import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChartLinkButton extends StatelessWidget {
  final String symbol;

  const ChartLinkButton({
    super.key,
    required this.symbol,
  });

  Future<void> _openChart() async {
    final cleanSymbol = symbol.trim();

    if (cleanSymbol.isEmpty) {
      return;
    }

    final uri = Uri.parse(
      'https://chartink.com/stocks/${Uri.encodeComponent(cleanSymbol)}.html',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched) {
        debugPrint('Could not open chart URL: $uri');
      }
    } catch (error) {
      debugPrint('Chart opening error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openChart,
      tooltip: 'Open Chartink chart',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.open_in_new,
        size: 18,
      ),
    );
  }
}