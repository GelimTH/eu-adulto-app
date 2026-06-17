import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../shared/providers/tutorial_providers.dart';
import '../../../onboarding/domain/entities/user_entity.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          userAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (user) {
              if (user == null) return const SizedBox();
              return _UserProfileCard(user: user);
            },
          ),
          const SizedBox(height: 28),
          Text('Ferramentas', style: AppTextStyles.label),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _FeatureCard(
                icon: Icons.credit_card_off_outlined,
                label: 'Dívidas',
                description: 'Gerencie suas dívidas',
                color: AppColors.error,
                route: '/debts',
              ),
              _FeatureCard(
                icon: Icons.account_balance_outlined,
                label: 'Bancos',
                description: 'Suas contas bancárias',
                color: AppColors.secondary,
                route: '/banks',
              ),
              _FeatureCard(
                icon: Icons.credit_card_outlined,
                label: 'Cartões',
                description: 'Limites e faturas',
                color: AppColors.info,
                route: '/cards',
              ),
              _FeatureCard(
                icon: Icons.receipt_long_outlined,
                label: 'Parcelamentos',
                description: 'Compras parceladas',
                color: AppColors.warning,
                route: '/installments',
              ),
              _FeatureCard(
                icon: Icons.savings_outlined,
                label: 'Reserva',
                description: 'Seu fundo de emergência',
                color: AppColors.reserva,
                route: '/reserve',
              ),
              _FeatureCard(
                icon: Icons.settings_outlined,
                label: 'Configurações',
                description: 'Perfil e preferências',
                color: AppColors.textSecondary,
                route: '/settings',
              ),
            ],
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () async {
              final prefs = ref.read(sharedPreferencesProvider);
              await resetAllTutorials(prefs);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tutorial será exibido ao voltar para o Início'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rever tutorial',
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Exibir o guia interativo novamente',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  final UserEntity user;

  const _UserProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.nome[0].toUpperCase(),
                style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.nome, style: AppTextStyles.heading3),
              Text(user.salarioMensal.brl, style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted),
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final String route;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
