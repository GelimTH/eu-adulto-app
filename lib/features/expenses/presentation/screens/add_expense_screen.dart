import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/expenses_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../reserve/presentation/providers/reserve_provider.dart';
import '../../../reserve/domain/entities/reserve_entity.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../debts/presentation/providers/debts_provider.dart';
import '../../../debts/domain/entities/debt_entity.dart';
import '../../../banks/presentation/providers/banks_provider.dart';
import '../../../cards/presentation/providers/cards_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseEntity? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.outros;
  ExpenseClassification _classification = ExpenseClassification.necessidade;
  DateTime _date = DateTime.now();
  int? _selectedBankId;
  int? _selectedCardId;
  bool _isLoading = false;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expenseToEdit;
    if (e != null) {
      _valorController.text = e.valor.toStringAsFixed(2).replaceAll('.', ',');
      _descricaoController.text = e.descricao ?? '';
      _category = e.categoria;
      _classification = e.classificacao;
      _date = e.data;
      _selectedBankId = e.bancoId;
      _selectedCardId = e.cartaoId;
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final valor = _valorController.text.parseBrl;
    final expense = ExpenseEntity(
      id: widget.expenseToEdit?.id,
      valor: valor,
      categoria: _category,
      classificacao: _classification,
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      data: _date,
      bancoId: _selectedBankId,
      cartaoId: _selectedCardId,
    );

    try {
      if (_isEditing) {
        await ref.read(expensesNotifierProvider.notifier).editItem(expense);
      } else {
        await ref.read(expensesNotifierProvider.notifier).add(expense);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final reserve = ref.watch(reserveNotifierProvider).value;
    final goals = ref.watch(goalsNotifierProvider).value;
    final debts = ref.watch(debtsNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editarGasto : AppStrings.novoGasto),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _valorController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                ],
                style: AppTextStyles.moneyLarge,
                decoration: const InputDecoration(
                  labelText: AppStrings.valor,
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return AppStrings.campoObrigatorio;
                  if (v.parseBrl <= 0) return AppStrings.valorInvalido;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildFuturoEuCard(user?.salarioMensal, reserve, goals, debts),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.descricao,
                  hintText: 'Opcional',
                ),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.categoria, style: AppTextStyles.label),
              const SizedBox(height: 12),
              _buildCategoryGrid(),
              const SizedBox(height: 20),
              Text(AppStrings.classificacao, style: AppTextStyles.label),
              const SizedBox(height: 12),
              _buildClassificationList(),
              const SizedBox(height: 20),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildLinkSection(),
              const SizedBox(height: 32),
              AppButton(
                label: AppStrings.salvar,
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturoEuCard(
    double? salario,
    ReserveEntity? reserve,
    List<GoalEntity>? goals,
    List<DebtEntity>? debts,
  ) {
    if (salario == null || salario <= 0) return const SizedBox();
    final valor = _valorController.text.parseBrl;
    if (valor <= 0) return const SizedBox();

    final diasTrabalho = valor / (salario / 22);
    final pctSalario = valor / salario * 100;

    final reservaAtual = reserve?.valorAtual ?? 0.0;
    String? reservaImpact;
    if (reservaAtual > 0) {
      final pct = valor / reservaAtual * 100;
      reservaImpact = '${pct.toStringAsFixed(1)}% da sua reserva de emergência';
    }

    String? metaImpact;
    if (goals != null) {
      final primeiraAtiva = goals.where((g) => !g.concluida).firstOrNull;
      if (primeiraAtiva != null) {
        if (valor >= primeiraAtiva.valorFaltante) {
          metaImpact =
              'Suficiente para completar a meta "${primeiraAtiva.nome}"!';
        } else {
          final pct = valor / primeiraAtiva.valorAlvo * 100;
          metaImpact =
              '${pct.toStringAsFixed(1)}% de avanço na meta "${primeiraAtiva.nome}"';
        }
      }
    }

    String? dividaImpact;
    if (debts != null && debts.isNotEmpty) {
      final totalParcela =
          debts.fold<double>(0.0, (sum, d) => sum + d.valorParcela);
      if (totalParcela > 0) {
        final equiv = valor / totalParcela;
        dividaImpact =
            'Equivale a ${equiv.toStringAsFixed(1)}× sua parcela mensal de dívidas';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: AppColors.secondary, size: 16),
              const SizedBox(width: 8),
              Text('Futuro Eu', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• ${diasTrabalho.toStringAsFixed(1)} dias de trabalho',
            style: AppTextStyles.caption,
          ),
          Text(
            '• ${pctSalario.toStringAsFixed(1)}% do seu salário',
            style: AppTextStyles.caption,
          ),
          if (reservaImpact != null)
            Text('• $reservaImpact', style: AppTextStyles.caption),
          if (metaImpact != null)
            Text('• $metaImpact', style: AppTextStyles.caption),
          if (dividaImpact != null)
            Text('• $dividaImpact', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildLinkSection() {
    final banksAsync = ref.watch(banksNotifierProvider);
    final cardsAsync = ref.watch(cardsNotifierProvider);

    final banks = banksAsync.value ?? [];
    final cards = cardsAsync.value ?? [];

    if (banks.isEmpty && cards.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vincular (opcional)', style: AppTextStyles.label),
        const SizedBox(height: 12),
        if (banks.isNotEmpty)
          DropdownButtonFormField<int?>(
            initialValue: _selectedBankId,
            decoration: const InputDecoration(labelText: 'Banco'),
            dropdownColor: AppColors.cardDark,
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Nenhum')),
              ...banks.map((b) => DropdownMenuItem<int?>(
                    value: b.id,
                    child: Text(b.nome),
                  )),
            ],
            onChanged: (v) => setState(() => _selectedBankId = v),
          ),
        if (banks.isNotEmpty && cards.isNotEmpty) const SizedBox(height: 12),
        if (cards.isNotEmpty)
          DropdownButtonFormField<int?>(
            initialValue: _selectedCardId,
            decoration: const InputDecoration(labelText: 'Cartão de crédito'),
            dropdownColor: AppColors.cardDark,
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Nenhum')),
              ...cards.map((c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.nome),
                  )),
            ],
            onChanged: (v) => setState(() => _selectedCardId = v),
          ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: ExpenseCategory.values.length,
      itemBuilder: (_, i) {
        final cat = ExpenseCategory.values[i];
        final isSelected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getCategoryEmoji(cat),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  cat.label,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassificationList() {
    return Column(
      children: ExpenseClassification.values.map((cls) {
        final isSelected = _classification == cls;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _classification = cls),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Text(cls.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(cls.label, style: AppTextStyles.body),
                  if (isSelected) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: AppColors.primary, size: 18),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(
              'Data: ${_date.day}/${_date.month}/${_date.year}',
              style: AppTextStyles.body,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
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
