// lib/models/disciplina_model.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HorarioAula {
  final String dia; // Ex: SEGUNDA
  final String inicio; // Ex: 07:30
  final String fim; // Ex: 09:10
  final String local;
  final bool isLaboratorio;
  final int frequenciaLab; // 0=Semanal, 1=Quinzenal 1, 2=Quinzenal 2, 3=Custom
  final List<String> datasCustomizadas; // Datas do calendário salvas em ISO (YYYY-MM-DD)
  final bool precisaEpi;
  final List<String> epis;

  HorarioAula({
    required this.dia,
    required this.inicio,
    required this.fim,
    required this.local,
    required this.isLaboratorio,
    required this.frequenciaLab,
    required this.datasCustomizadas,
    required this.precisaEpi,
    required this.epis,
  });

  factory HorarioAula.fromMap(Map<String, dynamic> map) {
    return HorarioAula(
      dia: map['dia'] ?? 'SEGUNDA',
      inicio: map['inicio'] ?? '00:00',
      fim: map['fim'] ?? '00:00',
      local: map['local'] ?? '',
      isLaboratorio: map['isLaboratorio'] ?? false,
      frequenciaLab: map['frequenciaLab'] ?? 0,
      datasCustomizadas: List<String>.from(map['datasCustomizadas'] ?? []),
      precisaEpi: map['precisaEpi'] ?? false,
      epis: List<String>.from(map['epis'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dia': dia,
      'inicio': inicio,
      'fim': fim,
      'local': local,
      'isLaboratorio': isLaboratorio,
      'frequenciaLab': frequenciaLab,
      'datasCustomizadas': datasCustomizadas,
      'precisaEpi': precisaEpi,
      'epis': epis,
    };
  }
}

class Turma {
  final String id;
  final String codigo; // Ex: 2026101
  final List<String> professores;
  final List<HorarioAula> horarios;

  Turma({
    required this.id,
    required this.codigo,
    required this.professores,
    required this.horarios,
  });

  factory Turma.fromMap(Map<String, dynamic> map) {
    return Turma(
      id: map['id'] ?? '',
      codigo: map['codigo'] ?? '',
      professores: List<String>.from(map['professores'] ?? []),
      horarios: (map['horarios'] as List<dynamic>? ?? [])
          .map((h) => HorarioAula.fromMap(h as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'professores': professores,
      'horarios': horarios.map((h) => h.toMap()).toList(),
    };
  }
}

class Disciplina {
  final String id;
  final String codigo; // Ex: GP2601
  final String nome; // Ex: FENÔMENOS PARANORMAIS
  final String instituto; // Ex: POLI
  final String departamento; // Ex: Engenharia de Produção
  final String ementa;
  
  final bool isQuadrimestral;
  final bool isEstagio;
  final bool contaPresenca;

  final List<String> avaliacoesAtivas; // Ex: ['P1', 'P2', 'SUB']
  final String formulaFinal;
  final String avisosGerais;

  final List<Turma> turmas;
  final Color cor;
  
  // Status de moderação
  final bool isVerificada;
  final int numeroInscritos;

  Disciplina({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.instituto,
    required this.departamento,
    required this.ementa,
    required this.isQuadrimestral,
    required this.isEstagio,
    required this.contaPresenca,
    required this.avaliacoesAtivas,
    required this.formulaFinal,
    required this.avisosGerais,
    required this.turmas,
    required this.cor,
    this.isVerificada = false,
    this.numeroInscritos = 0,
  });

  static Color _obterCorDoDepartamento(String inst) {
    const Map<String, Color> coresOficiais = {
      'POLI': Color(0xFF0460E9), // Azul Poli
      'IME': Color(0xFFE04F44),
      'IF': Color(0xFF4CAF50),
      'IQ': Color(0xFF9C27B0),
      'ICG': Color(0xFFFF9800),
    };
    final sigla = inst.toUpperCase().split(' ').first.trim();
    if (coresOficiais.containsKey(sigla)) return coresOficiais[sigla]!;
    
    final random = Random(sigla.hashCode);
    return Color.fromRGBO(random.nextInt(100) + 80, random.nextInt(100) + 80, random.nextInt(100) + 80, 1);
  }

  factory Disciplina.fromMap(String id, Map<String, dynamic> data) {
    final inst = data['instituto'] ?? 'POLI';
    return Disciplina(
      id: id,
      codigo: data['codigo'] ?? '',
      nome: data['nome'] ?? '',
      instituto: inst,
      departamento: data['departamento'] ?? '',
      ementa: data['ementa'] ?? '',
      isQuadrimestral: data['isQuadrimestral'] ?? false,
      isEstagio: data['isEstagio'] ?? false,
      contaPresenca: data['contaPresenca'] ?? true,
      avaliacoesAtivas: List<String>.from(data['avaliacoesAtivas'] ?? []),
      formulaFinal: data['formulaFinal'] ?? '',
      avisosGerais: data['avisosGerais'] ?? '',
      turmas: (data['turmas'] as List<dynamic>? ?? [])
          .map((t) => Turma.fromMap(t as Map<String, dynamic>))
          .toList(),
      cor: data['cor'] != null ? Color(int.parse(data['cor'])) : _obterCorDoDepartamento(inst),
      isVerificada: data['isVerificada'] ?? false,
      numeroInscritos: data['numeroInscritos'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'instituto': instituto,
      'departamento': departamento,
      'ementa': ementa,
      'isQuadrimestral': isQuadrimestral,
      'isEstagio': isEstagio,
      'contaPresenca': contaPresenca,
      'avaliacoesAtivas': avaliacoesAtivas,
      'formulaFinal': formulaFinal,
      'avisosGerais': avisosGerais,
      'turmas': turmas.map((t) => t.toMap()).toList(),
      'cor': cor.value.toString(),
      'isVerificada': isVerificada,
      'numeroInscritos': numeroInscritos,
    };
  }
}