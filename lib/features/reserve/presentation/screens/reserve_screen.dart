import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../providers/reserve_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class ReserveScreen extends ConsumerWidget {
  const ReserveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reserveAsync = ref.watch(reserveNotifierProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva de Emergência'),
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      body: reserveAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (reserve) {
          final salario = userAsync.value?.salarioMensal ?? 0;
          final valorAtual = reserve?.valorAtual ?? 0;
          final metaIdeal = salario * 6;
          final pct = metaIdeal > 0
              ? (valorAtual / metaIdeal).clamp(0.0, 1.0)
              : 0.0;
          final falta = (metaIdeal - valorAtual).clamp(0.0, double.infinity);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReserveProgressCard(
                  valorAtual: valorAtual,
                  metaIdeal: metaIdeal,
                  salario: salario,
                  pct: pct,
                  falta: falta,
                ),
                const SizedBox(height: 20),
                _QuickAddSection(
                  valorAtual: valorAtual,
                  falta: falta,
                  onAdd: (valor) {
                    ref
                        .read(reserveNotifierProvider.notifier)
                        .addToReserve(valor);
                  },
                ),
                const SizedBox(height: 20),
                _SetTotalButton(
                  valorAtual: valorAtual,
                  onUpdate: (valor) {
                    ref
                        .read(reserveNotifierProvider.notifier)
                        .updateReserve(valor);
                  },
                ),
                const SizedBox(height: 24),
                _InfoCard(salario: salario),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReserveProgressCard extends StatelessWidget {
  final double valorAtual;
  final double metaIdeal;
  final double salario;
  final double pct;
  final double falta;

  const _ReserveProgressCard({
    required this.valorAtual,
    required this.metaIdeal,
    required this.salario,
    required this.pct,
    required this.falta,
  });

  @override
  Widget build(BuildContext context) {
    final completed = pct >= 1.0;
    final color = completed ? AppColors.success : AppColors.reserva;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: completed
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserva atual', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    valorAtual.brl,
                    style: AppTextStyles.moneyLarge.copyWith(color: color),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  completed ? Icons.check_circle_outline : Icons.savings_outlined,
                  color: color,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(pct * 100).toInt()}% da meta',
                style: AppTextStyles.body.copyWith(
                    color: color, fontWeight: FontWeight.w600),
              ),
              Text(
                'Meta: ${metaIdeal.brlCompact}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 12,
            percent: pct,
            backgroundColor: AppColors.border,
            progressColor: color,
            barRadius: const Radius.circular(6),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: completed
                ? Row(children: [
                    const Icon(Icons.celebration,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Text('Parabéns! Meta atingida 🎉',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.success)),
                  ])
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ainda falta', style: AppTextStyles.caption),
                      Text(
                        falta.brl,
                        style: AppTextStyles.moneySmall
                            .copyWith(color: AppColors.reserva),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddSection extends StatelessWidget {
  final double valorAtual;
  final double falta;
  final void Function(double) onAdd;

  const _QuickAddSection({
    required this.valorAtual,
    required this.falta,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    const chips = [50.0, 100.0, 200.0, 500.0];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Adicionar à reserva', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...chips.map((v) => _QuickChip(
                    label: '+${v.brlCompact}',
                    onTap: () => onAdd(v),
                  )),
              if (falta > 0)
                _QuickChip(
                  label: 'Completar tudo',
                  onTap: () => onAdd(falta),
                  highlight: true,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _CustomAmountField(
            hint: 'Outro valor',
            onConfirm: onAdd,
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _QuickChip(
      {required this.label, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.success : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _CustomAmountField extends StatefulWidget {
  final String hint;
  final void Function(double) onConfirm;

  const _CustomAmountField({required this.hint, required this.onConfirm});

  @override
  State<_CustomAmountField> createState() => _CustomAmountFieldState();
}

class _CustomAmountFieldState extends State<_CustomAmountField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
            ],
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixText: 'R\$ ',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _confirm,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  void _confirm() {
    final valor = _controller.text.parseBrl;
    if (valor > 0) {
      widget.onConfirm(valor);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }
}

class _SetTotalButton extends StatelessWidget {
  final double valorAtual;
  final void Function(double) onUpdate;

  const _SetTotalButton(
      {required this.valorAtual, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showSheet(context),
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: const Text('Definir valor total da reserva'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final controller = TextEditingController(
      text: valorAtual > 0
          ? valorAtual.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Definir total da reserva', style: AppTextStyles.heading3),
            const SizedBox(height: 6),
            Text(
              'Use quando já tem uma reserva formada e quer registrar o valor total.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
              style: AppTextStyles.moneyMedium,
              decoration: const InputDecoration(
                labelText: 'Valor total atual',
                prefixText: 'R\$ ',
                hintText: '0,00',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final valor = controller.text.parseBrl;
                if (valor >= 0) {
                  onUpdate(valor);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text(AppStrings.salvar),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final double salario;

  const _InfoCard({required this.salario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.reserva.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.reserva.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.reserva, size: 16),
              const SizedBox(width: 8),
              Text('O que é reserva de emergência?',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.reserva,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'É o dinheiro guardado para imprevistos — perda de emprego, despesa médica ou emergência familiar. A regra é ter pelo menos 6x a sua renda mensal guardada.',
            style: AppTextStyles.caption,
          ),
          if (salario > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sua meta ideal (6x renda)',
                      style: AppTextStyles.caption),
                  Text(
                    (salario * 6).brl,
                    style: AppTextStyles.moneySmall
                        .copyWith(color: AppColors.reserva),
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
