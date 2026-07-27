// lib/providers/disciplinas_provider.dart

import 'dart:async';
import 'package:app_da_poli/models/disciplina_model.dart';
import 'package:app_da_poli/models/progresso_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

class DisciplinasProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _userSubscription;
  StreamSubscription? _disciplinasSubscription;
  StreamSubscription? _progressosSubscription;

  List<Disciplina> _minhasDisciplinas = [];
  List<ProgressoDisciplina> _meusProgressos = [];
  bool _isLoading = true;

  List<Disciplina> get disciplinas => _minhasDisciplinas;
  List<ProgressoDisciplina> get progressos => _meusProgressos;
  bool get isLoading => _isLoading;

  DisciplinasProvider() {
    _initListener();
  }

void _initListener() {
    _userSubscription = _firestoreService.getUserProfile().listen((appUser) {
      if (appUser != null) {
        _isLoading = true;
        notifyListeners();

        // Baixa o progresso de notas e faltas com tratamento de erro
        _progressosSubscription?.cancel();
        _progressosSubscription = _firestoreService.getMeusProgressos().listen(
          (progs) {
            _meusProgressos = progs;
            notifyListeners();
          },
          onError: (erro) {
            debugPrint("Erro ao carregar progressos: $erro");
            // Se der erro, pelo menos destrava a tela
            _isLoading = false; 
            notifyListeners();
          }
        );

        // Puxa as disciplinas globais com tratamento de erro
        _disciplinasSubscription?.cancel();
        _disciplinasSubscription = _firestoreService.getDisciplinasGlobais().listen(
          (todasAsDisciplinas) {
            _minhasDisciplinas = todasAsDisciplinas.where((d) => appUser.turmasIds.contains(d.id)).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (erro) {
            debugPrint("Erro ao carregar disciplinas globais: $erro");
            _isLoading = false; // Destrava a tela em caso de falha de permissão
            notifyListeners();
          }
        );

      } else {
        _minhasDisciplinas = [];
        _meusProgressos = [];
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (erro) {
      debugPrint("Erro ao carregar usuário: $erro");
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _disciplinasSubscription?.cancel();
    _progressosSubscription?.cancel();
    super.dispose();
  }
}