import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    final items = prov.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/resources'),
            icon: const Icon(Icons.cloud_download),
          ),
        ],
      ),
      backgroundColor: const Color(0xffafe1ba),
      body: Consumer<ExpenseProvider>(
        builder: (context, prov, _) {
          final items = prov.items;
          if (items.isEmpty) {
            return const Center(child: Text('Nenhuma despesa registrada'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final e = items[i];
              return ListTile(
                title: Text(e.title),
                subtitle:
                    Text('${DateFormat.yMMMd().format(e.date)} • ${e.note}'),
                trailing: Text('R\$ ${e.amount.toStringAsFixed(2)}'),
                onTap: () => _showEditDialog(context, e),
                onLongPress: () => prov.deleteExpense(e.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // exemplo adição rápida
          final newExp = Expense(
            id: '',
            title: 'Nova despesa',
            amount: 10.0,
            date: DateTime.now(),
            categoryId: 'Outros',
          );
          await prov.addExpense(newExp);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // =====================================================
  // Método corrigido: chama updateExpense passando apenas
  // um Expense (não dois argumentos).
  // =====================================================
  Future<void> _showEditDialog(BuildContext context, Expense expense) async {
    final titleController = TextEditingController(text: expense.title);
    final amountController =
        TextEditingController(text: expense.amount.toString());

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Despesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              // aceita vírgula como separador decimal
              final raw = amountController.text.replaceAll(',', '.').trim();
              final newAmount = double.tryParse(raw) ?? 0.0;

              if (newTitle.isNotEmpty && newAmount > 0) {
                // Cria um novo Expense (ou pode copiar o antigo e alterar campos)
                final updated = Expense(
                  id: expense.id,
                  title: newTitle,
                  amount: newAmount,
                  date: expense.date,
                  categoryId: expense.categoryId,
                  // mantenha outros campos (note, etc.) conforme seu model
                );

                // Aqui: updateExpense aceita UM argumento (Expense)
                Provider.of<ExpenseProvider>(context, listen: false)
                    .updateExpense(updated);
              }

              Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    // se quiser, libere os controllers locais:
    titleController.dispose();
    amountController.dispose();
  }
}
