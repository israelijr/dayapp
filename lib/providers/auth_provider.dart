import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../db/database_helper.dart';
import '../models/user.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    final db = await DatabaseHelper().database;
    // Busca usuário pelo email
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      final storedPassword = result.first['senha'] as String;
      // Verifica senha com hash (suporta migração de senhas antigas)
      if (_secureStorage.verifyPassword(password, storedPassword)) {
        _user = User.fromMap(result.first);

        // Se a senha ainda não tem hash, atualiza para versão segura
        if (!storedPassword.contains('\$')) {
          final salt = _secureStorage.generateSalt();
          final hashedPassword = _secureStorage.hashPassword(password, salt);
          await db.update(
            'users',
            {'senha': hashedPassword},
            where: 'id = ?',
            whereArgs: [_user!.id],
          );
        }

        if (remember) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', _user!.id);
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> register({
    required String nome,
    required String email,
    required String senha,
    DateTime? dtNascimento,
    String? fotoPerfil,
  }) async {
    try {
      final db = await DatabaseHelper().database;
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (existing.isNotEmpty) {
        return false;
      }

      // Gera hash seguro para a senha
      final salt = _secureStorage.generateSalt();
      final hashedSenha = _secureStorage.hashPassword(senha, salt);

      final uuid = const Uuid().v4();
      await db.insert('users', {
        'id': uuid,
        'nome': nome,
        'email': email,
        'senha': hashedSenha,
        'dt_nascimento': dtNascimento?.toIso8601String(),
        'foto_perfil': fotoPerfil,
      });
      _user = User(
        id: uuid,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (result.isNotEmpty) {
        _user = User.fromMap(result.first);
        notifyListeners();
      }
    }
  }

  Future<bool> updateUser({
    required String nome,
    required String email,
    DateTime? dtNascimento,
    String? fotoPerfil,
  }) async {
    if (_user == null) return false;

    try {
      final db = await DatabaseHelper().database;
      await db.update(
        'users',
        {
          'nome': nome,
          'email': email,
          'dt_nascimento': dtNascimento?.toIso8601String(),
          'foto_perfil': fotoPerfil,
        },
        where: 'id = ?',
        whereArgs: [_user!.id],
      );

      _user = User(
        id: _user!.id,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
