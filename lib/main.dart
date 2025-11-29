import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db/database_helper.dart';
import 'models/historia.dart';
import 'providers/auth_provider.dart';
import 'providers/pin_provider.dart';
import 'providers/refresh_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/backup_manager_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/create_account_complement_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/create_historia_screen.dart';
import 'screens/edit_historia_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/trash_screen.dart';
import 'services/ad_service.dart';
import 'services/inactivity_service.dart';
import 'services/notification_service.dart';
import 'theme/m3_expressive_theme.dart';
import 'widgets/pin_protected_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa sqflite_common_ffi apenas em desktop (rápido, necessário antes do DB)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicialização de data/hora (rápida e necessária para formatação)
  await initializeDateFormatting('pt_BR', null);

  // Inicia o app IMEDIATAMENTE com a tela de carregamento
  // As inicializações pesadas serão feitas em background
  runApp(const AppLoader());
}

/// Widget que carrega o app de forma assíncrona
/// Mostra a splash screen enquanto inicializa os providers
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  late Future<AppInitData> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  /// Inicializa todos os providers e serviços necessários
  Future<AppInitData> _initializeApp() async {
    // Inicializar AuthProvider e tentar auto-login
    final authProvider = AuthProvider();
    await authProvider.tryAutoLogin();

    // Inicializar ThemeProvider
    final themeProvider = ThemeProvider();
    await themeProvider.waitForLoad();

    // Inicializar RefreshProvider
    final refreshProvider = RefreshProvider();

    // Inicializar PinProvider (passa o status de login do usuário)
    final pinProvider = PinProvider();
    await pinProvider.initialize(isUserLoggedIn: authProvider.isLoggedIn);

    // Inicializar Google Mobile Ads (em paralelo com notificações)
    final adsFuture = AdService().initialize();

    // Inicializar notificações
    final notificationsFuture = NotificationService().init((
      String? payload,
    ) async {
      if (payload != null) {
        final int? historiaId = int.tryParse(payload);
        if (historiaId != null) {
          final Historia? historia = await DatabaseHelper().getHistoria(
            historiaId,
          );
          if (historia != null) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => EditHistoriaScreen(historia: historia),
              ),
            );
          }
        }
      }
    });

    // Aguarda inicializações em paralelo
    await Future.wait([adsFuture, notificationsFuture]);

    return AppInitData(
      authProvider: authProvider,
      themeProvider: themeProvider,
      refreshProvider: refreshProvider,
      pinProvider: pinProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppInitData>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Enquanto carrega, mostra a splash screen bonita com animações
        // A native splash (cor sólida) já foi removida, agora mostramos a splash do Flutter
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: M3ExpressiveTheme.getLightTheme(),
            darkTheme: M3ExpressiveTheme.getDarkTheme(),
            home: const SplashScreen(),
          );
        }

        // Se houve erro na inicialização
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: M3ExpressiveTheme.getLightTheme(),
            darkTheme: M3ExpressiveTheme.getDarkTheme(),
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao inicializar o app',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _initFuture = _initializeApp();
                        });
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Inicialização completa - carrega o app principal
        final data = snapshot.data!;
        return MyApp(
          authProvider: data.authProvider,
          themeProvider: data.themeProvider,
          refreshProvider: data.refreshProvider,
          pinProvider: data.pinProvider,
        );
      },
    );
  }
}

/// Classe para armazenar os dados inicializados
class AppInitData {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;
  final RefreshProvider refreshProvider;
  final PinProvider pinProvider;

  AppInitData({
    required this.authProvider,
    required this.themeProvider,
    required this.refreshProvider,
    required this.pinProvider,
  });
}

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;
  final RefreshProvider refreshProvider;
  final PinProvider pinProvider;

  const MyApp({
    required this.authProvider,
    required this.themeProvider,
    required this.refreshProvider,
    required this.pinProvider,
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final InactivityService _inactivityService = InactivityService();
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Garante que o estado do PIN seja notificado após o widget estar montado
    // Isso força o PinProtectedWrapper a reagir ao estado inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pinProvider.shouldShowPinScreen) {
        // Força uma notificação para garantir que os listeners reajam
        widget.pinProvider.requireAuthentication();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkBackgroundLock() async {
    if (_pausedTime == null) return;

    // Verifica o tempo em segundo plano
    final pauseDuration = DateTime.now().difference(_pausedTime!);
    final backgroundTimeoutSeconds = await _inactivityService
        .getBackgroundLockTimeout();
    final backgroundTimeout = Duration(seconds: backgroundTimeoutSeconds);

    // Bloqueia se o tempo de pausa excedeu o configurado
    if (pauseDuration > backgroundTimeout) {
      widget.pinProvider.requireAuthentication();
    }

    _pausedTime = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App foi para background ou perdeu foco
        _pausedTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        // App voltou para foreground
        if (widget.pinProvider.isLockEnabled && _pausedTime != null) {
          // Se estiver autenticando com biometria, não bloqueia
          if (widget.pinProvider.isAuthenticatingWithBiometrics) {
            _pausedTime = null;
            // Reseta a flag pois já consumimos o evento de retorno
            widget.pinProvider.isAuthenticatingWithBiometrics = false;
            return;
          }

          // Se estiver selecionando mídia externa (galeria, câmera, etc.), não bloqueia
          if (widget.pinProvider.isPickingExternalMedia) {
            _pausedTime = null;
            // Reseta a flag pois já consumimos o evento de retorno
            widget.pinProvider.isPickingExternalMedia = false;
            return;
          }

          _checkBackgroundLock();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider.value(value: widget.refreshProvider),
        ChangeNotifierProvider.value(value: widget.pinProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DayApp',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: M3ExpressiveTheme.getLightTheme(),
            darkTheme: M3ExpressiveTheme.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            // Vai direto para home ou login (splash já foi mostrada durante carregamento)
            initialRoute: widget.authProvider.isLoggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/create_account': (context) => const CreateAccountScreen(),
              '/create_account_complement': (context) =>
                  const CreateAccountComplementScreen(),
              '/home': (context) =>
                  const PinProtectedWrapper(child: HomeScreen()),
              '/create_historia': (context) =>
                  const PinProtectedWrapper(child: CreateHistoriaScreen()),
              '/edit_profile': (context) =>
                  const PinProtectedWrapper(child: EditProfileScreen()),
              '/settings': (context) =>
                  const PinProtectedWrapper(child: SettingsScreen()),
              '/calendar': (context) =>
                  const PinProtectedWrapper(child: CalendarViewScreen()),
              '/backup-manager': (context) =>
                  const PinProtectedWrapper(child: BackupManagerScreen()),
              '/trash': (context) =>
                  const PinProtectedWrapper(child: TrashScreen()),
              '/search': (context) =>
                  const PinProtectedWrapper(child: SearchScreen()),
            },
          );
        },
      ),
    );
  }
}

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks and behaves.
