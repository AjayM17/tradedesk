import 'package:flutter/material.dart';

class AppPageLayout extends StatelessWidget {
  final Widget child;

  const AppPageLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760, // desktop/web max width
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: 16, // content spacing ONLY
          ),
          child: child,
        ),
      ),
    );
  }
}
