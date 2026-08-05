class FeedbackItem {
  final String id;
  final String? userId;
  final String customerName;
  final double rating;
  final String comment;
  final String? itemName;
  final DateTime createdAt;

  FeedbackItem({
    required this.id,
    this.userId,
    required this.customerName,
    required this.rating,
    required this.comment,
    this.itemName,
    required this.createdAt,
  });
}
