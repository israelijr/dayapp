import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    debugPrint('Tentando login para: $email');
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'users',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, password],
    );
    debugPrint('Resultado da consulta: ${result.length}');
    if (result.isNotEmpty) {
      debugPrint('Login bem-sucedido!');
      _user = User.fromMap(result.first);
      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _user!.id);
      }
      notifyListeners();
      return true;
    }
    debugPrint('Login falhou: usuário ou senha inválidos');
    return false;
  }

  Future<bool> register({
    required String nome,
    required String email,
    required String senha,
    DateTime? dtNascimento,
    String? fotoPerfil,
  }) async {
    debugPrint('register: início');
    try {
      debugPrint('register: obtendo instância do banco de dados...');
      final db = await DatabaseHelper().database;
      debugPrint('register: instância do banco obtida');
      debugPrint('register: verificando se email já existe...');
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      debugPrint(
        'register: resultado da consulta de email: ${existing.length}',
      );
      if (existing.isNotEmpty) {
        debugPrint('register: email já cadastrado');
        return false;
      }
      final uuid = const Uuid().v4();
      debugPrint('register: inserindo novo usuário...');
      await db.insert('users', {
        'id': uuid,
        'nome': nome,
        'email': email,
        'senha': senha,
        'dt_nascimento': dtNascimento?.toIso8601String(),
        'foto_perfil': fotoPerfil,
      });
      debugPrint('register: usuário inserido com sucesso');
      _user = User(
        id: uuid,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );
      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint('register: erro ao registrar usuário: $e');
      debugPrint('register: stacktrace: $stack');
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
      debugPrint('Erro ao atualizar usuário: $e');
      return false;
    }
  }
}
