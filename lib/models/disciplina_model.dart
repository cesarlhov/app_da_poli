// lib/models/disciplina_model.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Disciplina {
  final String id;
  final String nome;
  final String codigo; // Ex: PME3380
  final String departamento;
  final String local; // Substitui 'sala'
  final List<String> diasDaSemana;
  final String horarioInicio;
  final String horarioFim;
  final Color cor; 
  
  // --- DADOS ACADÊMICOS ---
  final String ementa;
  final List<String> docentes;
  final List<String> monitores;
  
  // --- AVALIAÇÃO E CALENDÁRIO ---
  final String formulaAvaliacao; 
  final List<String> variaveisAvaliacao; 
  final Timestamp dataInicio; 
  final Timestamp dataFim; 
  final int totalAulasEstimadas; 
  
  // --- SOCIAL E GERÊNCIA ---
  final int numeroInscritos; 
  final String rcId; 
  final bool isVerificada;

  const Disciplina({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.departamento,
    required this.local,
    required this.diasDaSemana,
    required this.horarioInicio,
    required this.horarioFim,
    required this.cor,
    this.ementa = '',
    this.docentes = const [],
    this.monitores = const [],
    this.formulaAvaliacao = 'M = (P1 + P2)/2',
    this.variaveisAvaliacao = const ['P1', 'P2'],
    required this.dataInicio,
    required this.dataFim,
    required this.totalAulasEstimadas,
    this.numeroInscritos = 0,
    this.rcId = '',
    this.isVerificada = false,
  });

  static Color _obterCorDoDepartamento(String depto) {
    const Map<String, Color> coresOficiais = {
      'PQI': Color(0xFF9C27B0),
      'PCS': Color(0xFF4CAF50),
      'PME': Color(0xFFF44336),
      'PTC': Color(0xFF2196F3),
      'PEA': Color(0xFFFF9800),
      'PEF': Color(0xFF795548),
      'PRO': Color(0xFF607D8B),
    };
    final sigla = depto.toUpperCase().trim();
    if (coresOficiais.containsKey(sigla)) return coresOficiais[sigla]!;
    
    final random = Random(sigla.hashCode);
    return Color.fromRGBO(random.nextInt(100) + 80, random.nextInt(100) + 80, random.nextInt(100) + 80, 1);
  }

  factory Disciplina.fromMap(String id, Map<String, dynamic> data) {
    final depto = data['departamento'] ?? 'Geral';
    return Disciplina(
      id: id,
      nome: data['nome'] ?? '',
      codigo: data['codigo'] ?? '',
      departamento: depto,
      local: data['local'] ?? '',
      diasDaSemana: List<String>.from(data['diasDaSemana'] ?? []),
      horarioInicio: data['horarioInicio'] ?? '00:00',
      horarioFim: data['horarioFim'] ?? '00:00',
      cor: data['cor'] != null ? Color(int.parse(data['cor'])) : _obterCorDoDepartamento(depto),
      ementa: data['ementa'] ?? '',
      docentes: List<String>.from(data['docentes'] ?? []),
      monitores: List<String>.from(data['monitores'] ?? []),
      formulaAvaliacao: data['formulaAvaliacao'] ?? 'M = (P1 + P2)/2',
      variaveisAvaliacao: List<String>.from(data['variaveisAvaliacao'] ?? ['P1', 'P2']),
      dataInicio: data['dataInicio'] ?? Timestamp.now(),
      dataFim: data['dataFim'] ?? Timestamp.now(),
      totalAulasEstimadas: data['totalAulasEstimadas'] ?? 30,
      numeroInscritos: data['numeroInscritos'] ?? 0,
      rcId: data['rcId'] ?? '',
      isVerificada: data['isVerificada'] ?? false,
    );
  }

  // O MÉTODO QUE FALTAVA
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'codigo': codigo,
      'departamento': departamento,
      'local': local,
      'diasDaSemana': diasDaSemana,
      'horarioInicio': horarioInicio,
      'horarioFim': horarioFim,
      'ementa': ementa,
      'docentes': docentes,
      'monitores': monitores,
      'formulaAvaliacao': formulaAvaliacao,
      'variaveisAvaliacao': variaveisAvaliacao,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'totalAulasEstimadas': totalAulasEstimadas,
      'numeroInscritos': numeroInscritos,
      'rcId': rcId,
      'isVerificada': isVerificada,
    };
  }
}