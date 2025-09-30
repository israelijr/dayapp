import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../db/database_helper.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;

  String? errorMessage;
  bool loading = false;

  Future<void> _register(BuildContext context) async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Preencha todos os campos.';
        loading = false;
      });
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'As senhas não coincidem.';
        loading = false;
      });
      return;
    }
    if (passwordController.text.length < 6) {
      setState(() {
        errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
        loading = false;
      });
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final success = await auth.register(
      nome: nameController.text.trim(),
      email: emailController.text.trim(),
      senha: passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      loading = false;
    });
    if (success) {
      navigator.pushNamed('/create_account_complement');
    } else {
      // Verifica se o e-mail já existe no banco
      final db = await DatabaseHelper().database;
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [emailController.text.trim()],
      );
      if (!mounted) return;
      setState(() {
        errorMessage = existing.isNotEmpty
            ? 'E-mail já cadastrado.'
            : 'Erro ao criar conta. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB388FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Criar conta', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'DayApp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: nameController,
                label: 'Nome',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                label: 'Senha',
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Confirmar Senha',
                obscureText: obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirm = !obscureConfirm;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : () => _register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Criar Conta'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Já tem uma conta? Faça login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
