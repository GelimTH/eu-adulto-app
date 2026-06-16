import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/expenses_provider.dart';
import '../../domain/entities/expense_entity.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesNotifierProvider);
    final totalAsync = ref.watch(expensesTotalProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.gastos),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => context.push('/expenses/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(context, ref, selectedMonth, totalAsync),
          _buildCategoryFilter(ref, selectedCategory),
          Expanded(
            child: expensesAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (expenses) {
                final filtered = selectedCategory == null
                    ? expenses
                    : expenses
                        .where((e) => e.categoria == selectedCategory)
                        .toList();
                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    message: selectedCategory != null
                        ? 'Nenhum gasto de "${selectedCategory.label}" neste mês.'
                        : 'Nenhum gasto registrado neste mês.',
                    actionLabel: AppStrings.novoGasto,
                    icon: Icons.receipt_long_outlined,
                    onAction: () => context.push('/expenses/add'),
                  );
                }
                return _GroupedExpensesList(expenses: filtered);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Gasto',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
    AsyncValue<double> totalAsync,
  ) {
    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).state = DateTime(
                  selectedMonth.year, selectedMonth.month - 1);
            },
          ),
          Column(
            children: [
              Text(selectedMonth.mesAno, style: AppTextStyles.subtitle),
              const SizedBox(height: 2),
              totalAsync.when(
                loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 1.5,
                        color: AppColors.primary)),
                error: (_, _) => const SizedBox(),
                data: (total) => Text(
                  total.brl,
                  style: AppTextStyles.moneySmall
                      .copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          IconButton(
            icon:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onPressed: () {
              final now = DateTime.now();
              final next =
                  DateTime(selectedMonth.year, selectedMonth.month + 1);
              if (!next.isAfter(DateTime(now.year, now.month))) {
                ref.read(selectedMonthProvider.notifier).state = next;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, ExpenseCategory? selectedCategory) {
    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CategoryFilterChip(
              label: 'Todos',
              selected: selectedCategory == null,
              onTap: () =>
                  ref.read(selectedCategoryProvider.notifier).state = null,
            ),
            const SizedBox(width: 8),
            ...ExpenseCategory.values.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryFilterChip(
                    label: cat.label,
                    selected: selectedCategory == cat,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state =
                          selectedCategory == cat ? null : cat;
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _GroupedExpensesList extends ConsumerWidget {
  final List<ExpenseEntity> expenses;

  const _GroupedExpensesList({required this.expenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, List<ExpenseEntity>> grouped = {};
    for (final e in expenses) {
      final key = _dateKey(e.data);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final days = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final day = days[i];
        final dayExpenses = grouped[day]!;
        final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.valor);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(day, style: AppTextStyles.label),
                  Text(dayTotal.brl,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error)),
                ],
              ),
            ),
            ...dayExpenses.map((expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExpenseCard(expense: expense),
                )),
          ],
        );
      },
    );
  }

  String _dateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Hoje';
    if (d == yesterday) return 'Ontem';
    return date.ddMMyyyy;
  }
}

class _ExpenseCard extends ConsumerWidget {
  final ExpenseEntity expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('expense_${expense.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Excluir gasto?'),
                content: Text(
                    expense.descricao ?? expense.categoria.label),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Excluir',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        if (expense.id != null) {
          ref.read(expensesNotifierProvider.notifier).delete(expense.id!);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 22),
            SizedBox(height: 4),
            Text('Excluir',
                style: TextStyle(color: AppColors.error, fontSize: 11)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => context.push('/expenses/edit', extra: expense),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.categoria)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    _getCategoryEmoji(expense.categoria),
                    style: const TextStyle(fontSize: 19),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.descricao ?? expense.categoria.label,
                      style: AppTextStyles.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getClassificationColor(expense.classificacao)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${expense.classificacao.emoji} ${expense.classificacao.label}',
                            style: TextStyle(
                              fontSize: 10,
                              color: _getClassificationColor(
                                  expense.classificacao),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          expense.categoria.label,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                expense.valor.brl,
                style: AppTextStyles.moneySmall
                    .copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.alimentacao:
        return Colors.orange;
      case ExpenseCategory.transporte:
        return Colors.blue;
      case ExpenseCategory.saude:
        return Colors.red;
      case ExpenseCategory.educacao:
        return Colors.purple;
      case ExpenseCategory.lazer:
        return Colors.pink;
      case ExpenseCategory.moradia:
        return Colors.teal;
      case ExpenseCategory.vestuario:
        return Colors.indigo;
      case ExpenseCategory.outros:
        return AppColors.textMuted;
    }
  }

  Color _getClassificationColor(ExpenseClassification cls) {
    switch (cls) {
      case ExpenseClassification.necessidade:
        return AppColors.success;
      case ExpenseClassification.conforto:
        return AppColors.info;
      case ExpenseClassification.impulso:
        return AppColors.error;
      case ExpenseClassification.recompensaEmocional:
        return AppColors.warning;
    }
  }

  String _getCategoryEmoji(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.alimentacao:
        return '🍔';
      case ExpenseCategory.transporte:
        return '🚗';
      case ExpenseCategory.saude:
        return '💊';
      case ExpenseCategory.educacao:
        return '📚';
      case ExpenseCategory.lazer:
        return '🎮';
      case ExpenseCategory.moradia:
        return '🏠';
      case ExpenseCategory.vestuario:
        return '👕';
      case ExpenseCategory.outros:
        return '📦';
    }
  }
}
