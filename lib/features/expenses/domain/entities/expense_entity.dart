import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  alimentacao,
  transporte,
  saude,
  educacao,
  lazer,
  moradia,
  vestuario,
  outros;

  String get label {
    switch (this) {
      case alimentacao:
        return 'Alimentação';
      case transporte:
        return 'Transporte';
      case saude:
        return 'Saúde';
      case educacao:
        return 'Educação';
      case lazer:
        return 'Lazer';
      case moradia:
        return 'Moradia';
      case vestuario:
        return 'Vestuário';
      case outros:
        return 'Outros';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => outros,
    );
  }
}

enum ExpenseClassification {
  necessidade,
  conforto,
  impulso,
  recompensaEmocional;

  String get label {
    switch (this) {
      case necessidade:
        return 'Necessidade';
      case conforto:
        return 'Conforto';
      case impulso:
        return 'Impulso';
      case recompensaEmocional:
        return 'Recompensa Emocional';
    }
  }

  String get emoji {
    switch (this) {
      case necessidade:
        return '✅';
      case conforto:
        return '😌';
      case impulso:
        return '⚡';
      case recompensaEmocional:
        return '🎁';
    }
  }

  static ExpenseClassification fromString(String value) {
    return ExpenseClassification.values.firstWhere(
      (e) => e.name == value,
      orElse: () => necessidade,
    );
  }
}

class ExpenseEntity extends Equatable {
  final int? id;
  final double valor;
  final ExpenseCategory categoria;
  final ExpenseClassification classificacao;
  final String? descricao;
  final DateTime data;
  final int? bancoId;
  final int? cartaoId;

  const ExpenseEntity({
    this.id,
    required this.valor,
    required this.categoria,
    required this.classificacao,
    this.descricao,
    required this.data,
    this.bancoId,
    this.cartaoId,
  });

  ExpenseEntity copyWith({
    int? id,
    double? valor,
    ExpenseCategory? categoria,
    ExpenseClassification? classificacao,
    String? descricao,
    DateTime? data,
    int? bancoId,
    int? cartaoId,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      categoria: categoria ?? this.categoria,
      classificacao: classificacao ?? this.classificacao,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      bancoId: bancoId ?? this.bancoId,
      cartaoId: cartaoId ?? this.cartaoId,
    );
  }

  @override
  List<Object?> get props =>
      [id, valor, categoria, classificacao, descricao, data, bancoId, cartaoId];
}
