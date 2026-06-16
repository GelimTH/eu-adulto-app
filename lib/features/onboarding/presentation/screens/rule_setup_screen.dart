import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/onboarding_provider.dart';

class RuleSetupScreen extends ConsumerStatefulWidget {
  const RuleSetupScreen({super.key});

  @override
  ConsumerState<RuleSetupScreen> createState() => _RuleSetupScreenState();
}

class _RuleSetupScreenState extends ConsumerState<RuleSetupScreen> {
  double _necessidades = 60;
  double _objetivos = 30;
  double _reserva = 10;

  static const _presets = [
    (label: 'Conservador', n: 70.0, o: 20.0, r: 10.0),
    (label: 'Equilibrado', n: 60.0, o: 30.0, r: 10.0),
    (label: 'Investidor', n: 50.0, o: 30.0, r: 20.0),
  ];

  void _onNecessidadesChanged(double v) {
    setState(() {
      _necessidades = v;
      final maxO = (100 - v - 5).clamp(5.0, 85.0);
      if (_objetivos > maxO) _objetivos = maxO;
      _reserva = 100 - _necessidades - _objetivos;
    });
  }

  void _onObjetivosChanged(double v) {
    setState(() {
      _objetivos = v;
      _reserva = 100 - _necessidades - v;
    });
  }

  void _applyPreset(double n, double o, double r) {
    setState(() {
      _necessidades = n;
      _objetivos = o;
      _reserva = r;
    });
  }

  Future<void> _finish() async {
    ref.read(onboardingProvider.notifier).setPercentuais(
          necessidades: _necessidades,
          objetivos: _objetivos,
          reserva: _reserva,
        );
    await ref.read(onboardingProvider.notifier).save();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final salario = state.salarioMensal;

    ref.listen(onboardingProvider, (_, next) {
      if (next.saved) context.go('/home');
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/onboarding/salary'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(AppStrings.ruleTitle, style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(AppStrings.ruleSubtitle, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),

              // Visual bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 12,
                  child: Row(children: [
                    Flexible(
                      flex: _necessidades.toInt(),
                      child: Container(color: AppColors.necessidades),
                    ),
                    Flexible(
                      flex: _objetivos.toInt(),
                      child: Container(color: AppColors.objetivos),
                    ),
                    Flexible(
                      flex: _reserva.toInt(),
                      child: Container(color: AppColors.reserva),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LegendItem(AppColors.necessidades, '🏠 ${_necessidades.toInt()}%'),
                  _LegendItem(AppColors.objetivos, '🎯 ${_objetivos.toInt()}%'),
                  _LegendItem(AppColors.reserva, '💰 ${_reserva.toInt()}%'),
                ],
              ),
              const SizedBox(height: 24),

              // Presets
              Row(
                children: _presets.map((p) {
                  final isSelected = _necessidades == p.n &&
                      _objetivos == p.o &&
                      _reserva == p.r;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _applyPreset(p.n, p.o, p.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                p.label,
                                style: AppTextStyles.caption.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${p.n.toInt()}/${p.o.toInt()}/${p.r.toInt()}',
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Slider: Necessidades
              _buildSlider(
                emoji: '🏠',
                label: AppStrings.necessidades,
                value: _necessidades,
                min: 5,
                max: 90,
                color: AppColors.necessidades,
                salario: salario,
                onChanged: _onNecessidadesChanged,
              ),
              const SizedBox(height: 20),

              // Slider: Estilo de vida
              _buildSlider(
                emoji: '🎯',
                label: AppStrings.objetivos,
                value: _objetivos,
                min: 5,
                max: (100 - _necessidades - 5).clamp(5.0, 85.0),
                color: AppColors.objetivos,
                salario: salario,
                onChanged: _onObjetivosChanged,
              ),
              const SizedBox(height: 16),

              // Reserva: computed display
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.reserva.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.reserva.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.reserva, style: AppTextStyles.body),
                        if (salario > 0)
                          Text(
                            (salario * _reserva / 100).brl,
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${_reserva.toInt()}%',
                      style: AppTextStyles.heading3
                          .copyWith(color: AppColors.reserva),
                    ),
                    const SizedBox(width: 4),
                    Text('automático',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted, fontSize: 9)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              AppButton(
                label: AppStrings.comecar,
                isLoading: state.isLoading,
                onPressed: _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String emoji,
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required double salario,
    required ValueChanged<double> onChanged,
  }) {
    final safeMax = max.clamp(min, 90.0);
    final safeValue = value.clamp(min, safeMax);
    final divisions = ((safeMax - min)).round().clamp(1, 85);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.subtitle),
            const Spacer(),
            Text(
              '${safeValue.toInt()}%',
              style: AppTextStyles.heading3.copyWith(color: color),
            ),
          ],
        ),
        if (salario > 0)
          Text(
            (salario * safeValue / 100).brl,
            style: AppTextStyles.caption,
          ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: AppColors.border,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: safeValue,
            min: min,
            max: safeMax,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem(this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}
