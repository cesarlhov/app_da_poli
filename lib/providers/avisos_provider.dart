// lib/providers/avisos_provider.dart

import 'dart:async';
import 'package:app_da_poli/models/aviso_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:flutter/material.dart';

class AvisosProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Aviso>>? _avisosSubscription;

  List<Aviso> _avisos = [];
  bool _isLoading = true;

  List<Aviso> get avisos => _avisos;
  bool get isLoading => _isLoading;

  AvisosProvider() {
    _initListener();
  }

  void _initListener() {
    _isLoading = true;
    notifyListeners();

    // Fica escutando a coleção global de avisos do Firestore
    _avisosSubscription = _firestoreService.getAvisos().listen((lista) {
      _avisos = lista;
      _isLoading = false;
      notifyListeners(); // Avisa a interface que os comunicados chegaram
    });
  }

  @override
  void dispose() {
    _avisosSubscription?.cancel();
    super.dispose();
  }
}