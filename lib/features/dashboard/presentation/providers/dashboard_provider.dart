import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../debts/presentation/providers/debts_provider.dart';
import '../../../installments/presentation/providers/installments_provider.dart';
import '../../../reserve/presentation/providers/reserve_provider.dart';
import '../../../subscriptions/presentation/providers/subscriptions_provider.dart';

final dashboardProvider = FutureProvider<DashboardSummaryEntity?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;

  // .future garante que aguardamos o carregamento real dos dados.
  // Também cria a dependência correta: quando qualquer lista mudar,
  // dashboardProvider recomputa — sem queries duplicadas no banco.
  final expenses = await ref.watch(expensesNotifierProvider.future);
  final debts = await ref.watch(debtsNotifierProvider.future);
  final installments = await ref.watch(installmentsNotifierProvider.future);
  final reserve = await ref.watch(reserveNotifierProvider.future);
  final subscriptions = await ref.watch(subscriptionsNotifierProvider.future);

  final now = DateTime.now();

  final thisMonthExpenses = expenses
      .where((e) => e.data.year == now.year && e.data.month == now.month)
      .toList();

  final totalGastos =
      thisMonthExpenses.fold(0.0, (sum, e) => sum + e.valor);

  final totalNecessidades = thisMonthExpenses
      .where((e) => e.classificacao == ExpenseClassification.necessidade)
      .fold(0.0, (sum, e) => sum + e.valor);

  final totalEstiloVida = thisMonthExpenses
      .where((e) => e.classificacao != ExpenseClassification.necessidade)
      .fold(0.0, (sum, e) => sum + e.valor);

  final totalDividas = debts.fold(0.0, (sum, d) => sum + d.valorRestante);
  final parcelaMensalDividas = debts.fold(0.0, (sum, d) => sum + d.valorParcela);
  final parcelaMensalParcelamentos =
      installments.fold(0.0, (sum, i) => sum + i.valorParcela);
  final mensalidadeAssinaturas = subscriptions
      .where((s) => s.ativa)
      .fold(0.0, (sum, s) => sum + s.custoMensal);
  final reservaAtual = reserve?.valorAtual ?? 0;

  final comprometimentoMensal = totalGastos +
      parcelaMensalDividas +
      parcelaMensalParcelamentos +
      mensalidadeAssinaturas;

  final pontuacao = _calcularPontuacao(
    salario: user.salarioMensal,
    comprometimentoMensal: comprometimentoMensal,
    totalDividas: totalDividas,
    reserva: reservaAtual,
  );

  return DashboardSummaryEntity(
    salarioMensal: user.salarioMensal,
    totalGastos: totalGastos,
    totalNecessidades: totalNecessidades,
    totalEstiloVida: totalEstiloVida,
    totalDividas: totalDividas,
    parcelaMensalDividas: parcelaMensalDividas,
    parcelaMensalParcelamentos: parcelaMensalParcelamentos,
    mensalidadeAssinaturas: mensalidadeAssinaturas,
    reservaAtual: reservaAtual,
    percentualNecessidades: user.percentualNecessidades,
    percentualObjetivos: user.percentualObjetivos,
    percentualReserva: user.percentualReserva,
    pontuacaoSaude: pontuacao,
    nomeUsuario: user.nome,
  );
});

int _calcularPontuacao({
  required double salario,
  required double comprometimentoMensal,
  required double totalDividas,
  required double reserva,
}) {
  if (salario <= 0) return 0;

  int pontuacao = 100;

  // Fator 1: Comprometimento da renda mensal (gastos + parcelas + assinaturas)
  // Ideal < 50% da renda. Acima de 90% é situação crítica.
  final pctComprometido = comprometimentoMensal / salario;
  if (pctComprometido > 0.9) {
    pontuacao -= 40;
  } else if (pctComprometido > 0.7) {
    pontuacao -= 30;
  } else if (pctComprometido > 0.5) {
    pontuacao -= 20;
  } else if (pctComprometido > 0.3) {
    pontuacao -= 10;
  }

  // Fator 2: Peso total da dívida acumulada vs salário
  final propDividas = totalDividas / salario;
  if (propDividas > 12) {
    pontuacao -= 30;
  } else if (propDividas > 6) {
    pontuacao -= 20;
  } else if (propDividas > 3) {
    pontuacao -= 10;
  } else if (propDividas > 1) {
    pontuacao -= 5;
  }

  // Fator 3: Reserva de emergência (meta = 6x salário)
  // Sem reserva = penalidade. Com reserva completa = bônus.
  final metaReserva = salario * 6;
  final propReserva = reserva / metaReserva;
  if (propReserva >= 1.0) {
    pontuacao += 10;
  } else if (propReserva < 0.1) {
    pontuacao -= 20;
  } else if (propReserva < 0.25) {
    pontuacao -= 10;
  }

  return pontuacao.clamp(0, 100);
}
