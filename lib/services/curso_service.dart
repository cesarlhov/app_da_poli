// Este ficheiro simula uma base de dados central com todas as disciplinas de um curso.
class CursoService {
  // Lista completa de disciplinas do curso de Engenharia de Computação (exemplo)
  // Usamos o código da disciplina como identificador único.
  final List<Map<String, String>> _disciplinasDoCurso = [
    {'codigo': 'PME3380', 'nome': 'Cálculo Numérico'},
    {'codigo': 'PEA3301', 'nome': 'Circuitos Elétricos'},
    {'codigo': 'PBI3345', 'nome': 'Física III'},
    {'codigo': 'MAC0110', 'nome': 'Introdução à Computação'},
    {'codigo': 'MAT2453', 'nome': 'Cálculo Diferencial e Integral I'},
    {'codigo': 'PCS3111', 'nome': 'Estruturas de Dados'},
    // ... podemos adicionar todas as outras 44 disciplinas aqui
  ];

  // Método para obter a lista completa de códigos de disciplina do curso
  List<String> getTodosCodigos() {
    return _disciplinasDoCurso.map((d) => d['codigo']!).toList();
  }

  // Método para obter o número total de disciplinas no curso
  int getTotalDisciplinas() {
    return _disciplinasDoCurso.length;
  }
}
