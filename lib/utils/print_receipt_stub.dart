// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

Future<void> printReceipt({
  required String cafeName,
  required String tableId,
  required List<Map<String, dynamic>> items,
  required double total,
  String? paymentMethod,
  String? orderId,
}) async {
  // Receipt printing is only available on desktop web interfaces.
  toastification.show(
    title: const Text('Printing Not Supported'),
    description: const Text('Receipt printing is only available on desktop.'),
    type: ToastificationType.warning,
    style: ToastificationStyle.flatColored,
    autoCloseDuration: const Duration(seconds: 4),
  );
}
