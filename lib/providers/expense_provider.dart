import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _items = [];

  List<Expense> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('expenses.data') ?? '[]';
    final list = json.decode(raw) as List<dynamic>;
    _items.clear();
    for (var m in list) {
      _items.add(Expense.fromMap(Map<String, dynamic>.from(m)));
    }
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _items.map((e) => e.toMap()).toList();
    await prefs.setString('expenses.data', json.encode(list));
  }

  Future<void> addExpense(Expense exp) async {
    // generate simple unique id based on timestamp if none provided
    if (exp.id.isEmpty)
      exp.id = DateTime.now().millisecondsSinceEpoch.toString();
    _items.add(exp);
    await save();
    notifyListeners();
  }

  Future<void> updateExpense(Expense exp) async {
    final idx = _items.indexWhere((e) => e.id == exp.id);
    if (idx >= 0) {
      _items[idx] = exp;
      await save();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _items.removeWhere((e) => e.id == id);
    await save();
    notifyListeners();
  }

  double totalForMonth(DateTime month) {
    return _items
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0.0, (s, e) => s + e.amount);
  }
}
