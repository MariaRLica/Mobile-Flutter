import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prov = Provider.of<ExpenseProvider>(context);
    final total = prov.totalForMonth(now);

    // Últimas 5 despesas (mais recentes)
    final List<Expense> recent = prov.items.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xffc7029c),
        actions: [
          IconButton(
            tooltip: 'Despesas',
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/expenses'),
          ),
          IconButton(
            tooltip: 'Orçamento',
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.pushNamed(context, '/budget'),
          ),
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'about') Navigator.pushNamed(context, '/about');
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'about', child: Text('Sobre')),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total de ${DateFormat.yMMMM().format(now)}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('R\$ ${total.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontWeight: FontWeight.w400)),
              const SizedBox(height: 24),
              const Text('Últimas despesas',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Nenhuma despesa cadastrada',
                      style: Theme.of(context).textTheme.bodyMedium),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final e = recent[i];
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text(DateFormat.yMMMd().format(e.date)),
                      trailing: Text('R\$ ${e.amount.toStringAsFixed(2)}'),
                      onTap: () {
                        // Exemplo: mostrar detalhes em dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(e.title),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Valor: R\$ ${e.amount.toStringAsFixed(2)}'),
                                Text(
                                    'Data: ${DateFormat.yMMMd().format(e.date)}'),
                                Text('Categoria: ${e.categoryId}'),
                                if (e.note.isNotEmpty) Text('Nota: ${e.note}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar')),
                              TextButton(
                                onPressed: () async {
                                  // deletar exemplo
                                  await prov.deleteExpense(e.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Remover',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Adição rápida — abre um dialog para inserir dados básicos
          final newExpense = await _showAddExpenseDialog(context);
          if (newExpense != null) {
            await prov.addExpense(newExpense);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Despesa adicionada')));
          }
        },
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<Expense?> _showAddExpenseDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'Outros';

    return showDialog<Expense>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nova despesa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título')),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                  controller: TextEditingController(text: category),
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  onChanged: (v) {
                    category = v;
                  }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                final a =
                    double.tryParse(amountCtrl.text.replaceAll(',', '.')) ??
                        0.0;
                if (t.isEmpty || a <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Preencha título e valor válido')));
                  return;
                }
                final expense = Expense(
                    id: '',
                    title: t,
                    amount: a,
                    date: DateTime.now(),
                    categoryId: category);
                Navigator.pop(ctx, expense);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
