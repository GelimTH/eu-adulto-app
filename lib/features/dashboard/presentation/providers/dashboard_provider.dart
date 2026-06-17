import 'dart:math';
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

  final breakdown = _calcularHealthScore(
    salario: user.salarioMensal,
    totalGastos: totalGastos,
    totalNecessidades: totalNecessidades,
    totalEstiloVida: totalEstiloVida,
    totalDividas: totalDividas,
    parcelaMensalDividas: parcelaMensalDividas,
    parcelaMensalParcelamentos: parcelaMensalParcelamentos,
    mensalidadeAssinaturas: mensalidadeAssinaturas,
    reserva: reservaAtual,
    percentualNecessidades: user.percentualNecessidades,
    percentualObjetivos: user.percentualObjetivos,
    percentualReserva: user.percentualReserva,
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
    scoreBreakdown: breakdown,
    nomeUsuario: user.nome,
  );
});

HealthScoreBreakdown _calcularHealthScore({
  required double salario,
  required double totalGastos,
  required double totalNecessidades,
  required double totalEstiloVida,
  required double totalDividas,
  required double parcelaMensalDividas,
  required double parcelaMensalParcelamentos,
  required double mensalidadeAssinaturas,
  required double reserva,
  required double percentualNecessidades,
  required double percentualObjetivos,
  required double percentualReserva,
}) {
  if (salario <= 0) {
    return const HealthScoreBreakdown(fatores: [], pontuacaoTotal: 0);
  }

  final fatores = <HealthScoreFator>[];

  // Fator 1: Reserva de Emergência (0-25 pts)
  final mediaDespesas = totalGastos > 0 ? totalGastos : salario;
  final metaReserva = mediaDespesas * 6;
  final mesesCobertos = mediaDespesas > 0 ? reserva / mediaDespesas : 0.0;
  final pontosReserva = min(25, (reserva / metaReserva * 25)).round();

  String dicaReserva;
  if (reserva <= 0) {
    dicaReserva = 'Comece sua reserva de emergência hoje. A meta são 6 meses de despesas.';
  } else if (mesesCobertos >= 6) {
    dicaReserva = 'Parabéns! Sua reserva cobre ${mesesCobertos.toStringAsFixed(1)} meses. Meta atingida!';
  } else {
    dicaReserva = 'Sua reserva cobre ${mesesCobertos.toStringAsFixed(1)} meses. A meta são 6 meses de despesas.';
  }

  fatores.add(HealthScoreFator(
    nome: 'Reserva de Emergência',
    descricao: 'Quanto da meta de 6 meses de despesas você já guardou.',
    pontos: pontosReserva,
    maximo: 25,
    dica: dicaReserva,
  ));

  // Fator 2: Comprometimento com Dívidas (0-25 pts)
  final pagamentoMensal = parcelaMensalDividas + parcelaMensalParcelamentos;
  final pctComprometimento = pagamentoMensal / salario;
  final int pontosComprometimento;
  if (pagamentoMensal <= 0) {
    pontosComprometimento = 25;
  } else if (pctComprometimento <= 0.15) {
    pontosComprometimento = 20;
  } else if (pctComprometimento <= 0.30) {
    pontosComprometimento = 15;
  } else if (pctComprometimento <= 0.50) {
    pontosComprometimento = 8;
  } else {
    pontosComprometimento = 0;
  }

  final pctComprometimentoFormatado = (pctComprometimento * 100).toStringAsFixed(0);
  String dicaComprometimento;
  if (pagamentoMensal <= 0) {
    dicaComprometimento = 'Nenhuma parcela mensal. Excelente!';
  } else if (pctComprometimento > 0.30) {
    dicaComprometimento = '$pctComprometimentoFormatado% da sua renda vai para dívidas e parcelas. Acima de 30% é zona de risco.';
  } else {
    dicaComprometimento = '$pctComprometimentoFormatado% da sua renda vai para dívidas e parcelas. Dentro do saudável.';
  }

  fatores.add(HealthScoreFator(
    nome: 'Comprometimento com Dívidas',
    descricao: 'Quanto do seu salário vai para pagar dívidas e parcelas todo mês.',
    pontos: pontosComprometimento,
    maximo: 25,
    dica: dicaComprometimento,
  ));

  // Fator 3: Sobra Mensal (0-20 pts)
  final comprometimentoTotal = totalGastos +
      parcelaMensalDividas +
      parcelaMensalParcelamentos +
      mensalidadeAssinaturas;
  final sobra = salario - comprometimentoTotal;
  final pctSobra = sobra / salario;
  final int pontosSobra;
  if (pctSobra < 0) {
    pontosSobra = 0;
  } else if (pctSobra <= 0.05) {
    pontosSobra = 5;
  } else if (pctSobra <= 0.10) {
    pontosSobra = 10;
  } else if (pctSobra <= 0.20) {
    pontosSobra = 15;
  } else {
    pontosSobra = 20;
  }

  String dicaSobra;
  if (sobra < 0) {
    dicaSobra = 'Você está gastando mais do que ganha. Revise seus gastos com urgência.';
  } else if (pctSobra <= 0.05) {
    dicaSobra = 'Sobra muito apertada (${(pctSobra * 100).toStringAsFixed(0)}%). Tente reduzir gastos não essenciais.';
  } else {
    dicaSobra = '${(pctSobra * 100).toStringAsFixed(0)}% do salário sobra no fim do mês. ${pctSobra > 0.20 ? "Ótimo ritmo!" : "Tente aumentar para acima de 20%."}';
  }

  fatores.add(HealthScoreFator(
    nome: 'Sobra Mensal',
    descricao: 'Quanto sobra do seu salário depois de todos os gastos do mês.',
    pontos: pontosSobra,
    maximo: 20,
    dica: dicaSobra,
  ));

  // Fator 4: Nível de Endividamento Total (0-20 pts)
  final rendaAnual = salario * 12;
  final pctEndividamento = totalDividas / rendaAnual;
  final int pontosEndividamento;
  if (totalDividas <= 0) {
    pontosEndividamento = 20;
  } else if (pctEndividamento <= 0.10) {
    pontosEndividamento = 16;
  } else if (pctEndividamento <= 0.30) {
    pontosEndividamento = 12;
  } else if (pctEndividamento <= 0.50) {
    pontosEndividamento = 8;
  } else if (pctEndividamento <= 1.0) {
    pontosEndividamento = 4;
  } else {
    pontosEndividamento = 0;
  }

  String dicaEndividamento;
  if (totalDividas <= 0) {
    dicaEndividamento = 'Sem dívidas! Continue assim.';
  } else if (pctEndividamento > 1.0) {
    dicaEndividamento = 'Sua dívida total ultrapassa sua renda anual. Priorize a quitação.';
  } else {
    dicaEndividamento = 'Sua dívida total representa ${(pctEndividamento * 100).toStringAsFixed(0)}% da sua renda anual.';
  }

  fatores.add(HealthScoreFator(
    nome: 'Nível de Endividamento',
    descricao: 'Quanto você deve no total comparado com o que ganha no ano.',
    pontos: pontosEndividamento,
    maximo: 20,
    dica: dicaEndividamento,
  ));

  // Fator 5: Disciplina Orçamentária (0-10 pts)
  final limiteNecessidades = salario * percentualNecessidades / 100;
  final limiteObjetivos = salario * percentualObjetivos / 100;
  final limiteReserva = salario * percentualReserva / 100;

  int categoriasOk = 0;
  if (totalNecessidades + parcelaMensalDividas <= limiteNecessidades) categoriasOk++;
  if (totalEstiloVida + parcelaMensalParcelamentos + mensalidadeAssinaturas <= limiteObjetivos) categoriasOk++;
  if (reserva >= limiteReserva) categoriasOk++;

  final int pontosDisciplina;
  if (categoriasOk >= 3) {
    pontosDisciplina = 10;
  } else if (categoriasOk == 2) {
    pontosDisciplina = 7;
  } else if (categoriasOk == 1) {
    pontosDisciplina = 3;
  } else {
    pontosDisciplina = 0;
  }

  fatores.add(HealthScoreFator(
    nome: 'Disciplina Orçamentária',
    descricao: 'Se você está respeitando a regra de orçamento que configurou.',
    pontos: pontosDisciplina,
    maximo: 10,
    dica: '$categoriasOk de 3 categorias do orçamento estão dentro do limite.',
  ));

  final total = fatores.fold(0, (sum, f) => sum + f.pontos);

  return HealthScoreBreakdown(
    fatores: fatores,
    pontuacaoTotal: total.clamp(0, 100),
  );
}
