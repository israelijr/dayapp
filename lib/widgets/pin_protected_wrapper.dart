import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../screens/lock_screen.dart';
import 'dart:ui';

class PinProtectedWrapper extends StatelessWidget {
  final Widget child;

  const PinProtectedWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, child) {
        if (pinProvider.shouldShowPinScreen) {
          return Stack(
            children: [
              // Conteúdo com blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3 * 255),
                  child: this.child,
                ),
              ),
              // Tela de bloqueio sobreposta
              const LockScreen(),
            ],
          );
        }

        return this.child;
      },
    );
  }
}
