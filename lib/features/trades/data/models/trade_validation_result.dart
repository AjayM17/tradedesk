class TradeValidationResult {
  final bool isValid;
  final String? error;

  const TradeValidationResult.valid()
      : isValid = true,
        error = null;

  const TradeValidationResult.invalid(this.error)
      : isValid = false;
}
