import 'package:trade_desk/features/trades/data/v2/trade_action_log.dart';

import '../models/trade_action_type.dart';
import '../models/trade_model.dart';

class TradeV2ActionValidator {
  static void validate({
    required TradeModel trade,
    required TradeActionType action,
  }) {
    final actions = trade.actions;

    // ───────── GLOBAL LIMIT ─────────
    if (actions.length >= 4) {
      throw Exception('Maximum 4 actions allowed');
    }

    final int rCount = actions
        .where((a) => a.kind == TradeActionKind.rBooking)
        .length;

    final int addOnCount = actions
        .where((a) => a.kind == TradeActionKind.addOn)
        .length;

    switch (action) {
      case TradeActionType.rBooking:
        _validateRBooking(actions, rCount, addOnCount);
        break;

      case TradeActionType.addOn:
        _validateAddOn(actions, rCount, addOnCount);
        break;
    }
  }

  // ───────── R BOOKING RULES ─────────
  static void _validateRBooking(
    List<TradeActionLog> actions,
    int rCount,
    int addOnCount,
  ) {
    if (rCount >= 2) {
      throw Exception('Maximum 2 R bookings allowed');
    }

    // R1 → no previous actions
    if (rCount == 0 && actions.isNotEmpty) {
      throw Exception('R1 must be the first action');
    }

    // R2 → must come after Add-On 1
    if (rCount == 1) {
      final last = actions.last;
      if (last.kind != TradeActionKind.addOn) {
        throw Exception('R2 allowed only after Add-On');
      }
    }
  }

  // ───────── ADD-ON RULES ─────────
  static void _validateAddOn(
    List<TradeActionLog> actions,
    int rCount,
    int addOnCount,
  ) {
    if (addOnCount >= 2) {
      throw Exception('Maximum 2 Add-Ons allowed');
    }

    // Add-On must always follow an R booking
    if (actions.isEmpty ||
        actions.last.kind != TradeActionKind.rBooking) {
      throw Exception('Add-On allowed only after R booking');
    }
  }
}
