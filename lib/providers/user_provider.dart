// lib/providers/user_provider.dart

import 'dart:async';
import 'package:app_da_poli/models/user_model.dart';
import 'package:app_da_poli/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<UserModel?>? _userSubscription;

  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      _userSubscription?.cancel();

      if (firebaseUser != null) {
        _isLoading = true;
        notifyListeners(); 

        _userSubscription = _firestoreService.getUserProfile().listen((UserModel? userModel) {
          _currentUser = userModel;
          _isLoading = false;
          notifyListeners();
        });
      } else {
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