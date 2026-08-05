import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../theme/m3_theme.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import '../../providers/staff_provider.dart';
import '../../models/staff.dart';
import 'admin_shell.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  final _uuid = const Uuid();
  String _searchQuery = '';
  StaffRole? _selectedRole;

  List<StaffMember> _filter(List<StaffMember> staff) {
    var filtered = staff;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((s) => s.name.toLowerCase().contains(q) || s.phone.contains(q))
          .toList();
    }
    if (_selectedRole != null) {
      filtered = filtered.where((s) => s.role == _selectedRole).toList();
    }
    return filtered;
  }

  void _showAddEditSheet({StaffMember? existing}) async {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final wageCtrl = TextEditingController(
      text: existing?.hourlyWage.toStringAsFixed(2) ?? '12.00',
    );
    final formKey = GlobalKey<FormState>();
    StaffRole selectedRole = existing?.role ?? StaffRole.barista;
    ShiftType selectedShift = existing?.currentShift ?? ShiftType.morning;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
            child: Form(
              key: formKey,
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
                      isEditing ? 'Edit Staff' : 'Add Staff',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StaffRole>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      items: StaffRole.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheetState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ShiftType>(
                      initialValue: selectedShift,
                      decoration: const InputDecoration(
                        labelText: 'Shift',
                        prefixIcon: Icon(Icons.schedule_rounded),
                      ),
                      items: ShiftType.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheetState(() => selectedShift = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: wageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Wage (\$)',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final member = StaffMember.withDefaults(
                            id: isEditing ? existing.id : _uuid.v4(),
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim().isEmpty
                                ? null
                                : emailCtrl.text.trim(),
                            role: selectedRole,
                            currentShift: selectedShift,
                            hourlyWage: double.tryParse(wageCtrl.text) ?? 12.0,
                            isClockedIn: existing?.isClockedIn ?? false,
                          );
                          if (isEditing) {
                            ref
                                .read(staffProvider.notifier)
                                .updateStaff(member);
                          } else {
                            ref.read(staffProvider.notifier).addStaff(member);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isEditing ? 'Update' : 'Add Staff'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    wageCtrl.dispose();
  }

  void _confirmDelete(StaffMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Staff'),
        content: Text('Remove ${member.name} from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(staffProvider.notifier).removeStaff(member.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffProvider);
    final filtered = _filter(staff);

    final clockedIn = staff.where((s) => s.isClockedIn).length;

    return AdminShell(
      title: 'Staff',
      selectedIndex: 4,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEditSheet,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff'),
        backgroundColor: CafeColors.onSurface,
        foregroundColor: CafeColors.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stats
          Container(
            padding: const EdgeInsets.fromLTRB(48, 48, 48, 32),
            child: Row(
              children: [
                _StatsChip(
                  icon: Icons.people_rounded,
                  label: 'Total',
                  value: '${staff.length}',
                  color: CafeColors.primary,
                ),
                const SizedBox(width: 16),
                _StatsChip(
                  icon: Icons.check_circle_rounded,
                  label: 'On Shift',
                  value: '$clockedIn',
                  color: CafeColors.success,
                ),
                const SizedBox(width: 16),
                _StatsChip(
                  icon: Icons.person_off_rounded,
                  label: 'Off Duty',
                  value: '${staff.length - clockedIn}',
                  color: CafeColors.outline,
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),

          // Search & role filter
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search staff...',
                    hintStyle: TextStyle(
                      color: CafeColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: CafeColors.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: CafeColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: StaffRole.values.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _RoleChip(
                          label: 'All',
                          selected: _selectedRole == null,
                          onTap: () => setState(() => _selectedRole = null),
                        );
                      }
                      final r = StaffRole.values[index - 1];
                      return _RoleChip(
                        label: r.shortLabel,
                        selected: _selectedRole == r,
                        onTap: () => setState(() => _selectedRole = r),
                      );
                    },
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 16),

          // Staff list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 64,
                          color: CafeColors.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No staff found',
                          style: const TextStyle(
                            color: CafeColors.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 400.ms)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(48, 4, 48, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return _StaffCard(
                            member: member,
                            onToggleClock: () => ref
                                .read(staffProvider.notifier)
                                .toggleClockIn(member.id),
                            onEdit: () => _showAddEditSheet(existing: member),
                            onDelete: () => _confirmDelete(member),
                          )
                          .animate(delay: (50 * index).ms)
                          .fade(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatsChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DoubleBezelContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CafeColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: CafeColors.onSurface, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: CafeColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CafeColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        selectedColor: CafeColors.primaryContainer,
        checkmarkColor: CafeColors.onPrimaryContainer,
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  final VoidCallback onToggleClock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.member,
    required this.onToggleClock,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DoubleBezelContainer(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: member.isClockedIn
                      ? CafeColors.success.withValues(alpha: 0.15)
                      : CafeColors.surfaceContainerHigh,
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: member.isClockedIn
                          ? CafeColors.success
                          : CafeColors.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CafeColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            member.role.shortLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CafeColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: CafeColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          member.currentShift.shortLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CafeColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money_rounded,
                          size: 16,
                          color: CafeColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '\$${member.hourlyWage.toStringAsFixed(2)}/hr',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CafeColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Clock in/out button
              Column(
                children: [
                  GestureDetector(
                    onTap: onToggleClock,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: member.isClockedIn
                            ? CafeColors.success.withValues(alpha: 0.12)
                            : CafeColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        color: member.isClockedIn
                            ? CafeColors.success
                            : CafeColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.isClockedIn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: member.isClockedIn
                          ? CafeColors.success
                          : CafeColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // More menu
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 22,
                  color: CafeColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
