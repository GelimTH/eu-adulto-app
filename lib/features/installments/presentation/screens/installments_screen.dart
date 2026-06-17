import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../providers/installments_provider.dart';
import '../../domain/entities/installment_entity.dart';
import '../../../banks/presentation/providers/banks_provider.dart';
import '../../../cards/presentation/providers/cards_provider.dart';

class InstallmentsScreen extends ConsumerWidget {
  const InstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync = ref.watch(installmentsNotifierProvider);
    final monthlyAsync = ref.watch(monthlyInstallmentTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.parcelamentos),
        leading: Navigator.canPop(context) ? const BackButton() : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => _showAddSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          monthlyAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (total) => Container(
              color: AppColors.surfaceDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total mensal', style: AppTextStyles.caption),
                  Text(total.brl,
                      style: AppTextStyles.moneyMedium
                          .copyWith(color: AppColors.warning)),
                ],
              ),
            ),
          ),
          Expanded(
            child: installmentsAsync.when(
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    message: 'Nenhum parcelamento cadastrado.',
                    actionLabel: AppStrings.novoParcelamento,
                    icon: Icons.calendar_month_outlined,
                    onAction: () => _showAddSheet(context, ref),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _InstallmentCard(
                    item: items[i],
                    ref: ref,
                    onEdit: () => _showAddSheet(context, ref, items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref,
      [InstallmentEntity? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _InstallmentFormSheet(ref: ref, item: item),
    );
  }
}

class _InstallmentCard extends StatelessWidget {
  final InstallmentEntity item;
  final WidgetRef ref;
  final VoidCallback onEdit;

  const _InstallmentCard({
    required this.item,
    required this.ref,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = item.totalParcelas > 0
        ? (item.parcelaAtual - 1) / item.totalParcelas
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.descricao, style: AppTextStyles.heading3),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 18),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 18),
                onPressed: () async {
                  final confirmed = await ConfirmationDialog.show(context);
                  if (confirmed && item.id != null) {
                    ref
                        .read(installmentsNotifierProvider.notifier)
                        .delete(item.id!);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parcela ${item.parcelaAtual}/${item.totalParcelas}',
                style: AppTextStyles.body,
              ),
              Text(
                item.valorParcela.brl,
                style: AppTextStyles.moneySmall
                    .copyWith(color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Encerramento: ${item.encerramentoPrevisto.ddMMyyyy} · Restam ${item.valorRestante.brl}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _InstallmentFormSheet extends StatefulWidget {
  final WidgetRef ref;
  final InstallmentEntity? item;

  const _InstallmentFormSheet({required this.ref, this.item});

  @override
  State<_InstallmentFormSheet> createState() => _InstallmentFormSheetState();
}

class _InstallmentFormSheetState extends State<_InstallmentFormSheet> {
  final _descController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _parcelasController = TextEditingController();
  final _parcelaAtualController = TextEditingController();
  int? _selectedBankId;
  int? _selectedCardId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _descController.text = item.descricao;
      _valorTotalController.text =
          item.valorTotal.toStringAsFixed(2).replaceAll('.', ',');
      _parcelasController.text = item.totalParcelas.toString();
      _parcelaAtualController.text = item.parcelaAtual.toString();
      _selectedBankId = item.bancoId;
      _selectedCardId = item.cartaoId;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _valorTotalController.dispose();
    _parcelasController.dispose();
    _parcelaAtualController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_descController.text.isEmpty || _valorTotalController.text.isEmpty) {
      return;
    }
    setState(() => _isLoading = true);

    final valorTotal = _valorTotalController.text.parseBrl;
    final totalParcelas = int.tryParse(_parcelasController.text) ?? 1;
    final parcelaAtual = int.tryParse(_parcelaAtualController.text) ?? 1;

    final inst = InstallmentEntity(
      id: widget.item?.id,
      descricao: _descController.text.trim(),
      valorTotal: valorTotal,
      valorParcela: valorTotal / totalParcelas,
      parcelaAtual: parcelaAtual,
      totalParcelas: totalParcelas,
      bancoId: _selectedBankId,
      cartaoId: _selectedCardId,
      dataInicio: widget.item?.dataInicio ?? DateTime.now(),
    );

    if (widget.item != null) {
      await widget.ref
          .read(installmentsNotifierProvider.notifier)
          .editItem(inst);
    } else {
      await widget.ref
          .read(installmentsNotifierProvider.notifier)
          .add(inst);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildCardDropdown() {
    final cardsAsync = widget.ref.watch(cardsNotifierProvider);
    return cardsAsync.when(
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
      data: (cards) {
        if (cards.isEmpty) return const SizedBox();
        return DropdownButtonFormField<int?>(
          initialValue: _selectedCardId,
          decoration:
              const InputDecoration(labelText: AppStrings.cartao),
          dropdownColor: AppColors.cardDark,
          items: [
            const DropdownMenuItem<int?>(
                value: null, child: Text('Nenhum')),
            ...cards.map((c) => DropdownMenuItem<int?>(
                  value: c.id,
                  child: Text(c.nome),
                )),
          ],
          onChanged: (v) => setState(() => _selectedCardId = v),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = widget.ref.watch(banksNotifierProvider);
    final isEditing = widget.item != null;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Editar Parcelamento' : AppStrings.novoParcelamento,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            decoration:
                const InputDecoration(labelText: AppStrings.descricao),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valorTotalController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
            ],
            decoration:
                const InputDecoration(labelText: 'Valor Total', prefixText: 'R\$ '),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _parcelasController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      const InputDecoration(labelText: 'Total de Parcelas'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _parcelaAtualController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      const InputDecoration(labelText: 'Parcela Atual'),
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
          const SizedBox(height: 12),
          _buildCardDropdown(),
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
