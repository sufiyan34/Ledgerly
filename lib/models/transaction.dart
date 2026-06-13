enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String categoryId; // References Category.id
  final DateTime dateTime;
  final String note;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.dateTime,
    this.note = '',
    required this.type,
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? dateTime,
    String? note,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'categoryId': categoryId,
    'dateTime': dateTime.toIso8601String(),
    'note': note,
    'type': type.name,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    categoryId: json['categoryId'],
    dateTime: DateTime.parse(json['dateTime']),
    note: json['note'] ?? '',
    type: json['type'] == 'income'
        ? TransactionType.income
        : TransactionType.expense,
  );
}
