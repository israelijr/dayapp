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
    final success = await auth.register(
      nome: nameController.text.trim(),
      email: emailController.text.trim(),
      senha: passwordController.text,
    );
    setState(() {
      loading = false;
    });
    if (success) {
      Navigator.pushNamed(context, '/create_account_complement');
    } else {
      // Verifica se o e-mail já existe no banco
      final db = await DatabaseHelper().database;
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [emailController.text.trim()],
      );
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informe os dados para criar a conta',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Nome completo',
                  controller: nameController,
                ),
                CustomTextField(
                  label: 'Informe seu e-mail',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  label: 'Crie uma senha',
                  controller: passwordController,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                CustomTextField(
                  label: 'Repita a senha',
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading ? null : () => _register(context),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Próximo passo...',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
