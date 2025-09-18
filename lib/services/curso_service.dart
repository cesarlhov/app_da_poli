// lib/services/curso_service.dart

/// Um serviço para fornecer dados estáticos sobre o curso, como a lista
/// completa de disciplinas. No futuro, isso poderia ser carregado de um
/// arquivo JSON ou de uma API.
class CursoService {
  // Lista de exemplo de disciplinas do curso.
  // Idealmente, esta lista seria mais completa e poderia vir de uma fonte externa.
  final List<Map<String, String>> _disciplinasDoCurso = const [
    {'codigo': 'PME3380', 'nome': 'Cálculo Numérico'},
    {'codigo': 'PEA3301', 'nome': 'Circuitos Elétricos'},
    {'codigo': 'PBI3345', 'nome': 'Física III'},
    {'codigo': 'MAC0110', 'nome': 'Introdução à Computação'},
    {'codigo': 'MAT2453', 'nome': 'Cálculo Diferencial e Integral I'},
    {'codigo': 'PCS3111', 'nome': 'Estruturas de Dados'},
    // Adicionar mais disciplinas aqui...
  ];

  /// Retorna uma lista com os códigos de todas as disciplinas do curso.
  List<String> getTodosCodigos() {
    return _disciplinasDoCurso.map((d) => d['codigo']!).toList();
  }

  /// Retorna o número total de disciplinas cadastradas no curso.
  int getTotalDisciplinas() {
    return _disciplinasDoCurso.length;
  }
}