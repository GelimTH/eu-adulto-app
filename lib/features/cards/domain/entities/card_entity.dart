import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final int? id;
  final int? bancoId;
  final String nome;
  final double limiteTotal;
  final int fechamento;
  final int vencimento;

  const CardEntity({
    this.id,
    this.bancoId,
    required this.nome,
    required this.limiteTotal,
    required this.fechamento,
    required this.vencimento,
  });

  CardEntity copyWith({
    int? id,
    int? bancoId,
    String? nome,
    double? limiteTotal,
    int? fechamento,
    int? vencimento,
  }) {
    return CardEntity(
      id: id ?? this.id,
      bancoId: bancoId ?? this.bancoId,
      nome: nome ?? this.nome,
      limiteTotal: limiteTotal ?? this.limiteTotal,
      fechamento: fechamento ?? this.fechamento,
      vencimento: vencimento ?? this.vencimento,
    );
  }

  @override
  List<Object?> get props => [id, bancoId, nome, limiteTotal, fechamento, vencimento];
}
