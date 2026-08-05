import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/m3_theme.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import 'admin_shell.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('loyalty_points', ascending: false)
          .limit(50);
      if (mounted) {
        setState(() {
          _members = List<Map<String, dynamic>>.from(response);
          _hasError = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching members: $e');
      // Do NOT fall back to fake data — surface a real error state so the admin
      // knows the list failed to load rather than trusting fabricated members.
      // (Issue 17)
      if (mounted) {
        setState(() {
          _members = [];
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredMembers {
    if (_searchQuery.isEmpty) return _members;
    final q = _searchQuery.toLowerCase();
    return _members.where((m) {
      final name = (m['full_name'] as String? ?? '').toLowerCase();
      final phone = (m['phone'] ?? m['phone_number'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMembers;
    final totalPoints = _members.fold<int>(
      0,
      (s, m) => s + (m['loyalty_points'] as int? ?? 0),
    );

    return AdminShell(
      title: 'Members',
      selectedIndex: 7,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stats
          Container(
            padding: const EdgeInsets.fromLTRB(48, 48, 48, 32),
            child: Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Top 50 Members',
                    value: '${_members.length}',
                    icon: Icons.people_rounded,
                    color: CafeColors.primary,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _StatBox(
                    label: 'Top 50 Points',
                    value: '$totalPoints',
                    icon: Icons.card_giftcard_rounded,
                    color: CafeColors.ratingGold,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _StatBox(
                    label: 'Top 50 Avg',
                    value: _members.isNotEmpty
                        ? '${(totalPoints / _members.length).round()}'
                        : '0',
                    icon: Icons.trending_up_rounded,
                    color: CafeColors.success,
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0),

          // Search
          Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
                child: DoubleBezelContainer(
                  outerRadius: 28,
                  padding: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone...',
                        hintStyle: TextStyle(
                          color: CafeColors.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: CafeColors.onSurfaceVariant,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CafeColors.onSurface,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fade(duration: 600.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              children: [
                Text(
                  '${filtered.length} member${filtered.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: CafeColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: CafeColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Members list
          Expanded(
            child: _isLoading && _members.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: CafeColors.primary),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasError
                              ? Icons.cloud_off_rounded
                              : Icons.person_search_rounded,
                          size: 64,
                          color: CafeColors.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _hasError
                              ? 'Could not load members'
                              : 'No members found',
                          style: TextStyle(
                            color: CafeColors.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_hasError) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Check your connection and try again.',
                            style: TextStyle(
                              color: CafeColors.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() => _isLoading = true);
                              _fetchMembers();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fade(duration: 600.ms)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(48, 8, 48, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return _MemberCard(
                            rank: _members.indexOf(member) + 1,
                            name: member['full_name'] as String? ?? 'Guest',
                            phone: member['phone'] as String? ?? 'N/A',
                            points: member['loyalty_points'] as int? ?? 0,
                            totalOrders: member['total_orders'] as int? ?? 0,
                            isTop3: index < 3,
                          )
                          .animate(delay: (50 * index).ms)
                          .fade(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DoubleBezelContainer(
      outerRadius: 24,
      padding: 6,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 32,
                color: CafeColors.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: CafeColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final int rank;
  final String name;
  final String phone;
  final int points;
  final int totalOrders;
  final bool isTop3;

  const _MemberCard({
    required this.rank,
    required this.name,
    required this.phone,
    required this.points,
    required this.totalOrders,
    required this.isTop3,
  });

  @override
  Widget build(BuildContext context) {
    // Medals for top 3
    final IconData? medalIcon = switch (rank) {
      1 => Icons.emoji_events_rounded,
      2 => Icons.workspace_premium_rounded,
      3 => Icons.military_tech_rounded,
      _ => null,
    };
    final Color? medalColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DoubleBezelContainer(
        outerRadius: 28,
        padding: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 48,
                child: medalIcon != null
                    ? Icon(medalIcon, color: medalColor, size: 36)
                    : Text(
                        '#$rank',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: CafeColors.outline,
                        ),
                      ),
              ),
              const SizedBox(width: 24),

              // Avatar with initial
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTop3
                      ? CafeColors.onSurface
                      : CafeColors.surfaceContainerLow,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isTop3 ? CafeColors.surface : CafeColors.onSurface,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Name & phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: TextStyle(
                        color: CafeColors.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Orders count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: CafeColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$totalOrders',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: CafeColors.onSurface,
                      ),
                    ),
                    Text(
                      'orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: CafeColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Points with trophy
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CafeColors.ratingGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CafeColors.ratingGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      size: 20,
                      color: CafeColors.ratingGold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$points',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: CafeColors.ratingGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
