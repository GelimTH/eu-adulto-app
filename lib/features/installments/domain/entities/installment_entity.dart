import 'package:equatable/equatable.dart';

class InstallmentEntity extends Equatable {
  final int? id;
  final String descricao;
  final double valorTotal;
  final double valorParcela;
  final int parcelaAtual;
  final int totalParcelas;
  final int? bancoId;
  final int? cartaoId;
  final DateTime dataInicio;

  const InstallmentEntity({
    this.id,
    required this.descricao,
    required this.valorTotal,
    required this.valorParcela,
    required this.parcelaAtual,
    required this.totalParcelas,
    this.bancoId,
    this.cartaoId,
    required this.dataInicio,
  });

  int get parcelasRestantes => totalParcelas - parcelaAtual + 1;
  double get valorRestante => valorParcela * parcelasRestantes;

  DateTime get encerramentoPrevisto {
    return DateTime(
      dataInicio.year,
      dataInicio.month + totalParcelas - 1,
      dataInicio.day,
    );
  }

  InstallmentEntity copyWith({
    int? id,
    String? descricao,
    double? valorTotal,
    double? valorParcela,
    int? parcelaAtual,
    int? totalParcelas,
    int? bancoId,
    int? cartaoId,
    DateTime? dataInicio,
  }) {
    return InstallmentEntity(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorTotal: valorTotal ?? this.valorTotal,
      valorParcela: valorParcela ?? this.valorParcela,
      parcelaAtual: parcelaAtual ?? this.parcelaAtual,
      totalParcelas: totalParcelas ?? this.totalParcelas,
      bancoId: bancoId ?? this.bancoId,
      cartaoId: cartaoId ?? this.cartaoId,
      dataInicio: dataInicio ?? this.dataInicio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        descricao,
        valorTotal,
        valorParcela,
        parcelaAtual,
        totalParcelas,
        bancoId,
        cartaoId,
        dataInicio,
      ];
}
