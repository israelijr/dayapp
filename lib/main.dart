import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/create_account_complement_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/create_historia_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/refresh_provider.dart';
import 'providers/pin_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'services/inactivity_service.dart';
import 'services/ad_service.dart';
import 'screens/edit_historia_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/backup_manager_screen.dart';
import 'screens/trash_screen.dart';
import 'db/database_helper.dart';
import 'models/historia.dart';
import 'widgets/pin_protected_wrapper.dart';
import 'theme/m3_expressive_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  // Inicializa sqflite_common_ffi apenas em desktop
  if (!identical(0, 0.0)) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

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

  // Inicializar Google Mobile Ads
  await AdService().initialize();

  // Inicializar notificações
  await NotificationService().init((String? payload) async {
    if (payload != null) {
      int? historiaId = int.tryParse(payload);
      if (historiaId != null) {
        Historia? historia = await DatabaseHelper().getHistoria(historiaId);
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

  runApp(
    MyApp(
      authProvider: authProvider,
      themeProvider: themeProvider,
      refreshProvider: refreshProvider,
      pinProvider: pinProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;
  final RefreshProvider refreshProvider;
  final PinProvider pinProvider;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.themeProvider,
    required this.refreshProvider,
    required this.pinProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final InactivityService _inactivityService = InactivityService();
  DateTime? _pausedTime;
  static const _shortPauseDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializa o serviço de inatividade sempre
    _inactivityService.initialize(
      onTimeout: () {
        if (widget.pinProvider.isPinEnabled) {
          print('Timer de inatividade disparado - bloqueando app');
          widget.pinProvider.requireAuthentication();
        }
      },
    );

    // Inicia o timer se PIN estiver habilitado
    if (widget.pinProvider.isPinEnabled) {
      _inactivityService.startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityService.clear();
    super.dispose();
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
        _inactivityService.stopTimer();
        break;
      case AppLifecycleState.resumed:
        // App voltou para foreground
        if (widget.pinProvider.isPinEnabled) {
          // Verifica se deve bloquear baseado no tempo de inatividade
          _inactivityService.shouldLockOnResume().then((shouldLock) {
            if (shouldLock) {
              widget.pinProvider.requireAuthentication();
            } else if (_pausedTime != null) {
              final pauseDuration = DateTime.now().difference(_pausedTime!);
              // Se foi uma pausa curta (ex: abrir seletor de mídia), não pede PIN
              if (pauseDuration > _shortPauseDuration) {
                widget.pinProvider.requireAuthentication();
              }
            }

            // Reinicia o timer de inatividade
            _inactivityService.startTimer();
          });

          _pausedTime = null;
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
          return GestureDetector(
            onTap: () {
              print('Atividade detectada: tap');
              _inactivityService.recordActivity();
            },
            onPanDown: (_) {
              print('Atividade detectada: pan');
              _inactivityService.recordActivity();
            },
            onScaleStart: (_) {
              print('Atividade detectada: scale');
              _inactivityService.recordActivity();
            },
            behavior: HitTestBehavior.translucent,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                print('Atividade detectada: scroll');
                _inactivityService.recordActivity();
                return false;
              },
              child: MaterialApp(
                title: 'DayApp',
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                theme: M3ExpressiveTheme.getLightTheme(),
                darkTheme: M3ExpressiveTheme.getDarkTheme(),
                themeMode: themeProvider.themeMode,
                supportedLocales: const [
                  Locale('pt', 'BR'),
                  Locale('en', 'US'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                initialRoute: widget.authProvider.isLoggedIn
                    ? '/home'
                    : '/login',
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
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks and behaves.
