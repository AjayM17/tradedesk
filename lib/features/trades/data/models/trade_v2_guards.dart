import '../models/trade_model.dart';
import '../v2/trade_action_log.dart';

/// V2 UI guards
/// PURELY derived from action history
/// Must match TradeV2ActionValidator exactly
extension TradeV2Guards on TradeModel {

  List<TradeActionLog> get _actions => actions;

  int get _rCount =>
      _actions.where((a) => a.kind == TradeActionKind.rBooking).length;

  int get _addOnCount =>
      _actions.where((a) => a.kind == TradeActionKind.addOn).length;

  /// ───────── GLOBAL LIMIT ─────────
  bool get isActionLimitReached => _actions.length >= 4;

  /// ───────── R BOOKING (R1 / R2) ─────────
  bool get canDoRBooking {
    if (isActionLimitReached) return false;
    if (_rCount >= 2) return false;

    // R1 → first action
    if (_rCount == 0) {
      return _actions.isEmpty;
    }

    // R2 → only after Add-On
    if (_rCount == 1) {
      return _actions.isNotEmpty &&
             _actions.last.kind == TradeActionKind.addOn;
    }

    return false;
  }

  /// ───────── ADD-ON ─────────
  bool get canDoAddOn {
    if (isActionLimitReached) return false;
    if (_addOnCount >= 2) return false;

    // Add-On only after R booking
    return _actions.isNotEmpty &&
           _actions.last.kind == TradeActionKind.rBooking;
  }
}
