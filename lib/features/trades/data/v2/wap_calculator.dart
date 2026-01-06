class WapCalculator {

  static double calculate({
    required double currentQty,
    required double currentAvgPrice,
    required double addQty,
    required double addPrice,
  }) {
    final totalCost =
        (currentQty * currentAvgPrice) +
        (addQty * addPrice);

    final totalQty = currentQty + addQty;

    if (totalQty == 0) return currentAvgPrice;

    return totalCost / totalQty;
  }
}
