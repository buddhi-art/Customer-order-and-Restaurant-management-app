import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/m3_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import '../../utils/security_layer.dart';
import 'admin_shell.dart';

class TableManagementScreen extends ConsumerStatefulWidget {
  const TableManagementScreen({super.key});

  @override
  ConsumerState<TableManagementScreen> createState() =>
      _TableManagementScreenState();
}

class _TableManagementScreenState extends ConsumerState<TableManagementScreen> {
  final List<_TableData> _tables = List.generate(8, (i) {
    return _TableData(number: i + 1);
  });

  void _addTable() {
    setState(() {
      _tables.add(_TableData(number: _tables.length + 1));
    });
  }

  void _removeTable(int index) {
    setState(() {
      _tables.removeAt(index);
    });
  }

  Set<int> _occupiedTables(List<AppOrder> orders) {
    final occupied = <int>{};
    for (final o in orders) {
      if (o.status != OrderStatus.paid) {
        final num = int.tryParse(o.tableId.replaceAll(RegExp(r'[^0-9]'), ''));
        if (num != null) occupied.add(num);
      }
    }
    return occupied;
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final occupied = _occupiedTables(orders);
    final colorScheme = Theme.of(context).colorScheme;

    return AdminShell(
      title: 'Tables',
      selectedIndex: 3,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTable,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryPill(
                  label: 'Total',
                  value: '${_tables.length}',
                  color: colorScheme.primary,
                ),
                _SummaryPill(
                  label: 'Occupied',
                  value: '${occupied.length}',
                  color: CafeColors.warning,
                ),
                _SummaryPill(
                  label: 'Available',
                  value: '${_tables.length - occupied.length}',
                  color: CafeColors.success,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Table grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 260,
                ),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  final table = _tables[index];
                  final isOccupied = occupied.contains(table.number);
                  // Find active order for this table
                  final tableOrders = orders.where((o) {
                    final num = int.tryParse(
                      o.tableId.replaceAll(RegExp(r'[^0-9]'), ''),
                    );
                    return num == table.number && o.status != OrderStatus.paid;
                  }).toList();

                  return _TableCard(
                    tableNumber: table.number,
                    isOccupied: isOccupied,
                    activeOrders: tableOrders.length,
                    orderTotal: tableOrders.fold<double>(
                      0,
                      (s, o) => s + o.totalAmount,
                    ),
                    onDownloadQr: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('QR for Table ${table.number} saved'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onDelete: _tables.length > 1
                        ? () => _removeTable(index)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableData {
  final int number;
  _TableData({required this.number});
}

class _TableCard extends StatelessWidget {
  final int tableNumber;
  final bool isOccupied;
  final int activeOrders;
  final double orderTotal;
  final VoidCallback onDownloadQr;
  final VoidCallback? onDelete;

  const _TableCard({
    required this.tableNumber,
    required this.isOccupied,
    required this.activeOrders,
    required this.orderTotal,
    required this.onDownloadQr,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DoubleBezelContainer(
      child: Column(
        children: [
          // Status indicator bar
          Container(
            height: 4,
            color: isOccupied ? CafeColors.warning : CafeColors.success,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Table number
                  Text(
                    'Table $tableNumber',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isOccupied ? CafeColors.warning : CafeColors.success)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOccupied ? 'Occupied' : 'Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOccupied
                            ? CafeColors.warning
                            : CafeColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: QrImageView(
                      data: SecurityLayer.generateQrToken('table_$tableNumber'),
                      version: QrVersions.auto,
                      size: 80,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.Q,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Order info if occupied
                  if (isOccupied) ...[
                    Text(
                      '$activeOrders order${activeOrders == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${orderTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CafeColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onDownloadQr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'QR',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
