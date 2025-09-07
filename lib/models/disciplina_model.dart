import 'package:cloud_firestore/cloud_firestore.dart';

// Este ficheiro define a estrutura de dados para uma disciplina.
class Disciplina {
  final String id;
  final String nome;
  final String codigo;
  final String professor;
  final String sala;
  // Agora pode ter vários dias
  final List<String> diasDaSemana;
  // Horários de início e fim
  final String horarioInicio;
  final String horarioFim;

  Disciplina({
    this.id = '', // <-- CORREÇÃO AQUI: ID volta a ser opcional
    required this.nome,
    required this.codigo,
    required this.professor,
    required this.sala,
    required this.diasDaSemana,
    required this.horarioInicio,
    required this.horarioFim,
  });

  // Factory constructor para criar uma Disciplina a partir de um documento do Firestore
  factory Disciplina.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Disciplina(
      id: doc.id,
      nome: data['nome'] ?? '',
      codigo: data['codigo'] ?? '',
      professor: data['professor'] ?? '',
      sala: data['sala'] ?? '',
      // Garante que diasDaSemana é sempre uma Lista<String>
      diasDaSemana: List<String>.from(data['diasDaSemana'] ?? []),
      horarioInicio: data['horarioInicio'] ?? '',
      horarioFim: data['horarioFim'] ?? '',
    );
  }
}

