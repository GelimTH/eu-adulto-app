import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int? id;
  final String nome;
  final double salarioMensal;
  final double percentualNecessidades;
  final double percentualObjetivos;
  final double percentualReserva;
  final DateTime dataCriacao;

  const UserEntity({
    this.id,
    required this.nome,
    required this.salarioMensal,
    this.percentualNecessidades = 60,
    this.percentualObjetivos = 30,
    this.percentualReserva = 10,
    required this.dataCriacao,
  });

  double get limiteNecessidades => salarioMensal * percentualNecessidades / 100;
  double get limiteObjetivos => salarioMensal * percentualObjetivos / 100;
  double get limiteReserva => salarioMensal * percentualReserva / 100;

  UserEntity copyWith({
    int? id,
    String? nome,
    double? salarioMensal,
    double? percentualNecessidades,
    double? percentualObjetivos,
    double? percentualReserva,
    DateTime? dataCriacao,
  }) {
    return UserEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      salarioMensal: salarioMensal ?? this.salarioMensal,
      percentualNecessidades:
          percentualNecessidades ?? this.percentualNecessidades,
      percentualObjetivos: percentualObjetivos ?? this.percentualObjetivos,
      percentualReserva: percentualReserva ?? this.percentualReserva,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        salarioMensal,
        percentualNecessidades,
        percentualObjetivos,
        percentualReserva,
        dataCriacao,
      ];
}
