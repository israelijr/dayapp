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
import 'screens/edit_historia_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/backup_manager_screen.dart';
import 'screens/trash_screen.dart';
import 'db/database_helper.dart';
import 'models/historia.dart';
import 'widgets/pin_protected_wrapper.dart';

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

  // Inicializar PinProvider
  final pinProvider = PinProvider();
  await pinProvider.initialize();

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

class MyApp extends StatelessWidget {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: refreshProvider),
        ChangeNotifierProvider.value(value: pinProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DayApp',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFB388FF)),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFFB388FF),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            themeMode: themeProvider.themeMode,
            supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: authProvider.isLoggedIn ? '/home' : '/login',
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
          );
        },
      ),
    );
  }
}

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks and behaves.
