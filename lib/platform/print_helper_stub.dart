/// Stub implementation for non-web platforms.
void printReceipt({
  required String cafeName,
  required String tableId,
  required List<Map<String, dynamic>> items,
  required double total,
  String? paymentMethod,
}) {
  // No-op on non-web platforms
}
