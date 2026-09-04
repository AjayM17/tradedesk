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

    return Align(
      alignment: Alignment.topCenter, // ✅ FIX
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 24, // left
            6,                  // top (minimal)
            isMobile ? 12 : 24, // right
            16,                 // bottom
          ),
          child: child,
        ),
      ),
    );
  }
}
