import 'package:flutter/material.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  String? _token;

  Usuario? get usuario => _usuario;
  String? get token => _token;

  bool get isAuthenticated => _token != null;

  void login({
    required Usuario usuario,
    required String token,
  }) {
    _usuario = usuario;
    _token = token;

    notifyListeners();
  }

  void logout() {
    _usuario = null;
    _token = null;

    notifyListeners();
  }
}