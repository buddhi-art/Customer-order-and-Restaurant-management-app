import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../theme/m3_theme.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import 'admin_shell.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  final _uuid = const Uuid();
  String _searchQuery = '';
  String? _selectedCategory;

  // Form controllers for add/edit bottom sheet
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _unitController = TextEditingController();
  final _costController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _costController.dispose();
    super.dispose();
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    var filtered = items;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }
    if (_selectedCategory != null) {
      filtered = filtered
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
    return filtered;
  }

  Color _stockColor(double currentStock, double minStock) {
    final ratio = minStock > 0 ? currentStock / minStock : 1;
    if (ratio >= 1.5) return CafeColors.success;
    if (ratio >= 1.0) return CafeColors.warning;
    return CafeColors.error;
  }

  double _stockBarRatio(double currentStock, double minStock) {
    if (minStock <= 0) return 1.0;
    return (currentStock / minStock).clamp(0.0, 2.0);
  }

  void _showAddEditSheet({InventoryItem? item}) {
    final isEditing = item != null;
    _nameController.text = item?.name ?? '';
    _categoryController.text = item?.category ?? '';
    _stockController.text = item?.currentStock.toString() ?? '';
    _minStockController.text = item?.minStock.toString() ?? '';
    _unitController.text = item?.unit ?? 'units';
    _costController.text = item?.costPerUnit.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? 'Edit Item' : 'Add Inventory Item',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      prefixIcon: Icon(Icons.inventory_2_rounded),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Current Stock',
                            prefixIcon: Icon(Icons.inventory_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _minStockController,
                          decoration: const InputDecoration(
                            labelText: 'Min Stock',
                            prefixIcon: Icon(Icons.warning_amber_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            prefixIcon: Icon(Icons.scale_rounded),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          decoration: const InputDecoration(
                            labelText: 'Cost/Unit',
                            prefixIcon: Icon(Icons.attach_money_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final newItem = InventoryItem(
                          id: isEditing ? item.id : _uuid.v4(),
                          name: _nameController.text.trim(),
                          category: _categoryController.text.trim(),
                          currentStock:
                              double.tryParse(_stockController.text) ?? 0,
                          minStock:
                              double.tryParse(_minStockController.text) ?? 0,
                          unit: _unitController.text.trim(),
                          costPerUnit:
                              double.tryParse(_costController.text) ?? 0,
                        );
                        if (isEditing) {
                          ref
                              .read(inventoryProvider.notifier)
                              .updateItem(newItem);
                        } else {
                          ref.read(inventoryProvider.notifier).addItem(newItem);
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Text(isEditing ? 'Update' : 'Add Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActionSheet(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Edit Item'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showAddEditSheet(item: item);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline_rounded),
                  title: const Text('Adjust Stock'),
                  subtitle: const Text('Add or remove stock'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showStockAdjustDialog(item);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete Item',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDelete(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStockAdjustDialog(InventoryItem item) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Adjust Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.name}: Current ${item.currentStock} ${item.unit}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Adjustment (+/-)',
                  prefixIcon: Icon(Icons.add_circle_outline_rounded),
                  hintText: 'e.g. 10 or -5',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final delta = double.tryParse(controller.text);
                if (delta != null && delta != 0) {
                  ref
                      .read(inventoryProvider.notifier)
                      .adjustStock(item.id, delta);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  void _confirmDelete(InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                ref.read(inventoryProvider.notifier).deleteItem(item.id);
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inventoryProvider);
    final categories = ref.read(inventoryProvider.notifier).categories.toList()
      ..sort();
    final filtered = _filterItems(items);
    final colorScheme = Theme.of(context).colorScheme;

    return AdminShell(
      title: 'Inventory',
      selectedIndex: 6,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEditSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inventoryProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search inventory...',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

            // Category filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                        selectedColor: CafeColors.primaryContainer,
                        checkmarkColor: CafeColors.onPrimaryContainer,
                      ),
                    ),
                    ...categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (sel) => setState(
                            () => _selectedCategory = sel ? cat : null,
                          ),
                          selectedColor: CafeColors.primaryContainer,
                          checkmarkColor: CafeColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Grid count header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${filtered.length} item${filtered.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Grid of inventory items
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      220, // Keeps cards compact on wide screens
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = filtered[index];
                  final stockColor = _stockColor(
                    item.currentStock,
                    item.minStock,
                  );
                  final barRatio = _stockBarRatio(
                    item.currentStock,
                    item.minStock,
                  );
                  final totalValue = item.currentStock * item.costPerUnit;

                  return DoubleBezelContainer(
                    child: InkWell(
                      onLongPress: () => _showActionSheet(item),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: CafeColors.primaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: CafeColors.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Name
                            Expanded(
                              child: Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Stock gauge bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${item.currentStock.toStringAsFixed(item.currentStock == item.currentStock.roundToDouble() ? 0 : 1)} ${item.unit}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: stockColor,
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'min: ${item.minStock.toStringAsFixed(item.minStock == item.minStock.roundToDouble() ? 0 : 1)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: barRatio),
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, _) {
                                      return LinearProgressIndicator(
                                        value: value / 2.0,
                                        backgroundColor:
                                            colorScheme.surfaceContainerHigh,
                                        color: stockColor,
                                        minHeight: 6,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Cost info row
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money_rounded,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '\$${item.costPerUnit.toStringAsFixed(2)}/${item.unit}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${totalValue.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }
}
