import 'package:equatable/equatable.dart';

enum HealthScore { critico, preocupante, atencao, saudavel, excelente }

extension HealthScoreExtension on HealthScore {
  String get label {
    switch (this) {
      case HealthScore.critico:
        return 'Crítico';
      case HealthScore.preocupante:
        return 'Preocupante';
      case HealthScore.atencao:
        return 'Atenção';
      case HealthScore.saudavel:
        return 'Saudável';
      case HealthScore.excelente:
        return 'Excelente';
    }
  }
}

class HealthScoreFator extends Equatable {
  final String nome;
  final String descricao;
  final int pontos;
  final int maximo;
  final String dica;

  const HealthScoreFator({
    required this.nome,
    required this.descricao,
    required this.pontos,
    required this.maximo,
    required this.dica,
  });

  double get percentual => maximo > 0 ? pontos / maximo : 0;

  @override
  List<Object> get props => [nome, descricao, pontos, maximo, dica];
}

class HealthScoreBreakdown extends Equatable {
  final List<HealthScoreFator> fatores;
  final int pontuacaoTotal;

  const HealthScoreBreakdown({
    required this.fatores,
    required this.pontuacaoTotal,
  });

  HealthScore get healthScore {
    if (pontuacaoTotal >= 85) return HealthScore.excelente;
    if (pontuacaoTotal >= 70) return HealthScore.saudavel;
    if (pontuacaoTotal >= 50) return HealthScore.atencao;
    if (pontuacaoTotal >= 30) return HealthScore.preocupante;
    return HealthScore.critico;
  }

  @override
  List<Object> get props => [fatores, pontuacaoTotal];
}

class DashboardSummaryEntity extends Equatable {
  final double salarioMensal;
  final double totalGastos;
  final double totalNecessidades;
  final double totalEstiloVida;
  final double totalDividas;
  final double parcelaMensalDividas;
  final double parcelaMensalParcelamentos;
  final double mensalidadeAssinaturas;
  final double reservaAtual;
  final double percentualNecessidades;
  final double percentualObjetivos;
  final double percentualReserva;
  final HealthScoreBreakdown scoreBreakdown;
  final String nomeUsuario;

  const DashboardSummaryEntity({
    required this.salarioMensal,
    required this.totalGastos,
    required this.totalNecessidades,
    required this.totalEstiloVida,
    required this.totalDividas,
    required this.parcelaMensalDividas,
    required this.parcelaMensalParcelamentos,
    required this.mensalidadeAssinaturas,
    required this.reservaAtual,
    required this.percentualNecessidades,
    required this.percentualObjetivos,
    required this.percentualReserva,
    required this.scoreBreakdown,
    required this.nomeUsuario,
  });

  int get pontuacaoSaude => scoreBreakdown.pontuacaoTotal;

  double get saldoDisponivel {
    return salarioMensal -
        totalGastos -
        parcelaMensalDividas -
        parcelaMensalParcelamentos -
        mensalidadeAssinaturas;
  }

  double get limiteNecessidades => salarioMensal * percentualNecessidades / 100;
  double get limiteObjetivos => salarioMensal * percentualObjetivos / 100;
  double get limiteReserva => salarioMensal * percentualReserva / 100;

  HealthScore get healthScore => scoreBreakdown.healthScore;

  @override
  List<Object> get props => [
        salarioMensal,
        totalGastos,
        totalNecessidades,
        totalEstiloVida,
        totalDividas,
        parcelaMensalDividas,
        parcelaMensalParcelamentos,
        mensalidadeAssinaturas,
        reservaAtual,
        percentualNecessidades,
        percentualObjetivos,
        percentualReserva,
        scoreBreakdown,
        nomeUsuario,
      ];
}
