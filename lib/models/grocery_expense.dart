class GroceryExpense {
  const GroceryExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.purchasedAt,
  });

  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime purchasedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'purchasedAt': purchasedAt.toIso8601String(),
    };
  }

  factory GroceryExpense.fromJson(Map<String, dynamic> json) {
    return GroceryExpense(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      description: json['description'] as String? ?? 'Grocery purchase',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'Other',
      purchasedAt: DateTime.tryParse(
            json['purchasedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
