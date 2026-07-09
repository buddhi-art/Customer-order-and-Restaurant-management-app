import 'package:flutter/material.dart';

enum ExpenseCategory {
  ingredients,
  packaging,
  utilities,
  maintenance,
  marketing,
  rent,
  payroll,
  supplies,
  other,
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.ingredients:
        return 'Ingredients';
      case ExpenseCategory.packaging:
        return 'Packaging';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.payroll:
        return 'Payroll';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.ingredients:
        return Icons.coffee_rounded;
      case ExpenseCategory.packaging:
        return Icons.inventory_2_rounded;
      case ExpenseCategory.utilities:
        return Icons.bolt_rounded;
      case ExpenseCategory.maintenance:
        return Icons.build_rounded;
      case ExpenseCategory.marketing:
        return Icons.campaign_rounded;
      case ExpenseCategory.rent:
        return Icons.business_rounded;
      case ExpenseCategory.payroll:
        return Icons.people_rounded;
      case ExpenseCategory.supplies:
        return Icons.shopping_cart_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}

class Expense {
  final String id;
  final String title;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? paidTo;
  final String? receiptUrl;
  final bool isRecurring;

  const Expense({
    required this.id,
    required this.title,
    this.description = '',
    required this.amount,
    this.category = ExpenseCategory.other,
    required this.date,
    this.paidTo,
    this.receiptUrl,
    this.isRecurring = false,
  });

  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? paidTo,
    String? receiptUrl,
    bool? isRecurring,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paidTo: paidTo ?? this.paidTo,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'category': category.name,
    'date': date.toIso8601String(),
    'paid_to': paidTo,
    'receipt_url': receiptUrl,
    'is_recurring': isRecurring,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    category: ExpenseCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => ExpenseCategory.other,
    ),
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    paidTo: json['paid_to']?.toString(),
    receiptUrl: json['receipt_url']?.toString(),
    isRecurring: json['is_recurring'] as bool? ?? false,
  );
}
