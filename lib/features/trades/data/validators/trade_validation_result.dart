class TradeAddOnValidationResult {
  final bool isAllowed;
  final String? reason;

  const TradeAddOnValidationResult.allowed()
      : isAllowed = true,
        reason = null;

  const TradeAddOnValidationResult.denied(this.reason)
      : isAllowed = false;
}
