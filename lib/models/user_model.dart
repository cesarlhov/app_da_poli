// lib/models/user_model.dart

enum UserRole { aluno, representante, gremio, admin, chov } // 🟢 Adicionamos o chov aqui

class UserModel {
  final String uid;
  final String nomeCompleto; 
  final String nomeUsuario;
  final String email;
  final String numeroUSP; 
  final String? telefone; 
  final String curso;
  final String? fotoUrl; 
  final UserRole role; 
  
  // 🔥 HIERARQUIA SUPREMA (Calculada Automaticamente)
  // Se o role for chov, ele automaticamente ganha todos os poderes abaixo dele.
  bool get isChov => role == UserRole.chov || role == UserRole.admin;
  bool get isGremio => isChov || role == UserRole.gremio;
  bool get isRC => isGremio || role == UserRole.representante;
  
  // Listas de Conexão
  final List<String> turmasGerenciadas; 
  final List<String> turmasIds; 
  final List<String> amigosIds; 
  
  // Gamificação e Configurações
  final int xp;
  final String tituloAtual;
  final List<String> insignias;
  final bool aceitouTermos;
  final String visibilidadePerfil;

  String get nome => nomeCompleto;

  UserModel({
    required this.uid,
    required this.nomeCompleto,
    required this.nomeUsuario,
    required this.email,
    required this.numeroUSP,
    this.telefone,
    required this.curso,
    this.fotoUrl, 
    this.role = UserRole.aluno, 
    this.turmasGerenciadas = const [],
    this.turmasIds = const [],
    this.amigosIds = const [],
    this.xp = 0,
    this.tituloAtual = 'Calouro Curioso',
    this.insignias = const [],
    this.aceitouTermos = false,
    this.visibilidadePerfil = 'publico',
  });

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == 'chov') return UserRole.chov;
    if (roleStr == 'admin') return UserRole.admin;
    if (roleStr == 'gremio') return UserRole.gremio;
    if (roleStr == 'representante') return UserRole.representante;
    return UserRole.aluno;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Para retrocompatibilidade caso ainda exista isGremio como booleano no banco antigo
    UserRole detectedRole = _parseRole(map['role']);
    if (detectedRole == UserRole.aluno) {
      if (map['isGremio'] == true) detectedRole = UserRole.gremio;
      else if (map['isRC'] == true) detectedRole = UserRole.representante;
    }

    return UserModel(
      uid: documentId,
      nomeCompleto: map['nomeCompleto'] ?? map['nome'] ?? '',
      nomeUsuario: map['nomeUsuario'] ?? '',
      email: map['email'] ?? '',
      numeroUSP: map['numeroUSP'] ?? map['nusp'] ?? '',
      telefone: map['telefone'],
      curso: map['curso'] ?? 'Não informado',
      fotoUrl: map['fotoUrl'], 
      role: detectedRole, 
      turmasGerenciadas: List<String>.from(map['turmasGerenciadas'] ?? []),
      turmasIds: List<String>.from(map['turmasIds'] ?? []),
      amigosIds: List<String>.from(map['amigosIds'] ?? []),
      xp: map['xp'] ?? 0,
      tituloAtual: map['tituloAtual'] ?? 'Calouro Curioso',
      insignias: List<String>.from(map['insignias'] ?? []),
      aceitouTermos: map['aceitouTermos'] ?? false,
      visibilidadePerfil: map['visibilidadePerfil'] ?? 'publico',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeCompleto': nomeCompleto,
      'nomeUsuario': nomeUsuario,
      'email': email,
      'numeroUSP': numeroUSP,
      'telefone': telefone,
      'curso': curso,
      'fotoUrl': fotoUrl, 
      'role': role.name, 
      // Salvamos os booleanos também apenas para facilitar queries diretas no Firebase se você precisar buscar "where isGremio == true"
      'isGremio': isGremio,
      'isRC': isRC,
      'turmasGerenciadas': turmasGerenciadas,
      'turmasIds': turmasIds,
      'amigosIds': amigosIds,
      'xp': xp,
      'tituloAtual': tituloAtual,
      'insignias': insignias,
      'aceitouTermos': aceitouTermos,
      'visibilidadePerfil': visibilidadePerfil,
    };
  }
}