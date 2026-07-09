// ignore_for_file: avoid_print

void printReceipt({
  required String cafeName,
  required String tableId,
  required List<Map<String, dynamic>> items,
  required double total,
  String? paymentMethod,
  String? orderId,
}) {
  // Mobile printing not yet implemented
  print('Print receipt for table $tableId (not implemented on mobile)');
}
