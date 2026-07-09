import 'package:flutter_riverpod/flutter_riverpod.dart';

class TableNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTable(String? tableId) => state = tableId;
}

final tableProvider = NotifierProvider<TableNotifier, String?>(
  TableNotifier.new,
);
