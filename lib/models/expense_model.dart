
class Expense {
  String id;
  String title;
  double amount;
  DateTime date;
  String categoryId;
  String note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note = '',
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] is int) ? (map['amount'] as int).toDouble() : (map['amount'] as double? ?? 0.0),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      categoryId: map['categoryId'] ?? '',
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'note': note,
    };
  }
}

class Category {
  String id;
  String nome;
  String icone;
  String cor;

  Category({
    required this.id,
    required this.nome,
    this.icone = '🏷️',
    this.cor = '#0EA5E9',
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      icone: map['icone'] ?? '🏷️',
      cor: map['cor'] ?? '#0EA5E9',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'icone': icone,
      'cor': cor,
    };
  }
}
