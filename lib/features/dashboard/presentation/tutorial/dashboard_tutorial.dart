import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

abstract class DashboardTutorialKeys {
  static final healthBadge = GlobalKey();
  static final financialShortcuts = GlobalKey();
  static final budgetRule = GlobalKey();
  static final healthAndReserve = GlobalKey();
  static final quickActions = GlobalKey();
  static final goalsPreview = GlobalKey();
  static final recentExpenses = GlobalKey();
}

List<TargetFocus> buildDashboardTargets() {
  final targets = <TargetFocus>[];

  _addTarget(
    targets,
    key: DashboardTutorialKeys.healthBadge,
    identify: 'healthBadge',
    align: ContentAlign.bottom,
    shape: ShapeLightFocus.RRect,
    radius: 12,
    title: 'Saúde Financeira',
    description: 'Toque aqui para ver o detalhamento da sua pontuação de saúde financeira e dicas do que melhorar.',
  );

  _addTarget(
    targets,
    key: DashboardTutorialKeys.financialShortcuts,
    identify: 'financialShortcuts',
    align: ContentAlign.bottom,
    shape: ShapeLightFocus.RRect,
    radius: 16,
    title: 'Acesso Rápido',
    description: 'Atalhos para gerenciar dívidas, bancos, cartões e parcelas.',
  );

  _addTarget(
    targets,
    key: DashboardTutorialKeys.budgetRule,
    identify: 'budgetRule',
    align: ContentAlign.bottom,
    shape: ShapeLightFocus.RRect,
    radius: 20,
    title: 'Distribuição do Orçamento',
    description: 'Acompanhe se seus gastos estão dentro da regra que você configurou.',
  );

  _addTarget(
    targets,
    key: DashboardTutorialKeys.healthAndReserve,
    identify: 'healthAndReserve',
    align: ContentAlign.bottom,
    shape: ShapeLightFocus.RRect,
    radius: 16,
    title: 'Dívidas e Reserva',
    description: 'Resumo rápido: total de dívidas em aberto e quanto você já guardou.',
  );

  _addTarget(
    targets,
    key: DashboardTutorialKeys.quickActions,
    identify: 'quickActions',
    align: ContentAlign.top,
    shape: ShapeLightFocus.RRect,
    radius: 14,
    title: 'Ações Rápidas',
    description: 'Registre gastos, dívidas ou adicione à sua reserva com um toque.',
  );

  _addTarget(
    targets,
    key: DashboardTutorialKeys.goalsPreview,
    identify: 'goalsPreview',
    align: ContentAlign.top,
    shape: ShapeLightFocus.RRect,
    radius: 20,
    title: 'Suas Metas',
    description: 'Acompanhe o progresso das suas metas financeiras.',
  );

  _addTarget(
    targets,
    key: DashboardTutorialKeys.recentExpenses,
    identify: 'recentExpenses',
    align: ContentAlign.top,
    shape: ShapeLightFocus.RRect,
    radius: 20,
    title: 'Últimos Gastos',
    description: 'Seus gastos mais recentes aparecem aqui para você acompanhar no dia a dia.',
  );

  return targets;
}

Future<void> scrollToTarget(TargetFocus target) async {
  final key = target.keyTarget;
  if (key?.currentContext == null) return;
  await Scrollable.ensureVisible(
    key!.currentContext!,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    alignment: 0.3,
  );
}

void _addTarget(
  List<TargetFocus> targets, {
  required GlobalKey key,
  required String identify,
  required ContentAlign align,
  required ShapeLightFocus shape,
  required double radius,
  required String title,
  required String description,
}) {
  if (key.currentContext == null) return;

  targets.add(
    TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: shape,
      radius: radius,
      enableOverlayTab: true,
      enableTargetTab: true,
      paddingFocus: 8,
      contents: [
        TargetContent(
          align: align,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Toque para continuar',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00C896),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
