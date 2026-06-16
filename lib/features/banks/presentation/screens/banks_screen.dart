import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../providers/banks_provider.dart';
import '../../domain/entities/bank_entity.dart';
import '../../../debts/presentation/providers/debts_provider.dart';

class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banksAsync = ref.watch(banksNotifierProvider);
    final debts = ref.watch(debtsNotifierProvider).value ?? [];
    final totalDebts =
        debts.fold(0.0, (sum, d) => sum + d.valorRestante);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bancos),
        leading: Navigator.canPop(context)
            ? const BackButton()
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => _showBankSheet(context, ref),
          ),
        ],
      ),
      body: banksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (banks) {
          if (banks.isEmpty) {
            return EmptyStateWidget(
              message: 'Nenhum banco cadastrado.',
              actionLabel: AppStrings.novoBanco,
              icon: Icons.account_balance_outlined,
              onAction: () => _showBankSheet(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: banks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final bank = banks[i];
              final bankDebts =
                  debts.where((d) => d.bancoId == bank.id).toList();
              final bankDebtTotal =
                  bankDebts.fold(0.0, (sum, d) => sum + d.valorRestante);
              final debtPct = totalDebts > 0
                  ? (bankDebtTotal / totalDebts * 100)
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_outlined,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(bank.nome, style: AppTextStyles.body),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.textMuted, size: 20),
                          onPressed: () => _showBankSheet(context, ref, bank),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error, size: 20),
                          onPressed: () async {
                            final confirmed =
                                await ConfirmationDialog.show(context);
                            if (confirmed && bank.id != null) {
                              ref
                                  .read(banksNotifierProvider.notifier)
                                  .delete(bank.id!);
                            }
                          },
                        ),
                      ],
                    ),
                    if (bankDebtTotal > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_outlined,
                                    size: 14, color: AppColors.error),
                                const SizedBox(width: 6),
                                Text(
                                  'Dívida vinculada',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.error),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  bankDebtTotal.brl,
                                  style: AppTextStyles.moneySmall
                                      .copyWith(color: AppColors.error),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.error.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${debtPct.toStringAsFixed(0)}% do total',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBankSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBankSheet(BuildContext context, WidgetRef ref, [BankEntity? bank]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BankFormSheet(ref: ref, bank: bank),
    );
  }
}

class _BankFormSheet extends StatefulWidget {
  final WidgetRef ref;
  final BankEntity? bank;

  const _BankFormSheet({required this.ref, this.bank});

  @override
  State<_BankFormSheet> createState() => _BankFormSheetState();
}

class _BankFormSheetState extends State<_BankFormSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bank != null) {
      _controller.text = widget.bank!.nome;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final bank = BankEntity(
      id: widget.bank?.id,
      nome: _controller.text.trim(),
    );

    if (widget.bank != null) {
      await widget.ref.read(banksNotifierProvider.notifier).editItem(bank);
    } else {
      await widget.ref.read(banksNotifierProvider.notifier).add(bank);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.bank != null ? 'Editar Banco' : AppStrings.novoBanco,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: AppStrings.nomeBanco),
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
