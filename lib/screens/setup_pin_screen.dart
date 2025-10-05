import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';

class SetupPinScreen extends StatefulWidget {
  final bool isChanging;

  const SetupPinScreen({super.key, this.isChanging = false});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChanging ? 'Alterar PIN' : 'Configurar PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.security,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isChanging
                  ? 'Altere seu PIN de segurança'
                  : 'Crie um PIN de segurança',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'O PIN deve ter entre 4 e 8 dígitos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            if (widget.isChanging) ...[
              TextField(
                controller: _currentPinController,
                decoration: const InputDecoration(
                  labelText: 'PIN atual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _newPinController,
              decoration: InputDecoration(
                labelText: widget.isChanging ? 'Novo PIN' : 'PIN',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirmar PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed: _isLoading ? null : _setupPin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isChanging ? 'Alterar PIN' : 'Configurar PIN'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _setupPin() async {
    setState(() {
      _errorMessage = null;
    });

    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    // Validações
    if (widget.isChanging && currentPin.isEmpty) {
      setState(() {
        _errorMessage = 'Digite o PIN atual';
      });
      return;
    }

    if (newPin.isEmpty) {
      setState(() {
        _errorMessage = 'Digite o PIN';
      });
      return;
    }

    if (newPin.length < 4 || newPin.length > 8) {
      setState(() {
        _errorMessage = 'O PIN deve ter entre 4 e 8 dígitos';
      });
      return;
    }

    if (newPin != confirmPin) {
      setState(() {
        _errorMessage = 'Os PINs não coincidem';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pinProvider = Provider.of<PinProvider>(context, listen: false);
      bool success;

      if (widget.isChanging) {
        success = await pinProvider.changePin(currentPin, newPin);
        if (!success) {
          setState(() {
            _errorMessage = 'PIN atual incorreto';
          });
          return;
        }
      } else {
        success = await pinProvider.enablePin(newPin);
      }

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isChanging
                  ? 'PIN alterado com sucesso!'
                  : 'PIN configurado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Erro ao configurar PIN. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
