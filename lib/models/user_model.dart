// lib/models/user_model.dart

enum UserRole { aluno, representante, gremio, admin }

class UserModel {
  final String uid;
  final String nomeCompleto; 
  final String nomeUsuario;
  final String email;
  final String numeroUSP; 
  final String? telefone; 
  final String curso;
  final String? fotoUrl; // ✅ NOVO CAMPO: Link da foto de perfil
  
  // Hierarquia e Poderes
  final bool isGremio; 
  final bool isRC;     
  
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
    this.fotoUrl, // ✅ INCLUÍDO AQUI
    this.isGremio = false,
    this.isRC = false,
    this.turmasGerenciadas = const [],
    this.turmasIds = const [],
    this.amigosIds = const [],
    this.xp = 0,
    this.tituloAtual = 'Calouro Curioso',
    this.insignias = const [],
    this.aceitouTermos = false,
    this.visibilidadePerfil = 'publico',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      nomeCompleto: map['nomeCompleto'] ?? map['nome'] ?? '',
      nomeUsuario: map['nomeUsuario'] ?? '',
      email: map['email'] ?? '',
      numeroUSP: map['numeroUSP'] ?? map['nusp'] ?? '',
      telefone: map['telefone'],
      curso: map['curso'] ?? 'Não informado',
      fotoUrl: map['fotoUrl'], // ✅ PUXA DO BANCO
      isGremio: map['isGremio'] ?? (map['role'] == 'gremio' || map['role'] == 'admin'),
      isRC: map['isRC'] ?? (map['role'] == 'representante'),
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
      'fotoUrl': fotoUrl, // ✅ SALVA NO BANCO
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