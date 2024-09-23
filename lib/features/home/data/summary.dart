class BudgetProgress {
  const BudgetProgress({
    required this.category,
    required this.color,
    required this.amountCents,
    required this.spentCents,
    required this.status,
  });

  factory BudgetProgress.fromJson(Map<String, dynamic> json) => BudgetProgress(
        category: json['category'] as String,
        color: json['color'] as String,
        amountCents: json['amount_cents'] as int,
        spentCents: json['spent_cents'] as int,
        status: json['status'] as String,
      );

  final String category;
  final String color;
  final int amountCents;
  final int spentCents;
  final String status; // ok | warning | over

  double get ratio => amountCents == 0 ? 0 : spentCents / amountCents;
}

class Summary {
  const Summary({
    required this.month,
    required this.currency,
    required this.incomeCents,
    required this.expenseCents,
    required this.netWorthCents,
    required this.budgets,
    this.stale = false,
  });

  factory Summary.fromJson(Map<String, dynamic> json, {bool stale = false}) =>
      Summary(
        month: json['month'] as String,
        currency: json['currency'] as String,
        incomeCents: json['income_cents'] as int,
        expenseCents: json['expense_cents'] as int,
        netWorthCents: json['net_worth_cents'] as int,
        budgets: (json['budgets'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(BudgetProgress.fromJson)
            .toList(),
        stale: stale,
      );

  final String month;
  final String currency;
  final int incomeCents;
  final int expenseCents;
  final int netWorthCents;
  final List<BudgetProgress> budgets;

  /// True when this is the last cached copy because the server was unreachable.
  final bool stale;

  int get netCents => incomeCents - expenseCents;
}
