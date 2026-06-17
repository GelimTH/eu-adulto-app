import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/onboarding_provider.dart';

class NameSetupScreen extends ConsumerStatefulWidget {
  const NameSetupScreen({super.key});

  @override
  ConsumerState<NameSetupScreen> createState() => _NameSetupScreenState();
}

class _NameSetupScreenState extends ConsumerState<NameSetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(onboardingProvider.notifier).setName(_controller.text.trim());
    context.go('/onboarding/salary');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(AppStrings.nameQuestion,
                          style: AppTextStyles.heading2),
                      const SizedBox(height: 8),
                      Text(
                        'Vamos personalizar sua experiência.',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        label: AppStrings.nameHint,
                        controller: _controller,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.campoObrigatorio;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AppButton(
                  label: AppStrings.continuar,
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
