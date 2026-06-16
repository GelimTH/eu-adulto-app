import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../providers/goals_provider.dart';
import '../../domain/entities/goal_entity.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.metas),
      ),
      body: goalsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyStateWidget(
              message: 'Defina suas metas financeiras.',
              actionLabel: AppStrings.novaMeta,
              icon: Icons.flag_outlined,
              onAction: () => _showGoalForm(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: goals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _GoalCard(goal: goals[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalForm(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.flag_outlined, color: Colors.white),
        label: const Text('Nova Meta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showGoalForm(BuildContext context, WidgetRef ref, [GoalEntity? goal]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GoalFormSheet(ref: ref, goal: goal),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final GoalEntity goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = goal.percentualConcluido / 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: goal.concluida
            ? Border.all(color: AppColors.success.withValues(alpha: 0.4))
            : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (goal.concluida) ...[
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  goal.nome,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.cardDarkAlt,
                padding: EdgeInsets.zero,
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showGoalForm(context, ref, goal);
                  } else if (value == 'delete') {
                    final confirmed = await ConfirmationDialog.show(context);
                    if (confirmed && goal.id != null) {
                      ref.read(goalsNotifierProvider.notifier).delete(goal.id!);
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
                child: const Icon(Icons.more_vert,
                    color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: pct.clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            progressColor: goal.concluida ? AppColors.success : AppColors.secondary,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: goal.valorAtual.brlCompact,
                        style: AppTextStyles.moneySmall.copyWith(
                          color: goal.concluida
                              ? AppColors.success
                              : AppColors.secondary,
                        ),
                      ),
                      TextSpan(
                        text: ' de ${goal.valorAlvo.brlCompact}',
                        style: AppTextStyles.caption,
                      ),
                    ]),
                  ),
                  if (goal.prazo != null)
                    Text('Prazo: ${goal.prazo!.ddMMyyyy}',
                        style: AppTextStyles.caption),
                ],
              ),
              if (!goal.concluida)
                GestureDetector(
                  onTap: () => _showContributeSheet(context, ref, goal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add,
                            color: AppColors.secondary, size: 16),
                        const SizedBox(width: 4),
                        const Text('Contribuir',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Concluída 🎉',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGoalForm(BuildContext context, WidgetRef ref, [GoalEntity? g]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GoalFormSheet(ref: ref, goal: g),
    );
  }

  void _showContributeSheet(
      BuildContext context, WidgetRef ref, GoalEntity goal) {
    final controller = TextEditingController();
    final faltante = goal.valorFaltante;

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
            Row(
              children: [
                const Icon(Icons.savings_outlined,
                    color: AppColors.secondary, size: 20),
                const SizedBox(width: 10),
                Text('Contribuir para', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 4),
            Text(goal.nome, style: AppTextStyles.bodyMuted),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Falta ainda', style: AppTextStyles.caption),
                  Text(faltante.brl,
                      style: AppTextStyles.moneySmall
                          .copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
              style: AppTextStyles.moneyMedium,
              decoration: const InputDecoration(
                labelText: 'Quanto quer adicionar?',
                prefixText: 'R\$ ',
                hintText: '0,00',
              ),
            ),
            const SizedBox(height: 12),
            // Atalhos rápidos
            Wrap(
              spacing: 8,
              children: [50.0, 100.0, 200.0, faltante]
                  .where((v) => v > 0 && v <= faltante)
                  .map((v) => GestureDetector(
                        onTap: () {
                          controller.text =
                              v.toStringAsFixed(2).replaceAll('.', ',');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            v == faltante ? 'Tudo (${v.brlCompact})' : v.brlCompact,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final valor = controller.text.parseBrl;
                if (valor > 0) {
                  ref
                      .read(goalsNotifierProvider.notifier)
                      .addToGoal(goal, valor);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text(AppStrings.confirmar),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalFormSheet extends StatefulWidget {
  final WidgetRef ref;
  final GoalEntity? goal;

  const _GoalFormSheet({required this.ref, this.goal});

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime? _prazo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nomeController.text = widget.goal!.nome;
      _valorController.text =
          widget.goal!.valorAlvo.toStringAsFixed(2).replaceAll('.', ',');
      _prazo = widget.goal!.prazo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nomeController.text.isEmpty || _valorController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final goal = GoalEntity(
      id: widget.goal?.id,
      nome: _nomeController.text.trim(),
      valorAlvo: _valorController.text.parseBrl,
      valorAtual: widget.goal?.valorAtual ?? 0,
      prazo: _prazo,
      dataCriacao: widget.goal?.dataCriacao ?? DateTime.now(),
    );

    if (widget.goal != null) {
      await widget.ref.read(goalsNotifierProvider.notifier).editItem(goal);
    } else {
      await widget.ref.read(goalsNotifierProvider.notifier).add(goal);
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
            widget.goal != null ? 'Editar Meta' : AppStrings.novaMeta,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome da meta'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _valorController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
            ],
            decoration: const InputDecoration(
              labelText: AppStrings.valorAlvo,
              prefixText: 'R\$ ',
              hintText: '0,00',
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _prazo ??
                    DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2040),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(
                        primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _prazo = picked);
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
                    _prazo != null ? _prazo!.ddMMyyyy : AppStrings.semPrazo,
                    style: AppTextStyles.body,
                  ),
                  const Spacer(),
                  if (_prazo != null)
                    GestureDetector(
                      onTap: () => setState(() => _prazo = null),
                      child: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 16),
                    ),
                ],
              ),
            ),
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
