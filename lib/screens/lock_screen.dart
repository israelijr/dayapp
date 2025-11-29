import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../services/biometric_service.dart';
import '../services/pin_recovery_service.dart';

/// Tela de bloqueio com autenticação por PIN e biometria
/// Exibida quando o app retorna do background após o tempo de inatividade
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final List<String> _enteredPin = [];
  final BiometricService _biometricService = BiometricService();
  final PinRecoveryService _recoveryService = PinRecoveryService();
  bool _isLoading = false;
  bool _showError = false;
  bool _isBiometricAvailable = false;
  bool _showRecoveryDialog = false;
  final int _maxPinLength = 8; // PIN pode ter de 4 a 8 dígitos

  @override
  void initState() {
    super.initState();
    _checkBiometricAndAutoAuthenticate();
  }

  Future<void> _checkBiometricAndAutoAuthenticate() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    final isAvailable = await _biometricService.isBiometricAvailable();

    if (!mounted) return;

    setState(() {
      _isBiometricAvailable = isEnabled && isAvailable;
    });

    // Se biometria está habilitada e disponível, E não há PIN configurado,
    // inicia autenticação biométrica automaticamente
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    if (_isBiometricAvailable && !pinProvider.isPinEnabled) {
      // Aguarda um frame para garantir que a tela foi renderizada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _authenticateWithBiometric();
        }
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (!mounted) return;

    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    try {
      setState(() => _isLoading = true);

      // Sinaliza que estamos autenticando com biometria para evitar bloqueio por inatividade
      pinProvider.isAuthenticatingWithBiometrics = true;

      final authenticated = await _biometricService.authenticate(
        reason: 'Desbloqueie o app para continuar',
      );

      if (!mounted) return;

      if (authenticated) {
        // Autentica no provider - força autenticação bem-sucedida
        // O método authenticateWithBiometric já reseta a flag isAuthenticatingWithBiometrics
        pinProvider.authenticateWithBiometric();
        // Provider notifica e isso fecha a tela de bloqueio
      } else {
        // Se falhou, reseta a flag
        pinProvider.isAuthenticatingWithBiometrics = false;
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Se deu erro, reseta a flag
      pinProvider.isAuthenticatingWithBiometrics = false;
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < _maxPinLength) {
      setState(() {
        _enteredPin.add(number);
        _showError = false;
      });
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _showError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final pin = _enteredPin.join();
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final isValid = await pinProvider.authenticate(pin);

    if (!mounted) return;

    if (isValid) {
      setState(() => _isLoading = false);
      // A navegação será tratada automaticamente pelo provider
    } else {
      setState(() {
        _showError = true;
        _enteredPin.clear();
        _isLoading = false;
      });

      // Vibra para indicar erro
      // HapticFeedback.vibrate();
    }
  }

  void _showRecoveryOptions() {
    setState(() => _showRecoveryDialog = true);
  }

  Future<void> _sendRecoveryEmail() async {
    final email = await _recoveryService.getUserEmail();

    if (email == null || email.isEmpty) {
      if (!mounted) return;
      _showMessage('Nenhum e-mail cadastrado. Configure nas configurações.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await _recoveryService.sendRecoveryCode(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Verificar se conseguiu obter o código gerado
      final hasCode = await _recoveryService.hasActiveRecoveryCode();

      if (hasCode) {
        _showMessage('Verifique seu e-mail em $email ou use o código exibido');
        _showRecoveryCodeDialog();
      } else {
        _showMessage('Erro ao gerar código. Tente novamente.');
      }
    } else {
      _showMessage('Erro ao enviar código. Tente novamente.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void _showRecoveryCodeDialog() async {
    final codeController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool obscureNewPin = true;
    bool obscureConfirmPin = true;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Recuperar PIN'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Digite o código que foi enviado para seu e-mail:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código de recuperação (6 dígitos)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPinController,
                    decoration: InputDecoration(
                      labelText: 'Novo PIN (4 a 8 dígitos)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.pin),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPin
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureNewPin = !obscureNewPin;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    obscureText: obscureNewPin,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPinController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar novo PIN',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.pin),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPin
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPin = !obscureConfirmPin;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    obscureText: obscureConfirmPin,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final code = codeController.text.trim();
                  final newPin = newPinController.text.trim();
                  final confirmPin = confirmPinController.text.trim();

                  if (code.length != 6) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Código deve ter 6 dígitos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPin.length < 4 || newPin.length > 8) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('PIN deve ter entre 4 e 8 dígitos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPin != confirmPin) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Os PINs não coincidem'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final isValid = await _recoveryService.verifyRecoveryCode(
                    code,
                  );

                  if (!context.mounted) return;

                  if (isValid) {
                    final pinProvider = Provider.of<PinProvider>(
                      dialogContext,
                      listen: false,
                    );
                    await pinProvider.enablePin(newPin);
                    await _recoveryService.clearRecoveryCode();

                    if (!context.mounted) return;
                    Navigator.of(dialogContext).pop();
                    _showMessage('PIN redefinido com sucesso!');
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Código inválido ou expirado'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final bool onlyBiometric =
        _isBiometricAvailable && !pinProvider.isPinEnabled;

    return PopScope(
      canPop: false, // Impede voltar
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone de cadeado ou biometria
                      Icon(
                        onlyBiometric ? Icons.fingerprint : Icons.lock_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),

                      // Título
                      Text(
                        'Desbloqueie o App',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        onlyBiometric
                            ? 'Use sua biometria para continuar'
                            : 'Digite seu PIN para continuar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Mostra PIN apenas se estiver habilitado
                      if (pinProvider.isPinEnabled) ...[
                        // Indicadores de PIN
                        _buildPinIndicators(),

                        if (_showError) ...[
                          const SizedBox(height: 16),
                          Text(
                            'PIN incorreto. Tente novamente.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),

                        // Teclado numérico
                        _buildNumericKeypad(),

                        const SizedBox(height: 24),
                      ],

                      // Botão de biometria
                      if (_isBiometricAvailable) ...[
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : _authenticateWithBiometric,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(
                            onlyBiometric
                                ? 'Desbloquear com Biometria'
                                : 'Usar Biometria',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Link para recuperação - apenas se PIN estiver habilitado
                      if (pinProvider.isPinEnabled)
                        TextButton(
                          onPressed: _isLoading ? null : _showRecoveryOptions,
                          child: const Text('Esqueci meu PIN'),
                        ),
                    ],
                  ),
                ),
              ),

              // Indicador de carregamento
              if (_isLoading)
                const ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Dialog de recuperação
              if (_showRecoveryDialog)
                ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 48,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Recuperar PIN',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Enviaremos um código de recuperação para o seu e-mail cadastrado.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() => _showRecoveryDialog = false);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() => _showRecoveryDialog = false);
                                    _sendRecoveryEmail();
                                  },
                                  child: const Text('Enviar Código'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_maxPinLength, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            border: Border.all(
              color: _showError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumericKeypad() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          _buildKeypadRow(['4', '5', '6']),
          _buildKeypadRow(['7', '8', '9']),
          _buildKeypadRow(['✓', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }

        return _buildKeypadButton(number);
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading
              ? null
              : () {
                  if (value == '⌫') {
                    _onBackspacePressed();
                  } else if (value == '✓') {
                    if (_enteredPin.length >= 4) {
                      _verifyPin();
                    }
                  } else {
                    _onNumberPressed(value);
                  }
                },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: value == '⌫' ? 24 : 28,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
