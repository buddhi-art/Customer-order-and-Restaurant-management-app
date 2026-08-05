// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

/// Escape a string for safe interpolation into HTML text/attribute context.
/// Prevents XSS when order/menu data (item names, sizes, etc.) is rendered into
/// the receipt window.
String _esc(Object? value) {
  return (value ?? '')
      .toString()
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

class _PrintData {
  final String cafeName;
  final String tableId;
  final List<Map<String, dynamic>> items;
  final double total;
  final String? paymentMethod;
  final String? orderId;
  _PrintData(
    this.cafeName,
    this.tableId,
    this.items,
    this.total,
    this.paymentMethod,
    this.orderId,
  );
}

String _generateHtml(_PrintData data) {
  final itemsHtml = data.items
      .map((item) {
        final name = _esc(item['name']);
        final qty = (item['quantity'] as num?)?.toInt() ?? 1;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final size = item['size'];
        final lineTotal = price * qty;
        final sizeTag = size != null && size != 'Medium'
            ? ' <span style="color:#888;font-size:11px;">(${_esc(size)})</span>'
            : '';
        return '''
    <tr>
      <td style="padding:4px 0;">$qty x $name$sizeTag</td>
      <td style="padding:4px 0;text-align:right;">\$${lineTotal.toStringAsFixed(2)}</td>
    </tr>
  ''';
      })
      .join('\n');

  final safeCafeName = _esc(data.cafeName);
  final safeTableNumber = _esc(
    data.tableId.replaceAll('table_', '').toUpperCase(),
  );
  final safeOrderId = data.orderId != null
      ? _esc(data.orderId!.substring(0, 8))
      : '---';
  final safePaymentMethod = data.paymentMethod != null
      ? _esc(data.paymentMethod!.toUpperCase())
      : null;

  return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Receipt - Table $safeTableNumber</title>
  <style>
    @media print {
      body { margin: 0; padding: 0; }
      .no-print { display: none; }
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Courier New', Courier, monospace;
      background: #fff;
      color: #222;
      padding: 32px;
      display: flex;
      justify-content: center;
    }
    .receipt {
      max-width: 380px;
      width: 100%;
      border: 2px solid #222;
      border-radius: 16px;
      padding: 28px 24px;
      background: #fff;
      box-shadow: 6px 6px 0 #222;
    }
    .header {
      text-align: center;
      border-bottom: 2px dashed #222;
      padding-bottom: 16px;
      margin-bottom: 16px;
    }
    .header h1 { font-size: 24px; letter-spacing: 2px; }
    .header p { font-size: 12px; color: #555; margin-top: 4px; }
    .info {
      display: flex;
      justify-content: space-between;
      font-size: 13px;
      margin-bottom: 12px;
    }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    thead th {
      border-bottom: 1px solid #222;
      padding-bottom: 6px;
      text-align: left;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    thead th:last-child { text-align: right; }
    tbody td { vertical-align: top; }
    .total {
      border-top: 2px solid #222;
      margin-top: 12px;
      padding-top: 12px;
      display: flex;
      justify-content: space-between;
      font-size: 18px;
      font-weight: bold;
    }
    .payment {
      text-align: center;
      margin-top: 16px;
      padding-top: 12px;
      border-top: 1px dashed #ccc;
      font-size: 12px;
      color: #555;
    }
    .footer {
      text-align: center;
      margin-top: 16px;
      font-size: 11px;
      color: #888;
    }
  </style>
</head>
<body>
  <div class="receipt">
    <div class="header">
      <h1>$safeCafeName</h1>
      <p>कल्प • Since 2026</p>
    </div>
    <div class="info">
      <span><strong>Table:</strong> $safeTableNumber</span>
      <span><strong>#$safeOrderId</strong></span>
    </div>
    <table>
      <thead>
        <tr><th>Item</th><th style="text-align:right;">Amount</th></tr>
      </thead>
      <tbody>
        $itemsHtml
      </tbody>
    </table>
    <div class="total">
      <span>TOTAL</span>
      <span>\$${data.total.toStringAsFixed(2)}</span>
    </div>
    ${safePaymentMethod != null ? '<div class="payment">Paid via $safePaymentMethod</div>' : ''}
    <div class="footer">
      Thank you for visiting कल्प!<br>
      <button class="no-print" onclick="window.print()" style="margin-top:12px;padding:8px 24px;font-family:inherit;font-size:13px;border:2px solid #222;border-radius:8px;background:#fff;cursor:pointer;box-shadow:3px 3px 0 #222;">🖨 Print / Save PDF</button>
    </div>
  </div>
  <script>
    setTimeout(() => window.print(), 300);
  </script>
</body>
</html>
''';
}

Future<void> printReceipt({
  required String cafeName,
  required String tableId,
  required List<Map<String, dynamic>> items,
  required double total,
  String? paymentMethod,
  String? orderId,
}) async {
  final receiptHtml = await compute(
    _generateHtml,
    _PrintData(cafeName, tableId, items, total, paymentMethod, orderId),
  );

  final receiptDoc = web.window.open('', '_blank', 'width=500,height=700');
  if (receiptDoc != null) {
    final doc = receiptDoc.document;
    doc.open();
    doc.write(receiptHtml.toJS);
    doc.close();
  } else {
    throw Exception('Popup blocked. Please allow popups for this site to print receipts.');
  }
}
