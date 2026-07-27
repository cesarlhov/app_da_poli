// lib/models/user_model.dart

enum UserRole { 
  aluno, 
  representante, 
  gremio, 
  admin 
}

class AppUser {
  final String uid;
  final String nome;
  final String email;
  final String curso;
  final String nusp;
  final UserRole role;
  final List<String> amigosIds;
  final List<String> turmasIds;
  
  // NOVO: Controle de privacidade global transferido para cá
  final bool visivelParaAmigos; 

  const AppUser({
    required this.uid,
    required this.nome,
    required this.email,
    required this.curso,
    required this.nusp,
    this.role = UserRole.aluno,
    this.amigosIds = const [],
    this.turmasIds = const [],
    this.visivelParaAmigos = true, // Padrão: as pessoas gostam de se achar nas turmas
  });

  static UserRole _roleFromString(String roleString) {
    switch (roleString) {
      case 'admin': return UserRole.admin;
      case 'gremio': return UserRole.gremio;
      case 'representante': return UserRole.representante;
      default: return UserRole.aluno;
    }
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      uid: id,
      nome: data['nome'] ?? 'Usuário sem nome',
      email: data['email'] ?? '',
      curso: data['curso'] ?? 'Não definido',
      nusp: data['nusp'] ?? '',
      role: _roleFromString(data['role'] ?? 'aluno'),
      amigosIds: List<String>.from(data['amigosIds'] ?? []),
      turmasIds: List<String>.from(data['turmasIds'] ?? []),
      visivelParaAmigos: data['visivelParaAmigos'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'curso': curso,
      'nusp': nusp,
      'role': role.name,
      'amigosIds': amigosIds,
      'turmasIds': turmasIds,
      'visivelParaAmigos': visivelParaAmigos,
    };
  }
}