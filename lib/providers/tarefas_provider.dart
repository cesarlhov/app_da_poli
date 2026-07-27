// lib/providers/tarefas_provider.dart

import 'dart:async';
import 'package:app_da_poli/models/tarefa_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TarefasProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Tarefa>>? _tarefasSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<Tarefa> _tarefas = [];
  bool _isLoading = true;

  List<Tarefa> get tarefas => _tarefas;
  bool get isLoading => _isLoading;

  TarefasProvider() {
    _initListener();
  }

  void _initListener() {
    // Fica vigiando o estado de autenticação
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _tarefasSubscription?.cancel();
      
      if (user != null) {
        _isLoading = true;
        notifyListeners();

        // Baixa a lista de tarefas do Firebase em tempo real e guarda na memória local
        _tarefasSubscription = _firestoreService.getTarefas().listen((lista) {
          _tarefas = lista;
          _isLoading = false;
          notifyListeners(); // Avisa a interface que as tarefas estão prontas
        });
      } else {
        _tarefas = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _tarefasSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}