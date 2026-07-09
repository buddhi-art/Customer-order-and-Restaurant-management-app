import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';

class ExpenseNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() => _mockExpenses;

  void addExpense(Expense expense) {
    state = [expense, ...state];
  }

  void updateExpense(Expense expense) {
    final index = state.indexWhere((e) => e.id == expense.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = expense;
      state = updated;
    }
  }

  void removeExpense(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  double get totalExpenses => state.fold<double>(0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> get byCategory {
    final map = <ExpenseCategory, double>{};
    for (final e in state) {
      map.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    return map;
  }

  List<Expense> forDateRange(DateTime start, DateTime end) {
    return state
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }

  static final List<Expense> _mockExpenses = [
    Expense(
      id: 'exp-1',
      title: 'Coffee Beans - Arabica',
      description: '50kg specialty grade from Chitlang',
      amount: 625.00,
      category: ExpenseCategory.ingredients,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      paidTo: 'Chitlang Coffee Estate',
    ),
    Expense(
      id: 'exp-2',
      title: 'Milk Delivery',
      description: 'Fresh whole milk - 40L',
      amount: 48.00,
      category: ExpenseCategory.ingredients,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      paidTo: 'Dairy Farm Nepal',
    ),
    Expense(
      id: 'exp-3',
      title: 'Electricity Bill',
      description: 'Monthly utility payment',
      amount: 320.00,
      category: ExpenseCategory.utilities,
      date: DateTime.now().subtract(const Duration(days: 2)),
      paidTo: 'NEA',
      isRecurring: true,
    ),
    Expense(
      id: 'exp-4',
      title: 'Paper Cups Order',
      description: '500 pcs 12oz cups with lids',
      amount: 75.00,
      category: ExpenseCategory.packaging,
      date: DateTime.now().subtract(const Duration(days: 3)),
      paidTo: 'EcoPack Nepal',
    ),
    Expense(
      id: 'exp-5',
      title: 'Espresso Machine Service',
      description: 'Annual maintenance - La Marzocco',
      amount: 450.00,
      category: ExpenseCategory.maintenance,
      date: DateTime.now().subtract(const Duration(days: 5)),
      paidTo: 'Coffee Tech Solutions',
    ),
    Expense(
      id: 'exp-6',
      title: 'Weekly Payroll',
      description: '6 staff members - full week',
      amount: 1840.00,
      category: ExpenseCategory.payroll,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRecurring: true,
    ),
    Expense(
      id: 'exp-7',
      title: 'Instagram Ads',
      description: 'Monthly social media campaign',
      amount: 150.00,
      category: ExpenseCategory.marketing,
      date: DateTime.now().subtract(const Duration(days: 4)),
      paidTo: 'Meta Ads',
      isRecurring: true,
    ),
    Expense(
      id: 'exp-8',
      title: 'Cleaning Supplies',
      description: 'Detergent, sanitizer, wipes',
      amount: 65.00,
      category: ExpenseCategory.supplies,
      date: DateTime.now().subtract(const Duration(days: 6)),
      paidTo: 'Janitorial Supply Co.',
    ),
    Expense(
      id: 'exp-9',
      title: 'Rent - June',
      description: 'Monthly rent for café space',
      amount: 2500.00,
      category: ExpenseCategory.rent,
      date: DateTime.now().subtract(const Duration(days: 7)),
      paidTo: 'Lalitpur Properties',
      isRecurring: true,
    ),
    Expense(
      id: 'exp-10',
      title: 'Pastry Order',
      description: 'Assorted pastries from local bakery',
      amount: 120.00,
      category: ExpenseCategory.ingredients,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      paidTo: 'Boudha Bakery',
    ),
  ];
}

final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(
  ExpenseNotifier.new,
);
