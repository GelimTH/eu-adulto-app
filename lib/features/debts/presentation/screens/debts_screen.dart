import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../providers/debts_provider.dart';
import '../../domain/entities/debt_entity.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsNotifierProvider);
    final totalAsync = ref.watch(totalDebtProvider);
    final monthlyAsync = ref.watch(monthlyDebtPaymentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.novasDividas),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => context.push('/debts/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(totalAsync, monthlyAsync),
          Expanded(
            child: debtsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (debts) {
                if (debts.isEmpty) {
                  return EmptyStateWidget(
                    message: 'Nenhuma dívida cadastrada.',
                    actionLabel: AppStrings.novaDivida,
                    icon: Icons.credit_card_off_outlined,
                    onAction: () => context.push('/debts/add'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: debts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _DebtCard(debt: debts[i], ref: ref, context: context),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/debts/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryHeader(
    AsyncValue<double> totalAsync,
    AsyncValue<double> monthlyAsync,
  ) {
    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total em dívidas', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                totalAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (v) => Text(
                    v.brl,
                    style: AppTextStyles.moneyMedium.copyWith(
                        color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parcela mensal', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                monthlyAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (v) => Text(
                    v.brl,
                    style: AppTextStyles.moneyMedium.copyWith(
                        color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final DebtEntity debt;
  final WidgetRef ref;
  final BuildContext context;

  const _DebtCard({
    required this.debt,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final progress = debt.valorOriginal > 0
        ? 1 - (debt.valorRestante / debt.valorOriginal)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: (debt.tipo == DebtType.emprestimo
                                    ? AppColors.info
                                    : AppColors.error)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${debt.tipo.emoji} ${debt.tipo.label}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: debt.tipo == DebtType.emprestimo
                                  ? AppColors.info
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.descricao,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.cardDarkAlt,
                onSelected: (value) async {
                  if (value == 'edit') {
                    context.push('/debts/edit', extra: debt);
                  } else if (value == 'delete') {
                    final confirmed = await ConfirmationDialog.show(context);
                    if (confirmed && debt.id != null) {
                      ref.read(debtsNotifierProvider.notifier).delete(debt.id!);
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                label: 'Restante',
                value: debt.valorRestante.brl,
                valueColor: AppColors.error,
              ),
              _buildInfoItem(
                label: 'Parcela',
                value: debt.valorParcela.brl,
                valueColor: AppColors.warning,
              ),
              _buildInfoItem(
                label: 'Parcelas',
                value:
                    '${debt.parcelasRestantes}/${debt.parcelas}',
                valueColor: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% pago',
                style: AppTextStyles.caption,
              ),
              Text(
                'Quitação: ${debt.quitacaoPrevista.ddMMyyyy}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          if (debt.juros > 0) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showSimulation(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Juros: ${debt.juros}% a.m. · Economize ${debt.economiaAntecipacao.brl} antecipando',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calculate_outlined,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Simular',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSimulation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DebtSimulationSheet(debt: debt),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.moneySmall.copyWith(color: valueColor)),
      ],
    );
  }
}

class _DebtSimulationSheet extends StatefulWidget {
  final DebtEntity debt;

  const _DebtSimulationSheet({required this.debt});

  @override
  State<_DebtSimulationSheet> createState() => _DebtSimulationSheetState();
}

class _DebtSimulationSheetState extends State<_DebtSimulationSheet> {
  int _extraParcelas = 1;

  DebtEntity get debt => widget.debt;

  @override
  Widget build(BuildContext context) {
    final max = debt.parcelasRestantes;
    if (max <= 0) return const SizedBox();

    final extraPayment = _extraParcelas * debt.valorParcela;
    final newValorRestante =
        (debt.valorRestante - extraPayment).clamp(0.0, double.infinity);
    final newParcelasRestantes = (debt.parcelasRestantes - _extraParcelas)
        .clamp(0, debt.parcelasRestantes);

    final taxa = debt.juros / 100;
    final jurosAtual =
        debt.valorRestante * taxa * debt.parcelasRestantes;
    final jurosNovo = newValorRestante * taxa * newParcelasRestantes;
    final economia = (jurosAtual - jurosNovo).clamp(0.0, double.infinity);

    final newQuitacao = DateTime(
      debt.dataInicio.year,
      debt.dataInicio.month + newParcelasRestantes,
      debt.dataInicio.day,
    );

    final isQuitando = _extraParcelas >= max;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Simular Antecipação',
                  style: AppTextStyles.heading3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            debt.descricao,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Parcelas a antecipar', style: AppTextStyles.label),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isQuitando ? 'Quitar tudo' : '$_extraParcelas',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.warning,
              thumbColor: AppColors.warning,
              inactiveTrackColor: AppColors.border,
              overlayColor: AppColors.warning.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _extraParcelas.toDouble(),
              min: 1,
              max: max.toDouble(),
              divisions: max > 1 ? max - 1 : 1,
              onChanged: (v) => setState(() => _extraParcelas = v.round()),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _SimRow(
                  label: 'Pagamento extra agora',
                  value: extraPayment.brl,
                  valueColor: AppColors.error,
                ),
                const SizedBox(height: 12),
                _SimRow(
                  label: 'Parcelas restantes',
                  value: isQuitando
                      ? 'Dívida quitada!'
                      : '${debt.parcelasRestantes} → $newParcelasRestantes',
                  valueColor:
                      isQuitando ? AppColors.success : AppColors.textPrimary,
                ),
                const SizedBox(height: 12),
                _SimRow(
                  label: 'Nova quitação prevista',
                  value: isQuitando
                      ? 'Imediata'
                      : newQuitacao.ddMMyyyy,
                  valueColor: AppColors.success,
                ),
                const SizedBox(height: 12),
                _SimRow(
                  label: 'Economia em juros',
                  value: economia.brl,
                  valueColor: AppColors.success,
                  highlight: true,
                ),
              ],
            ),
          ),
          if (isQuitando) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quitando tudo agora você economiza ${economia.brl} em juros e fica livre da dívida!',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SimRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool highlight;

  const _SimRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(
          value,
          style: highlight
              ? AppTextStyles.moneySmall.copyWith(
                  color: valueColor, fontWeight: FontWeight.w700)
              : AppTextStyles.body.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
