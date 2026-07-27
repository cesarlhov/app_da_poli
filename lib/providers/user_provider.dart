// lib/providers/user_provider.dart

import 'dart:async';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<AppUser?>? _userSubscription;

  AppUser? _currentUser;
  bool _isLoading = true;

  // Acesso seguro de fora da classe
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    // Fica escutando se o usuário logou ou deslogou do Firebase
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      // Cancela a escuta anterior para não vazar memória
      _userSubscription?.cancel();

      if (firebaseUser != null) {
        _isLoading = true;
        notifyListeners(); // Avisa a interface que estamos carregando

        // Puxa os dados do aluno logado
        _userSubscription = _firestoreService.getUserProfile().listen((AppUser? appUser) {
          _currentUser = appUser;
          _isLoading = false;
          notifyListeners(); // Avisa a interface que os dados chegaram!
        });
      } else {
        // Se deslogar, limpa os dados da memória
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}