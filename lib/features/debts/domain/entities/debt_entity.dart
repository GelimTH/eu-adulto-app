import 'package:equatable/equatable.dart';

enum DebtType {
  divida,
  emprestimo;

  String get label {
    switch (this) {
      case divida:
        return 'Dívida';
      case emprestimo:
        return 'Empréstimo';
    }
  }

  String get emoji {
    switch (this) {
      case divida:
        return '💳';
      case emprestimo:
        return '🏦';
    }
  }

  static DebtType fromString(String value) {
    return DebtType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => divida,
    );
  }
}

class DebtEntity extends Equatable {
  final int? id;
  final int? bancoId;
  final DebtType tipo;
  final String descricao;
  final double valorOriginal;
  final double valorRestante;
  final double juros;
  final int parcelas;
  final int parcelasRestantes;
  final double valorParcela;
  final DateTime dataInicio;

  const DebtEntity({
    this.id,
    this.bancoId,
    this.tipo = DebtType.divida,
    required this.descricao,
    required this.valorOriginal,
    required this.valorRestante,
    required this.juros,
    required this.parcelas,
    required this.parcelasRestantes,
    required this.valorParcela,
    required this.dataInicio,
  });

  DateTime get quitacaoPrevista {
    return DateTime(
      dataInicio.year,
      dataInicio.month + parcelasRestantes,
      dataInicio.day,
    );
  }

  double get economiaAntecipacao {
    if (juros <= 0) return 0;
    final taxa = juros / 100;
    return valorRestante * taxa * parcelasRestantes;
  }

  DebtEntity copyWith({
    int? id,
    int? bancoId,
    DebtType? tipo,
    String? descricao,
    double? valorOriginal,
    double? valorRestante,
    double? juros,
    int? parcelas,
    int? parcelasRestantes,
    double? valorParcela,
    DateTime? dataInicio,
  }) {
    return DebtEntity(
      id: id ?? this.id,
      bancoId: bancoId ?? this.bancoId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valorOriginal: valorOriginal ?? this.valorOriginal,
      valorRestante: valorRestante ?? this.valorRestante,
      juros: juros ?? this.juros,
      parcelas: parcelas ?? this.parcelas,
      parcelasRestantes: parcelasRestantes ?? this.parcelasRestantes,
      valorParcela: valorParcela ?? this.valorParcela,
      dataInicio: dataInicio ?? this.dataInicio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bancoId,
        tipo,
        descricao,
        valorOriginal,
        valorRestante,
        juros,
        parcelas,
        parcelasRestantes,
        valorParcela,
        dataInicio,
      ];
}
