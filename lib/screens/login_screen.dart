import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../services/biometric_service.dart';
import '../widgets/custom_text_field.dart';
import '../theme/m3_expressive_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool enableBiometric = false;

  String? errorMessage;
  bool loading = false;
  bool biometricAvailable = false;
  bool biometricEnabled = false;

  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();

    setState(() {
      biometricAvailable = available;
      biometricEnabled = enabled;
    });

    // Se a biometria está habilitada, tenta fazer login automaticamente
    if (enabled && available) {
      _biometricLogin();
    }
  }

  Future<void> _biometricLogin() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Autentique-se para acessar o DayApp',
    );

    if (authenticated) {
      final credentials = await _biometricService.getSavedCredentials();
      if (credentials != null) {
        setState(() {
          loading = true;
          errorMessage = null;
        });

        // ignore: use_build_context_synchronously
        final auth = Provider.of<AuthProvider>(context, listen: false);
        // ignore: use_build_context_synchronously
        final pinProvider = Provider.of<PinProvider>(context, listen: false);
        // ignore: use_build_context_synchronously
        final navigator = Navigator.of(context);

        final success = await auth.login(
          credentials['email']!,
          credentials['password']!,
          remember: true,
        );

        if (!mounted) return;
        setState(() {
          loading = false;
        });

        if (success) {
          // Atualiza o status de login no PinProvider
          // skipPinCheck: true porque o usuário acabou de se autenticar com biometria
          pinProvider.updateUserLoginStatus(true, skipPinCheck: true);
          navigator.pushReplacementNamed('/home');
        } else {
          setState(() {
            errorMessage = 'Erro ao fazer login com biometria.';
          });
          // Se falhar, desabilita a biometria
          await _biometricService.disableBiometric();
        }
      }
    }
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    // Sempre lembrar o login para persistência
    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text,
      remember: true,
    );
    if (!mounted) return;
    setState(() {
      loading = false;
    });
    if (success) {
      // Atualiza o status de login no PinProvider
      // skipPinCheck: true porque o usuário acabou de se autenticar com email/senha
      pinProvider.updateUserLoginStatus(true, skipPinCheck: true);

      // Se o login foi bem-sucedido e o usuário marcou para habilitar biometria
      if (enableBiometric && biometricAvailable) {
        await _biometricService.enableBiometric(
          emailController.text.trim(),
          passwordController.text,
        );
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometria habilitada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      navigator.pushReplacementNamed('/home');
    } else {
      setState(() {
        errorMessage = 'E-mail ou senha inválidos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Image.asset('assets/icon/icon.png', width: 80, height: 80),
                const SizedBox(height: 24),
                const Text(
                  'Bem vindo de volta!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Acesse sua conta',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Informe seu e-mail',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  label: 'Digite sua senha',
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
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
                if (biometricAvailable && !biometricEnabled) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: enableBiometric,
                        onChanged: (value) {
                          setState(() {
                            enableBiometric = value ?? false;
                          });
                        },
                        fillColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                        checkColor: AppColors.primary,
                      ),
                      const Expanded(
                        child: Text(
                          'Habilitar login com biometria',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
                if (biometricEnabled) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: loading ? null : _biometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Login com Biometria'),
                  ),
                ],
                const SizedBox(height: 8),
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
                    onPressed: loading ? null : () => _login(context),
                    child: loading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            'Acessar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/password_recovery');
                  },
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/create_account');
                  },
                  child: const Text(
                    'Não tem conta, crie uma aqui.',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Informações de contato e privacidade
                Column(
                  children: [
                    const Text(
                      'Precisa de ajuda?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'israelijr.app@gmail.com',
                          queryParameters: {
                            'subject': 'Suporte DayApp - Login',
                            'body':
                                'Olá, preciso de ajuda com o login no DayApp...',
                          },
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      child: const Text(
                        'israelijr.app@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        const url =
                            'https://sites.google.com/view/politicadeprivacidade-dayapp/início';
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Text(
                        'Política de Privacidade',
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
