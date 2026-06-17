import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../providers/dashboard_provider.dart';

class HealthScoreScreen extends ConsumerWidget {
  const HealthScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Saúde Financeira'),
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (summary) {
          if (summary == null) return const SizedBox();
          final breakdown = summary.scoreBreakdown;
          final color = _scoreColor(breakdown.healthScore);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              children: [
                _ScoreHeader(
                  score: breakdown.pontuacaoTotal,
                  label: breakdown.healthScore.label,
                  color: color,
                ),
                const SizedBox(height: 24),
                ...breakdown.fatores.map((fator) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _FatorCard(fator: fator),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  static Color _scoreColor(HealthScore score) {
    return switch (score) {
      HealthScore.excelente => AppColors.scoreExcelente,
      HealthScore.saudavel => AppColors.scoreSaudavel,
      HealthScore.atencao => AppColors.scoreAtencao,
      HealthScore.preocupante => AppColors.scorePreocupante,
      HealthScore.critico => AppColors.scoreCritico,
    };
  }
}

class _ScoreHeader extends StatelessWidget {
  final int score;
  final String label;
  final Color color;

  const _ScoreHeader({
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
            ),
            child: Center(
              child: Text(
                '$score',
                style: AppTextStyles.moneyLarge.copyWith(
                  color: color,
                  fontSize: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'de 100 pontos',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _FatorCard extends StatelessWidget {
  final HealthScoreFator fator;

  const _FatorCard({required this.fator});

  @override
  Widget build(BuildContext context) {
    final pct = fator.percentual;
    final barColor = pct >= 0.7
        ? AppColors.success
        : pct >= 0.4
            ? AppColors.warning
            : AppColors.error;

    return Container(
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
              Expanded(
                child: Text(fator.nome, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${fator.pontos}/${fator.maximo}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(fator.descricao, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fator.dica,
                    style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.5),
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
