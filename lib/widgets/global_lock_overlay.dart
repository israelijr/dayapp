import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';
import '../screens/lock_screen.dart';

/// Widget que sobrepõe a tela de bloqueio em todo o app
/// sem reconstruir as telas subjacentes, preservando o estado de edição
class GlobalLockOverlay extends StatelessWidget {
  final Widget child;

  const GlobalLockOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, _) {
        debugPrint(
          'GlobalLockOverlay: shouldShowPinScreen=${pinProvider.shouldShowPinScreen}',
        );

        return Stack(
          children: [
            // Conteúdo do app - SEMPRE presente, nunca reconstruído
            child,

            // Overlay de bloqueio - só aparece quando necessário
            if (pinProvider.shouldShowPinScreen)
              Positioned.fill(
                child: Stack(
                  children: [
                    // Blur sobre o conteúdo
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // Tela de bloqueio
                    const LockScreen(),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
