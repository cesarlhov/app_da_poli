// lib/models/progresso_model.dart

class ProgressoDisciplina {
  final String disciplinaId;
  final bool isFavorita;
  final Map<String, double?> notasPreenchidas;
  final String formulaPersonalizada;
  
  // NOVO: Diário de Bordo. Chave = Data (YYYY-MM-DD), Valor = true (Presente) / false (Falta)
  final Map<String, bool> historicoPresenca;

  const ProgressoDisciplina({
    required this.disciplinaId,
    this.isFavorita = false,
    this.notasPreenchidas = const {},
    this.formulaPersonalizada = '',
    this.historicoPresenca = const {}, // Começa vazio (100% de presença)
  });

  /// Conta quantas faltas o aluno tem baseado no histórico
  int get faltasTotais {
    // Conta quantos "false" existem no mapa
    return historicoPresenca.values.where((estevePresente) => estevePresente == false).length;
  }

  /// Calcula a frequência atual. O aluno começa com 100%.
  double calcularFrequencia(int totalAulasEstimadas) {
    if (totalAulasEstimadas <= 0) return 100.0;
    int aulasPresentes = totalAulasEstimadas - faltasTotais;
    return (aulasPresentes / totalAulasEstimadas) * 100;
  }

  /// Retorna TRUE se a PRÓXIMA falta fizer ele cair para menos de 70% (ou 60% dependendo da regra).
  /// Alerta ideal para enviar notificação push!
  bool emRiscoDeReprovacao(int totalAulasEstimadas) {
    if (totalAulasEstimadas <= 0) return false;
    // Simula como ficaria se ele tomasse mais UMA falta hoje
    int aulasPresentesSeFaltar = totalAulasEstimadas - (faltasTotais + 1);
    double frequenciaFutura = (aulasPresentesSeFaltar / totalAulasEstimadas) * 100;
    
    // Alerta de perigo: Se a próxima falta deixar ele com menos de 70%
    return frequenciaFutura < 70.0; 
  }

  factory ProgressoDisciplina.fromMap(String disciplinaId, Map<String, dynamic> data) {
    Map<String, double?> parsedNotas = {};
    if (data['notasPreenchidas'] != null) {
      final map = data['notasPreenchidas'] as Map<String, dynamic>;
      map.forEach((key, value) {
        parsedNotas[key] = value != null ? (value as num).toDouble() : null;
      });
    }

    Map<String, bool> parsedPresenca = {};
    if (data['historicoPresenca'] != null) {
      final map = data['historicoPresenca'] as Map<String, dynamic>;
      map.forEach((key, value) {
        parsedPresenca[key] = value as bool;
      });
    }

    return ProgressoDisciplina(
      disciplinaId: disciplinaId,
      isFavorita: data['isFavorita'] ?? false,
      notasPreenchidas: parsedNotas,
      formulaPersonalizada: data['formulaPersonalizada'] ?? '',
      historicoPresenca: parsedPresenca, // Puxa o histórico do Firebase
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isFavorita': isFavorita,
      'notasPreenchidas': notasPreenchidas,
      'formulaPersonalizada': formulaPersonalizada,
      'historicoPresenca': historicoPresenca, // Salva o histórico no Firebase
    };
  }
}