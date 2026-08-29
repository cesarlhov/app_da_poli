// lib/models/disciplina_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// 🟢 NOVO: Classe para armazenar a sua Tríade de Cores do Canva!
class PaletaDisciplina {
  final Color borda;
  final Color fundoInicio;
  final Color fundoFim;
  const PaletaDisciplina(this.borda, this.fundoInicio, this.fundoFim);
}

class HorarioAula {
  final String dia;
  final String inicio;
  final String fim;
  final String local;
  final bool isLaboratorio;
  final int frequenciaLab;
  final List<String> datasCustomizadas;
  final bool precisaEpi;
  final List<String> epis;

  HorarioAula({
    required this.dia,
    required this.inicio,
    required this.fim,
    required this.local,
    this.isLaboratorio = false,
    this.frequenciaLab = 0,
    this.datasCustomizadas = const [],
    this.precisaEpi = false,
    this.epis = const [],
  });

  factory HorarioAula.fromMap(Map<String, dynamic> data) {
    return HorarioAula(
      dia: data['dia'] ?? '',
      inicio: data['inicio'] ?? '',
      fim: data['fim'] ?? '',
      local: data['local'] ?? '',
      isLaboratorio: data['isLaboratorio'] ?? false,
      frequenciaLab: data['frequenciaLab'] ?? 0,
      datasCustomizadas: List<String>.from(data['datasCustomizadas'] ?? []),
      precisaEpi: data['precisaEpi'] ?? false,
      epis: List<String>.from(data['epis'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dia': dia, 'inicio': inicio, 'fim': fim, 'local': local,
      'isLaboratorio': isLaboratorio, 'frequenciaLab': frequenciaLab,
      'datasCustomizadas': datasCustomizadas, 'precisaEpi': precisaEpi, 'epis': epis,
    };
  }
}

class Turma {
  final String id;
  final String codigo;
  final List<String> professores;
  final List<HorarioAula> horarios;

  Turma({required this.id, required this.codigo, required this.professores, required this.horarios});

  factory Turma.fromMap(Map<String, dynamic> data) {
    return Turma(
      id: data['id'] ?? '',
      codigo: data['codigo'] ?? '',
      professores: List<String>.from(data['professores'] ?? []),
      horarios: (data['horarios'] as List<dynamic>? ?? []).map((h) => HorarioAula.fromMap(h as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'codigo': codigo, 'professores': professores,
      'horarios': horarios.map((h) => h.toMap()).toList(),
    };
  }
}

class Disciplina {
  final String id;
  final String codigo;
  final String nome;
  final String instituto;
  final String departamento;
  final String ementa;
  
  final bool isQuadrimestral;
  final bool isEstagio;
  final bool contaPresenca;

  final List<String> avaliacoesAtivas;
  final String formulaFinal;
  final String avisosGerais;

  final List<Turma> turmas;
  final Color cor;
  
  final bool isVerificada;
  final int numeroInscritos;

  final Timestamp dataInicio;
  final Timestamp dataFim;
  final Timestamp? dataEdicao;
  final int totalAulasEstimadas;

  Disciplina({
    required this.id, required this.codigo, required this.nome, required this.instituto,
    required this.departamento, required this.ementa, required this.isQuadrimestral, required this.isEstagio,
    required this.contaPresenca, required this.avaliacoesAtivas, required this.formulaFinal, required this.avisosGerais,
    required this.turmas, required this.cor, this.isVerificada = false, this.numeroInscritos = 0,
    required this.dataInicio, required this.dataFim, required this.totalAulasEstimadas,
    this.dataEdicao,
  });

  // 🟢 MÁGICA: Retorna as 3 cores exatas que você definiu no Canva!
  static PaletaDisciplina obterPaleta(String depto) {
    final sigla = depto.split('-').first.toUpperCase().trim();
    
    if (['PCC', 'PEF', 'PTR'].contains(sigla)) return const PaletaDisciplina(Color(0xFFFFCA0F), Color(0xFFE9A804), Color(0xFFC88108));
    if (['PHA'].contains(sigla)) return const PaletaDisciplina(Color(0xFFA40FFF), Color(0xFF6C05B4), Color(0xFF5F0696));
    if (['PQI'].contains(sigla)) return const PaletaDisciplina(Color(0xFF0085FF), Color(0xFF0460E9), Color(0xFF0D41A9));
    if (['PME', 'PMR'].contains(sigla)) return const PaletaDisciplina(Color(0xFFD30000), Color(0xFFA01212), Color(0xFF6B0101));
    if (['PRO'].contains(sigla)) return const PaletaDisciplina(Color(0xFF7ACF00), Color(0xFF649903), Color(0xFF326906));
    if (['PCS', 'PTC', 'PSI', 'PEA'].contains(sigla)) return const PaletaDisciplina(Color(0xFF2E63ED), Color(0xFF1D3DA6), Color(0xFF0E2877));
    if (['PMT', 'PMI'].contains(sigla)) return const PaletaDisciplina(Color(0xFFF06619), Color(0xFFC25800), Color(0xFFA53C00));
    if (['PNV'].contains(sigla)) return const PaletaDisciplina(Color(0xFF2B688B), Color(0xFF102F4B), Color(0xFF021629));

    // Neutro (Outros Institutos)
    return const PaletaDisciplina(Color(0xFF96A4A9), Color(0xFF697682), Color.fromARGB(255, 81, 93, 104));
  }

  static Color _obterCorDoDepartamento(String depto) {
    return obterPaleta(depto).fundoInicio; // Mantém compatibilidade com outros widgets
  }

  factory Disciplina.fromMap(String id, Map<String, dynamic> data) {
    final String depto = data['departamento'] ?? 'Geral';
    final String inst = data['instituto'] ?? 'POLI';
    final Timestamp? dataEdicao = data['dataEdicao'] as Timestamp?;

    return Disciplina(
      id: id, codigo: data['codigo'] ?? '', nome: data['nome'] ?? '', instituto: inst, departamento: depto, ementa: data['ementa'] ?? '',
      isQuadrimestral: data['isQuadrimestral'] ?? false, isEstagio: data['isEstagio'] ?? false, contaPresenca: data['contaPresenca'] ?? true,
      avaliacoesAtivas: List<String>.from(data['avaliacoesAtivas'] ?? []), formulaFinal: data['formulaFinal'] ?? '', avisosGerais: data['avisosGerais'] ?? '',
      dataEdicao: dataEdicao,

      // 🟢 MÁGICA ANTI-COLISÃO: Garante que o ID da turma nunca se repita no aplicativo (Ex: idDaMateria_t1)
      turmas: (data['turmas'] as List<dynamic>? ?? []).map((t) {
        final parsedTurma = Turma.fromMap(t as Map<String, dynamic>);
        return Turma(
          id: parsedTurma.id.contains(id) ? parsedTurma.id : '${id}_${parsedTurma.id}',
          codigo: parsedTurma.codigo,
          professores: parsedTurma.professores,
          horarios: parsedTurma.horarios,
        );
      }).toList(),
      
      cor: _obterCorDoDepartamento(depto), isVerificada: data['isVerificada'] ?? false, numeroInscritos: data['numeroInscritos'] ?? 0,
      dataInicio: data['dataInicio'] ?? Timestamp.now(), dataFim: data['dataFim'] ?? Timestamp.now(), totalAulasEstimadas: data['totalAulasEstimadas'] ?? 30, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo, 'nome': nome, 'instituto': instituto, 'departamento': departamento, 'ementa': ementa,
      'isQuadrimestral': isQuadrimestral, 'isEstagio': isEstagio, 'contaPresenca': contaPresenca,
      'avaliacoesAtivas': avaliacoesAtivas, 'formulaFinal': formulaFinal, 'avisosGerais': avisosGerais,
      'turmas': turmas.map((t) => t.toMap()).toList(), 'isVerificada': isVerificada, 'numeroInscritos': numeroInscritos,
      'dataInicio': dataInicio, 'dataFim': dataFim, 'totalAulasEstimadas': totalAulasEstimadas,
    };
  }
}