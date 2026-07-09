import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class TopMembersLeaderboard extends StatefulWidget {
  const TopMembersLeaderboard({super.key});

  @override
  State<TopMembersLeaderboard> createState() => _TopMembersLeaderboardState();
}

class _TopMembersLeaderboardState extends State<TopMembersLeaderboard> {
  List<Map<String, dynamic>> _topMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopMembers();
  }

  Future<void> _fetchTopMembers() async {
    try {
      // Sorting by loyalty_points as a direct correlation to total amount spent
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('loyalty_points', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _topMembers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching top members: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_topMembers.isEmpty) {
      return const Center(child: Text("No customers found."));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadowDark.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(3, 3)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Customers by Spend (Loyalty Points)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => context.push('/admin/members'),
                icon: const Icon(Icons.list, color: AppColors.primaryAction),
                label: const Text('View Full Directory', style: TextStyle(color: AppColors.primaryAction, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(60),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.1))),
                ),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Loyalty Pts', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                ],
              ),
              ..._topMembers.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                final isTop3 = index < 3;
                
                return TableRow(
                  decoration: BoxDecoration(
                    color: isTop3 ? AppColors.primaryAction.withValues(alpha: 0.05) : null,
                    border: Border(bottom: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.05))),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index == 0 ? Colors.amber[700] : (index == 1 ? Colors.grey[600] : (index == 2 ? Colors.brown[400] : AppColors.textSecondary)),
                          fontSize: isTop3 ? 18 : 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(member['full_name'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(member['phone'] ?? 'N/A', style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '${member['loyalty_points'] ?? 0}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryAction, fontSize: 16),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
