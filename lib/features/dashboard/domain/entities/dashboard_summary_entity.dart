import 'package:equatable/equatable.dart';

enum HealthScore { critico, atencao, saudavel, excelente }

extension HealthScoreExtension on HealthScore {
  String get label {
    switch (this) {
      case HealthScore.critico:
        return 'Crítico';
      case HealthScore.atencao:
        return 'Atenção';
      case HealthScore.saudavel:
        return 'Saudável';
      case HealthScore.excelente:
        return 'Excelente';
    }
  }
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
  final int pontuacaoSaude;
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
    required this.pontuacaoSaude,
    required this.nomeUsuario,
  });

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

  HealthScore get healthScore {
    if (pontuacaoSaude >= 90) return HealthScore.excelente;
    if (pontuacaoSaude >= 70) return HealthScore.saudavel;
    if (pontuacaoSaude >= 40) return HealthScore.atencao;
    return HealthScore.critico;
  }

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
        pontuacaoSaude,
        nomeUsuario,
      ];
}
