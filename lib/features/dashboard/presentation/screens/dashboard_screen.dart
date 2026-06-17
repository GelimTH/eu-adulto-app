import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../shared/providers/tutorial_providers.dart';
import '../providers/dashboard_provider.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../tutorial/dashboard_tutorial.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _tutorialShowing = false;

  void _maybeShowTutorial() {
    final prefs = ref.read(sharedPreferencesProvider);
    if (isTutorialCompleted(prefs, 'dashboard')) return;
    if (_tutorialShowing) return;
    _tutorialShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targets = buildDashboardTargets();
      if (targets.isEmpty) return;

      TutorialCoachMark(
        targets: targets,
        colorShadow: const Color(0xFF0F1923),
        opacityShadow: 0.9,
        textSkip: 'PULAR',
        textStyleSkip: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        paddingFocus: 8,
        beforeFocus: scrollToTarget,
        onFinish: () {
          _tutorialShowing = false;
          markTutorialCompleted(prefs, 'dashboard');
        },
        onSkip: () {
          _tutorialShowing = false;
          markTutorialCompleted(prefs, 'dashboard');
          return true;
        },
      ).show(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    ref.listen<AsyncValue<DashboardSummaryEntity?>>(dashboardProvider,
        (prev, next) {
      if (next.hasValue && next.value != null) {
        _maybeShowTutorial();
      }
    });

    return Scaffold(
      body: dashboardAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (summary) {
          if (summary == null) return const SizedBox();
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardDark,
            onRefresh: () => ref.refresh(dashboardProvider.future),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverHeader(context, summary, topPadding),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      _buildFinancialShortcuts(context),
                      const SizedBox(height: 20),
                      _buildBudgetRule(summary),
                      const SizedBox(height: 16),
                      _buildHealthAndReserveRow(summary),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 16),
                      _GoalsPreviewCard(
                          key: DashboardTutorialKeys.goalsPreview),
                      const SizedBox(height: 16),
                      _RecentExpensesCard(
                          key: DashboardTutorialKeys.recentExpenses),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(
      BuildContext context, DashboardSummaryEntity summary, double topPadding) {
    final isPositive = summary.saldoDisponivel >= 0;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bom dia'
        : hour < 18
            ? 'Boa tarde'
            : 'Boa noite';

    return SliverAppBar(
      expandedHeight: topPadding + 216.0,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D2137), Color(0xFF0F1923)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, ${summary.nomeUsuario.split(' ').first} 👋',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 2),
                        Text(DateTime.now().mesAno,
                            style: AppTextStyles.caption),
                      ],
                    ),
                    _HealthBadge(
                      key: DashboardTutorialKeys.healthBadge,
                      score: summary.pontuacaoSaude,
                      label: summary.healthScore.label,
                      healthScore: summary.healthScore,
                      onTap: () => context.push('/health-score'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(AppStrings.saldoDisponivel,
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  summary.saldoDisponivel.brl,
                  style: AppTextStyles.moneyLarge.copyWith(
                    color:
                        isPositive ? AppColors.textPrimary : AppColors.error,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _BalancePill(
                        label: 'Renda',
                        value: summary.salarioMensal.brl,
                        color: AppColors.primary,
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(width: 8),
                      _BalancePill(
                        label: 'Gastos',
                        value: summary.totalGastos.brl,
                        color: AppColors.error,
                        icon: Icons.trending_down,
                      ),
                      const SizedBox(width: 8),
                      _BalancePill(
                        label: 'Dívidas/mês',
                        value: summary.parcelaMensalDividas.brl,
                        color: AppColors.warning,
                        icon: Icons.credit_card_outlined,
                      ),
                      if (summary.mensalidadeAssinaturas > 0) ...[
                        const SizedBox(width: 8),
                        _BalancePill(
                          label: 'Planos/mês',
                          value: summary.mensalidadeAssinaturas.brl,
                          color: AppColors.info,
                          icon: Icons.subscriptions_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetRule(DashboardSummaryEntity summary) {
    return Container(
      key: DashboardTutorialKeys.budgetRule,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${summary.percentualNecessidades.toInt()}/${summary.percentualObjetivos.toInt()}/${summary.percentualReserva.toInt()}',
                style: AppTextStyles.heading3,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Distribuição',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BudgetBar(
            emoji: '🏠',
            label: 'Necessidades',
            spent: summary.totalNecessidades + summary.parcelaMensalDividas,
            limit: summary.limiteNecessidades,
            color: AppColors.necessidades,
          ),
          const SizedBox(height: 12),
          _BudgetBar(
            emoji: '🎯',
            label: 'Estilo de vida',
            spent: summary.totalEstiloVida +
                summary.parcelaMensalParcelamentos +
                summary.mensalidadeAssinaturas,
            limit: summary.limiteObjetivos,
            color: AppColors.objetivos,
          ),
          const SizedBox(height: 12),
          _BudgetBar(
            emoji: '💰',
            label: 'Reserva',
            spent: summary.reservaAtual.clamp(0.0, summary.limiteReserva),
            limit: summary.limiteReserva,
            color: AppColors.reserva,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAndReserveRow(DashboardSummaryEntity summary) {
    return Row(
      key: DashboardTutorialKeys.healthAndReserve,
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Dívidas',
            value: summary.totalDividas.brlCompact,
            icon: Icons.credit_card_off_outlined,
            color: AppColors.error,
            subtitle: summary.totalDividas == 0
                ? 'Livre de dívidas 🎉'
                : 'Total em aberto',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Reserva',
            value: summary.reservaAtual.brlCompact,
            icon: Icons.savings_outlined,
            color: AppColors.reserva,
            subtitle:
                summary.reservaAtual == 0 ? 'Comece hoje!' : 'Guardado',
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialShortcuts(BuildContext context) {
    const shortcuts = [
      (
        label: 'Dívidas',
        icon: Icons.credit_card_off_outlined,
        color: AppColors.error,
        route: '/debts'
      ),
      (
        label: 'Bancos',
        icon: Icons.account_balance_outlined,
        color: AppColors.secondary,
        route: '/banks'
      ),
      (
        label: 'Cartões',
        icon: Icons.credit_card_outlined,
        color: AppColors.info,
        route: '/cards'
      ),
      (
        label: 'Parcelas',
        icon: Icons.receipt_long_outlined,
        color: AppColors.warning,
        route: '/installments'
      ),
    ];

    return Column(
      key: DashboardTutorialKeys.financialShortcuts,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acesso rápido', style: AppTextStyles.label),
        const SizedBox(height: 12),
        Row(
          children: shortcuts.map((s) {
            return Expanded(
              child: GestureDetector(
                onTap: () => context.push(s.route),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: s.color.withValues(alpha: 0.22)),
                      ),
                      child: Icon(s.icon, color: s.color, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.label,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      key: DashboardTutorialKeys.quickActions,
      children: [
        Expanded(
          child: _QuickActionButton(
            label: '+ Gasto',
            icon: Icons.receipt_long_outlined,
            color: AppColors.error,
            onTap: () => context.push('/expenses/add'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            label: '+ Dívida',
            icon: Icons.credit_card_outlined,
            color: AppColors.warning,
            onTap: () => context.push('/debts/add'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            label: 'Reserva',
            icon: Icons.savings_outlined,
            color: AppColors.reserva,
            onTap: () => context.push('/reserve'),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets como ConsumerWidget próprios ──────────────────────────────
// Rebuild isolado: cada um só reconstrói quando o seu próprio provider muda.

class _GoalsPreviewCard extends ConsumerWidget {
  const _GoalsPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    return goalsAsync.when(
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
      data: (goals) {
        final active = goals.where((g) => !g.concluida).take(2).toList();
        if (active.isEmpty) return const SizedBox();

        return GestureDetector(
          onTap: () => context.go('/goals'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.flag_outlined,
                          color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text('Metas', style: AppTextStyles.heading3),
                    ]),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textMuted, size: 18),
                  ],
                ),
                const SizedBox(height: 14),
                ...active.map((goal) {
                  final pct =
                      (goal.percentualConcluido / 100).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(goal.nome,
                                  style: AppTextStyles.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              '${goal.percentualConcluido.toInt()}%',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _ProgressBar(pct: pct, color: AppColors.secondary),
                        const SizedBox(height: 4),
                        Text(
                          '${goal.valorAtual.brlCompact} de ${goal.valorAlvo.brlCompact}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentExpensesCard extends ConsumerWidget {
  const _RecentExpensesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesNotifierProvider);
    return expensesAsync.when(
      skipLoadingOnReload: true,
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
      data: (expenses) {
        if (expenses.isEmpty) return const SizedBox();
        final recent = expenses.take(4).toList();
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.receipt_long_outlined,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('Últimos Gastos', style: AppTextStyles.heading3),
                  ]),
                  GestureDetector(
                    onTap: () => context.go('/expenses'),
                    child: Text('Ver todos',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...recent.map((e) => _RecentExpenseRow(expense: e)),
            ],
          ),
        );
      },
    );
  }
}

// ─── Widgets de exibição (todos StatelessWidget, sem estado nem providers) ──

class _ProgressBar extends StatelessWidget {
  final double pct;
  final Color color;

  const _ProgressBar({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: pct,
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: 6,
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  final String emoji;
  final String label;
  final double spent;
  final double limit;
  final Color color;

  const _BudgetBar({
    required this.emoji,
    required this.label,
    required this.spent,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver = pct >= 1.0;
    final barColor = pct >= 0.9 ? AppColors.error : color;

    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: spent.brlCompact,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        isOver ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' / ${limit.brlCompact}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _ProgressBar(pct: pct, color: barColor),
      ],
    );
  }
}

class _BalancePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _BalancePill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary)),
              Text(value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption),
          ]),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.moneyMedium.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _RecentExpenseRow extends StatelessWidget {
  final ExpenseEntity expense;

  const _RecentExpenseRow({required this.expense});

  static const _emojiMap = {
    ExpenseCategory.alimentacao: '🍔',
    ExpenseCategory.transporte: '🚗',
    ExpenseCategory.saude: '💊',
    ExpenseCategory.educacao: '📚',
    ExpenseCategory.lazer: '🎮',
    ExpenseCategory.moradia: '🏠',
    ExpenseCategory.vestuario: '👕',
    ExpenseCategory.outros: '📦',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(_emojiMap[expense.categoria] ?? '📦',
              style: const TextStyle(fontSize: 20)),
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
                Text(expense.data.ddMMM, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(expense.valor.brl,
              style: AppTextStyles.moneySmall
                  .copyWith(color: AppColors.error)),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final int score;
  final String label;
  final HealthScore healthScore;
  final VoidCallback? onTap;

  const _HealthBadge({
    super.key,
    required this.score,
    required this.label,
    required this.healthScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (healthScore) {
      HealthScore.excelente => AppColors.scoreExcelente,
      HealthScore.saudavel => AppColors.scoreSaudavel,
      HealthScore.atencao => AppColors.scoreAtencao,
      HealthScore.preocupante => AppColors.scorePreocupante,
      HealthScore.critico => AppColors.scoreCritico,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$score',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saúde',
                    style: TextStyle(
                        fontSize: 9, color: AppColors.textSecondary)),
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
