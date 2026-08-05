import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/m3_theme.dart';
import '../../ui/core/widgets/double_bezel_container.dart';
import 'admin_shell.dart';

class FeedbackManagementScreen extends ConsumerStatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  ConsumerState<FeedbackManagementScreen> createState() =>
      _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState
    extends ConsumerState<FeedbackManagementScreen> {
  String _filter = 'all';

  final _mockReviews = List.generate(
    8,
    (i) => _ReviewData(
      id: 'rev-$i',
      name: [
        'Aarav Sharma',
        'Priya Patel',
        'Ravi Kumar',
        'Sita Thapa',
        'Deepak Gurung',
        'Anita Rai',
        'Binod Poudel',
        'Kavita Joshi',
      ][i],
      rating: [5, 4, 5, 3, 5, 4, 4, 5][i],
      comment: [
        'Best cappuccino in town! The latte art was beautiful and the service was impeccable.',
        'Great atmosphere but the espresso was a bit too strong for my taste.',
        'Absolutely love this place! The cold brew is amazing and the staff is super friendly.',
        'Good coffee but the waiting time was a bit long during peak hours.',
        'The mocha here is heavenly. My go-to spot for meetings with friends.',
        'Affogato is to die for! Perfect combination of ice cream and espresso.',
        'Nice ambience and decent coffee. The pastry selection could be better though.',
        'Best café in the city hands down. The flat white is perfection every single time.',
      ][i],
      date: DateTime.now().subtract(
        Duration(hours: [2, 5, 12, 18, 24, 36, 48, 72][i]),
      ),
      itemName: [
        'Cappuccino',
        'Espresso',
        'Cold Brew',
        'Latte',
        'Mocha',
        'Affogato',
        'Americano',
        'Flat White',
      ][i],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'positive'
        ? _mockReviews.where((r) => r.rating >= 4).toList()
        : _filter == 'negative'
        ? _mockReviews.where((r) => r.rating <= 2).toList()
        : _mockReviews;

    final avgRating = _mockReviews.isEmpty
        ? 0.0
        : _mockReviews.fold<double>(0, (s, r) => s + r.rating) /
              _mockReviews.length;

    final positiveCount = _mockReviews.where((r) => r.rating >= 4).length;
    final negativeCount = _mockReviews.where((r) => r.rating <= 2).length;

    return AdminShell(
      title: 'Feedback',
      selectedIndex: 10,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFeedback(context),
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Add Review'),
        backgroundColor: CafeColors.onSurface,
        foregroundColor: CafeColors.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Container(
            padding: const EdgeInsets.fromLTRB(48, 48, 48, 32),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.star_rounded,
                  value: avgRating.toStringAsFixed(1),
                  label: 'Average',
                  color: CafeColors.ratingGold,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  icon: Icons.thumb_up_rounded,
                  value: '$positiveCount',
                  label: 'Positive',
                  color: CafeColors.success,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  icon: Icons.thumb_down_rounded,
                  value: '$negativeCount',
                  label: 'Negative',
                  color: CafeColors.error,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  icon: Icons.reviews_rounded,
                  value: '${_mockReviews.length}',
                  label: 'Total',
                  color: CafeColors.primary,
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),

          // Filter chips
          Container(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  children: [
                    _FilterChipSmall(
                      label: 'All Reviews',
                      isSelected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 12),
                    _FilterChipSmall(
                      label: 'Positive',
                      isSelected: _filter == 'positive',
                      onTap: () => setState(() => _filter = 'positive'),
                    ),
                    const SizedBox(width: 12),
                    _FilterChipSmall(
                      label: 'Critical',
                      isSelected: _filter == 'negative',
                      onTap: () => setState(() => _filter = 'negative'),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 32),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.reviews_rounded,
                          size: 64,
                          color: CafeColors.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reviews yet',
                          style: const TextStyle(
                            color: CafeColors.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 400.ms, delay: 200.ms)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(48, 8, 48, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final review = filtered[index];
                      return _ReviewCard(review: review, index: index)
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

  void _showAddFeedback(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    double rating = 5;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Customer Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rating: ${rating.toInt()} stars',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setDialogState(() => rating = v),
                  activeColor: CafeColors.ratingGold,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    prefixIcon: Icon(Icons.chat_rounded),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Feedback added successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    commentCtrl.dispose();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipSmall extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipSmall({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? CafeColors.primaryContainer
              : CafeColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? CafeColors.primary : CafeColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? CafeColors.onPrimaryContainer
                : CafeColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ReviewData {
  final String id;
  final String name;
  final int rating;
  final String comment;
  final DateTime date;
  final String itemName;

  const _ReviewData({
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    required this.itemName,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;
  final int index;

  const _ReviewCard({required this.review, required this.index});

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: DoubleBezelContainer(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: review.rating >= 4
                      ? CafeColors.successContainer
                      : CafeColors.errorContainer.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Text(
                    review.name[0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: review.rating >= 4
                          ? CafeColors.onSuccess
                          : CafeColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
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
                            review.itemName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CafeColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Stars
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 20,
                          color: CafeColors.ratingGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.comment,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CafeColors.onSurface,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: CafeColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(review.date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: CafeColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
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

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
