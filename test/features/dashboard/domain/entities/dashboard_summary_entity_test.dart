import 'package:flutter_test/flutter_test.dart';
import 'package:eu_adulto/features/dashboard/domain/entities/dashboard_summary_entity.dart';

void main() {
  group('DashboardSummaryEntity Unit Tests', () {
    test('should calculate correct saldoDisponivel', () {
      const summary = DashboardSummaryEntity(
        salarioMensal: 5000.0,
        totalGastos: 1500.0,
        totalNecessidades: 1000.0,
        totalEstiloVida: 500.0,
        totalDividas: 10000.0,
        parcelaMensalDividas: 400.0,
        parcelaMensalParcelamentos: 300.0,
        mensalidadeAssinaturas: 80.0,
        reservaAtual: 1000.0,
        percentualNecessidades: 60.0,
        percentualObjetivos: 30.0,
        percentualReserva: 10.0,
        pontuacaoSaude: 85,
        nomeUsuario: 'Angelo',
      );

      // 5000 - 1500 - 400 - 300 - 80 = 2720
      expect(summary.saldoDisponivel, 2720.0);
    });

    test('should calculate correct limit values based on percentages', () {
      const summary = DashboardSummaryEntity(
        salarioMensal: 4000.0,
        totalGastos: 1000.0,
        totalNecessidades: 600.0,
        totalEstiloVida: 400.0,
        totalDividas: 0.0,
        parcelaMensalDividas: 0.0,
        parcelaMensalParcelamentos: 0.0,
        mensalidadeAssinaturas: 0.0,
        reservaAtual: 500.0,
        percentualNecessidades: 60.0,
        percentualObjetivos: 30.0,
        percentualReserva: 10.0,
        pontuacaoSaude: 95,
        nomeUsuario: 'Angelo',
      );

      expect(summary.limiteNecessidades, 2400.0); // 60% of 4000
      expect(summary.limiteObjetivos, 1200.0);    // 30% of 4000
      expect(summary.limiteReserva, 400.0);       // 10% of 4000
    });

    test('should return correct healthScore based on pontuacaoSaude', () {
      const baseSummary = DashboardSummaryEntity(
        salarioMensal: 4000.0,
        totalGastos: 1000.0,
        totalNecessidades: 600.0,
        totalEstiloVida: 400.0,
        totalDividas: 0.0,
        parcelaMensalDividas: 0.0,
        parcelaMensalParcelamentos: 0.0,
        mensalidadeAssinaturas: 0.0,
        reservaAtual: 500.0,
        percentualNecessidades: 60.0,
        percentualObjetivos: 30.0,
        percentualReserva: 10.0,
        pontuacaoSaude: 0, // variable
        nomeUsuario: 'Angelo',
      );

      final excelente = baseSummary.copyWith(pontuacaoSaude: 90);
      final excelenteOver = baseSummary.copyWith(pontuacaoSaude: 95);
      final saudavel = baseSummary.copyWith(pontuacaoSaude: 70);
      final saudavelMid = baseSummary.copyWith(pontuacaoSaude: 85);
      final atencao = baseSummary.copyWith(pontuacaoSaude: 40);
      final atencaoMid = baseSummary.copyWith(pontuacaoSaude: 69);
      final critico = baseSummary.copyWith(pontuacaoSaude: 0);
      final criticoMid = baseSummary.copyWith(pontuacaoSaude: 39);

      expect(excelente.healthScore, HealthScore.excelente);
      expect(excelenteOver.healthScore, HealthScore.excelente);
      expect(saudavel.healthScore, HealthScore.saudavel);
      expect(saudavelMid.healthScore, HealthScore.saudavel);
      expect(atencao.healthScore, HealthScore.atencao);
      expect(atencaoMid.healthScore, HealthScore.atencao);
      expect(critico.healthScore, HealthScore.critico);
      expect(criticoMid.healthScore, HealthScore.critico);
    });

    test('should support copyWith', () {
      const summary = DashboardSummaryEntity(
        salarioMensal: 4000.0,
        totalGastos: 1000.0,
        totalNecessidades: 600.0,
        totalEstiloVida: 400.0,
        totalDividas: 0.0,
        parcelaMensalDividas: 0.0,
        parcelaMensalParcelamentos: 0.0,
        mensalidadeAssinaturas: 0.0,
        reservaAtual: 500.0,
        percentualNecessidades: 60.0,
        percentualObjetivos: 30.0,
        percentualReserva: 10.0,
        pontuacaoSaude: 95,
        nomeUsuario: 'Angelo',
      );

      final copied = summary.copyWith(nomeUsuario: 'José', pontuacaoSaude: 80);

      expect(copied.nomeUsuario, 'José');
      expect(copied.pontuacaoSaude, 80);
      expect(copied.salarioMensal, 4000.0); // unchanged
    });
  });
}

// Add copyWith to DashboardSummaryEntity to support testing and potential use cases
extension on DashboardSummaryEntity {
  DashboardSummaryEntity copyWith({
    double? salarioMensal,
    double? totalGastos,
    double? totalNecessidades,
    double? totalEstiloVida,
    double? totalDividas,
    double? parcelaMensalDividas,
    double? parcelaMensalParcelamentos,
    double? mensalidadeAssinaturas,
    double? reservaAtual,
    double? percentualNecessidades,
    double? percentualObjetivos,
    double? percentualReserva,
    int? pontuacaoSaude,
    String? nomeUsuario,
  }) {
    return DashboardSummaryEntity(
      salarioMensal: salarioMensal ?? this.salarioMensal,
      totalGastos: totalGastos ?? this.totalGastos,
      totalNecessidades: totalNecessidades ?? this.totalNecessidades,
      totalEstiloVida: totalEstiloVida ?? this.totalEstiloVida,
      totalDividas: totalDividas ?? this.totalDividas,
      parcelaMensalDividas: parcelaMensalDividas ?? this.parcelaMensalDividas,
      parcelaMensalParcelamentos: parcelaMensalParcelamentos ?? this.parcelaMensalParcelamentos,
      mensalidadeAssinaturas: mensalidadeAssinaturas ?? this.mensalidadeAssinaturas,
      reservaAtual: reservaAtual ?? this.reservaAtual,
      percentualNecessidades: percentualNecessidades ?? this.percentualNecessidades,
      percentualObjetivos: percentualObjetivos ?? this.percentualObjetivos,
      percentualReserva: percentualReserva ?? this.percentualReserva,
      pontuacaoSaude: pontuacaoSaude ?? this.pontuacaoSaude,
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
    );
  }
}
