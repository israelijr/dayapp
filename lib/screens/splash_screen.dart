import 'package:flutter/material.dart';

/// Splash Screen com animações de fade-in, desfoque e pulsação
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({required this.onComplete, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controladores de animação
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  // Animações
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Fade-in do logo e texto (1.5 segundos)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Scale do ícone surgindo lentamente (2 segundos, inicia após 0.3s)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Pulsação no texto (loop contínuo, 1.5 segundos)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progresso (2 segundos total)
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    // Inicia fade-in imediatamente
    _fadeController.forward();

    // Aguarda 200ms e inicia scale do ícone
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    // Aguarda mais 600ms e inicia pulsação (após o ícone estar visível)
    await Future.delayed(const Duration(milliseconds: 600));
    _pulseController.repeat(reverse: true);

    // Inicia o progresso
    _progressController.forward();

    // Aguarda completar e chama callback (2 segundos total)
    await Future.delayed(const Duration(milliseconds: 2000));
    widget.onComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8D5F0), // Lilás claro
              Color(0xFFF5E8FA), // Lilás muito claro
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Efeito de desfoque no fundo com círculos decorativos
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.3,
                  child: CustomPaint(
                    painter: _CirclesPainter(),
                    size: Size.infinite,
                  ),
                );
              },
            ),

            // Conteúdo principal centralizado
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo com ícone (fade-in + scale)
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _fadeAnimation,
                      _scaleAnimation,
                    ]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7B2CBF,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/icon/icon.png',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Texto "DayApp" com pulsação e brilho
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _fadeAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: const [
                                  Color(0xFF7B2CBF),
                                  Color(0xFF9D4EDD),
                                  Color(0xFF7B2CBF),
                                ],
                                stops: [
                                  0.0,
                                  _pulseAnimation.value * 0.5 + 0.25,
                                  1.0,
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'DayApp',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Indicador de progresso na parte inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          // Barra de progresso
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF7B2CBF),
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Texto de carregamento
                          Text(
                            'Carregando...',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(
                                0xFF7B2CBF,
                              ).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para desenhar círculos decorativos no fundo
class _CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Círculos decorativos em tons de roxo
    final circles = [
      {
        'x': size.width * 0.2,
        'y': size.height * 0.15,
        'radius': 80.0,
        'color': const Color(0xFF9D4EDD),
      },
      {
        'x': size.width * 0.8,
        'y': size.height * 0.25,
        'radius': 60.0,
        'color': const Color(0xFFC77DFF),
      },
      {
        'x': size.width * 0.15,
        'y': size.height * 0.7,
        'radius': 70.0,
        'color': const Color(0xFFE0AAFF),
      },
      {
        'x': size.width * 0.85,
        'y': size.height * 0.8,
        'radius': 90.0,
        'color': const Color(0xFF7B2CBF),
      },
    ];

    for (var circle in circles) {
      paint.color = (circle['color'] as Color).withValues(alpha: 0.15);
      canvas.drawCircle(
        Offset(circle['x'] as double, circle['y'] as double),
        circle['radius'] as double,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
