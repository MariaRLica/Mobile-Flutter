import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

/// Helper simples para exibir um "gráfico" textual.
/// Data é um Map<categoria, valor>.
Widget _buildSimpleChart(BuildContext context, Map<String, double> data) {
  final total = data.values.fold(0.0, (a, b) => a + b);
  return Column(
    children: data.entries.map((e) {
      final pct = total == 0 ? 0 : (e.value / total * 100);
      return ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(0xff9f21f3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(e.key),
        trailing:
            Text('${e.value.toStringAsFixed(2)} (${pct.toStringAsFixed(0)}%)'),
      );
    }).toList(),
  );
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Exemplo: texto estático — depois você pode trocar por dados do provider
  @override
  Widget build(BuildContext context) {
    // Aqui você pode agregar despesas por categoria usando ExpenseProvider
    final expenses = Provider.of<ExpenseProvider>(context).items;
    // Exemplo simples de agregação por categoria (se suas despesas tiverem categoryId, adapte)
    final Map<String, double> byCategory = {};
    for (var e in expenses) {
      final key = e.categoryId.isNotEmpty ? e.categoryId : 'Outros';
      byCategory[key] = (byCategory[key] ?? 0) + e.amount;
    }
    // Se estiver vazio, use dados de exemplo para não quebrar UI
    final data = byCategory.isEmpty
        ? {'Alimentação': 120.0, 'Transporte': 80.0, 'Lazer': 50.0}
        : byCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento'),
        backgroundColor: const Color(0xffa76dbe),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Distribuição por categoria',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildSimpleChart(context, data),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Aqui você pode listar categorias/detalhes...
            Card(
              child: ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Resumo mensal'),
                subtitle: const Text('Toque para ver detalhes'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
