import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../screens/pin_input_screen.dart';
import 'dart:ui';

class PinProtectedWrapper extends StatefulWidget {
  final Widget child;

  const PinProtectedWrapper({super.key, required this.child});

  @override
  State<PinProtectedWrapper> createState() => _PinProtectedWrapperState();
}

class _PinProtectedWrapperState extends State<PinProtectedWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App foi para background ou perdeu foco
        break;
      case AppLifecycleState.resumed:
        // App voltou para foreground
        if (pinProvider.isPinEnabled) {
          pinProvider.requireAuthentication();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

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
                  color: Colors.black.withOpacity(0.3),
                  child: widget.child,
                ),
              ),
              // Tela de PIN sobreposta
              const PinInputScreen(),
            ],
          );
        }

        return widget.child;
      },
    );
  }
}
