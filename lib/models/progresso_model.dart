// lib/models/progresso_model.dart

class ProgressoDisciplina {
  final String disciplinaId;
  final bool isFavorita;
  final Map<String, double?> notasPreenchidas;
  final String formulaPersonalizada;
  
  // 🟢 Agora permite null! (true = Presente, false = Faltei, null = Sem Registro)
  final Map<String, bool?> historicoPresenca;

  const ProgressoDisciplina({
    required this.disciplinaId,
    this.isFavorita = false,
    this.notasPreenchidas = const {},
    this.formulaPersonalizada = '',
    this.historicoPresenca = const {}, 
  });

  int get faltasTotais {
    return historicoPresenca.values.where((status) => status == false).length;
  }

  // 🟢 Conta as aulas que não tiveram registro / não aconteceram
  int get aulasCanceladas {
    return historicoPresenca.values.where((status) => status == null).length;
  }

  double calcularFrequencia(int totalAulasEstimadas) {
    if (totalAulasEstimadas <= 0) return 100.0;
    int aulasPresentes = totalAulasEstimadas - faltasTotais;
    return (aulasPresentes / totalAulasEstimadas) * 100;
  }

  bool emRiscoDeReprovacao(int totalAulasEstimadas) {
    if (totalAulasEstimadas <= 0) return false;
    int aulasPresentesSeFaltar = totalAulasEstimadas - (faltasTotais + 1);
    double frequenciaFutura = (aulasPresentesSeFaltar / totalAulasEstimadas) * 100;
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

    Map<String, bool?> parsedPresenca = {};
    if (data['historicoPresenca'] != null) {
      final map = data['historicoPresenca'] as Map<String, dynamic>;
      map.forEach((key, value) {
        parsedPresenca[key] = value as bool?;
      });
    }

    return ProgressoDisciplina(
      disciplinaId: disciplinaId,
      isFavorita: data['isFavorita'] ?? false,
      notasPreenchidas: parsedNotas,
      formulaPersonalizada: data['formulaPersonalizada'] ?? '',
      historicoPresenca: parsedPresenca,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isFavorita': isFavorita,
      'notasPreenchidas': notasPreenchidas,
      'formulaPersonalizada': formulaPersonalizada,
      'historicoPresenca': historicoPresenca, 
    };
  }
}