import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../providers/cards_provider.dart';
import '../../domain/entities/card_entity.dart';
import '../../../banks/presentation/providers/banks_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsNotifierProvider);
    final expenses = ref.watch(expensesNotifierProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cartoes),
        leading: Navigator.canPop(context) ? const BackButton() : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => _showCardSheet(context, ref),
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (cards) {
          if (cards.isEmpty) {
            return EmptyStateWidget(
              message: 'Nenhum cartão cadastrado.',
              actionLabel: AppStrings.novoCartao,
              icon: Icons.credit_card_outlined,
              onAction: () => _showCardSheet(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final card = cards[i];
              final linked = expenses
                  .where((e) => e.cartaoId == card.id)
                  .toList()
                ..sort((a, b) => b.data.compareTo(a.data));
              final linkedTotal =
                  linked.fold(0.0, (sum, e) => sum + e.valor);

              return _CardItem(
                card: card,
                linked: linked,
                linkedTotal: linkedTotal,
                onEdit: () => _showCardSheet(context, ref, card),
                onDelete: () async {
                  final confirmed = await ConfirmationDialog.show(context);
                  if (confirmed && card.id != null) {
                    ref.read(cardsNotifierProvider.notifier).delete(card.id!);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCardSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCardSheet(BuildContext context, WidgetRef ref,
      [CardEntity? card]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CardFormSheet(ref: ref, card: card),
    );
  }
}

class _CardItem extends StatefulWidget {
  final CardEntity card;
  final List<ExpenseEntity> linked;
  final double linkedTotal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardItem({
    required this.card,
    required this.linked,
    required this.linkedTotal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<_CardItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final usedPct = card.limiteTotal > 0
        ? (widget.linkedTotal / card.limiteTotal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.4),
            AppColors.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(card.nome, style: AppTextStyles.heading3),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.textMuted, size: 18),
                          onPressed: widget.onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error, size: 18),
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.limiteTotal,
                            style: AppTextStyles.caption),
                        Text(card.limiteTotal.brl,
                            style: AppTextStyles.moneySmall),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Fecha dia ${card.fechamento} · Vence dia ${card.vencimento}',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
                if (widget.linkedTotal > 0) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gasto neste mês', style: AppTextStyles.caption),
                      Text(
                        widget.linkedTotal.brl,
                        style: AppTextStyles.moneySmall
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: usedPct,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        usedPct > 0.8 ? AppColors.error : AppColors.primary,
                      ),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(usedPct * 100).toInt()}% do limite utilizado',
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          if (widget.linked.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.linked.length} gasto${widget.linked.length > 1 ? 's' : ''} vinculado${widget.linked.length > 1 ? 's' : ''}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, color: AppColors.border),
              ...widget.linked.take(5).map((e) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          '${e.data.day}/${e.data.month}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.descricao ?? e.categoria.label,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          e.valor.brl,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],
          ] else ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Nenhum gasto vinculado neste mês',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardFormSheet extends StatefulWidget {
  final WidgetRef ref;
  final CardEntity? card;

  const _CardFormSheet({required this.ref, this.card});

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  final _nomeController = TextEditingController();
  final _limiteController = TextEditingController();
  final _fechamentoController = TextEditingController(text: '1');
  final _vencimentoController = TextEditingController(text: '10');
  int? _selectedBankId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.card;
    if (c != null) {
      _nomeController.text = c.nome;
      _limiteController.text =
          c.limiteTotal.toStringAsFixed(2).replaceAll('.', ',');
      _fechamentoController.text = c.fechamento.toString();
      _vencimentoController.text = c.vencimento.toString();
      _selectedBankId = c.bancoId;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _limiteController.dispose();
    _fechamentoController.dispose();
    _vencimentoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nomeController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final card = CardEntity(
      id: widget.card?.id,
      bancoId: _selectedBankId,
      nome: _nomeController.text.trim(),
      limiteTotal: _limiteController.text.parseBrl,
      fechamento: int.tryParse(_fechamentoController.text) ?? 1,
      vencimento: int.tryParse(_vencimentoController.text) ?? 10,
    );

    if (widget.card != null) {
      await widget.ref.read(cardsNotifierProvider.notifier).editItem(card);
    } else {
      await widget.ref.read(cardsNotifierProvider.notifier).add(card);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = widget.ref.watch(banksNotifierProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.card != null ? 'Editar Cartão' : AppStrings.novoCartao,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do cartão'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _limiteController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
            ],
            decoration: const InputDecoration(
              labelText: AppStrings.limiteTotal,
              prefixText: 'R\$ ',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fechamentoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      const InputDecoration(labelText: 'Dia fechamento'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _vencimentoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      const InputDecoration(labelText: 'Dia vencimento'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          banksAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (banks) {
              if (banks.isEmpty) return const SizedBox();
              return DropdownButtonFormField<int?>(
                initialValue: _selectedBankId,
                decoration:
                    const InputDecoration(labelText: AppStrings.banco),
                dropdownColor: AppColors.cardDark,
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Nenhum')),
                  ...banks.map((b) => DropdownMenuItem<int?>(
                        value: b.id,
                        child: Text(b.nome),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedBankId = v),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text(AppStrings.salvar),
          ),
        ],
      ),
    );
  }
}
