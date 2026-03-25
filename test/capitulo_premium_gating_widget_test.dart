import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/pin_provider.dart';
import 'package:dayapp/providers/premium_provider.dart';
import 'package:dayapp/providers/refresh_provider.dart';
import 'package:dayapp/screens/create_historia_screen.dart';
import 'package:dayapp/screens/edit_historia_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'test_mocks.dart';

class FakePremiumProvider extends PremiumProvider {
  FakePremiumProvider(this.enabled);

  final bool enabled;

  @override
  bool get canUseChapters => enabled;

  @override
  bool get isPremium => enabled;
}

Widget _buildTestApp({required Widget child, required bool premiumEnabled}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ChangeNotifierProvider<PinProvider>(create: (_) => PinProvider()),
      ChangeNotifierProvider<RefreshProvider>(create: (_) => RefreshProvider()),
      ChangeNotifierProvider<PremiumProvider>(
        create: (_) => FakePremiumProvider(premiumEnabled),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    initTestBindingsAndMocks();
  });

  group('Capítulos premium gating (widget)', () {
    testWidgets('CreateHistoriaScreen mostra card premium para usuário free', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const CreateHistoriaScreen(),
          premiumEnabled: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_outlined), findsNothing);
      expect(
        find.text('Chapters and automatic suggestions are Premium features.'),
        findsOneWidget,
      );
      expect(find.text('Configure'), findsNothing);
    });

    testWidgets('CreateHistoriaScreen mostra ação de configurar para premium', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const CreateHistoriaScreen(),
          premiumEnabled: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
      expect(find.text('Configure'), findsOneWidget);
    });

    testWidgets('EditHistoriaScreen mostra card premium para usuário free', (
      tester,
    ) async {
      final historia = Historia(
        userId: 'u1',
        titulo: 'Teste',
        data: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: EditHistoriaScreen(historia: historia),
          premiumEnabled: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_outlined), findsNothing);
      expect(
        find.text('Chapters and automatic suggestions are Premium features.'),
        findsOneWidget,
      );
      expect(find.text('Configure'), findsNothing);
    });

    testWidgets('EditHistoriaScreen mostra ação de configurar para premium', (
      tester,
    ) async {
      final historia = Historia(
        userId: 'u1',
        titulo: 'Teste',
        data: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: EditHistoriaScreen(historia: historia),
          premiumEnabled: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
      expect(find.text('Configure'), findsOneWidget);
    });
  });
}
