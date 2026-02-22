import 'package:dayapp/services/biometric_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_mocks.dart';

void main() {
  setUpAll(() {
    // Inicializa binding e mocks comuns (path_provider, secure_storage)
    initTestBindingsAndMocks();
  });

  group('BiometricService Tests', () {
    final biometricService = BiometricService();

    setUp(() {
      // Resetar mocks e estado compartilhado antes de cada teste
      initTestBindingsAndMocks();
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'enableBiometric / isBiometricEnabled / getSavedCredentials',
      () async {
        const email = 'test@example.com';
        const password = 'password123';

        await biometricService.enableBiometric(email, password);
        expect(await biometricService.isBiometricEnabled(), true);

        final creds = await biometricService.getSavedCredentials();
        expect(creds, isNotNull);
        expect(creds!['email'], email);
        expect(creds['password'], password);
      },
    );

    test('disableBiometric removes credentials', () async {
      const email = 'test@example.com';
      const password = 'password123';

      await biometricService.enableBiometric(email, password);
      expect(await biometricService.isBiometricEnabled(), true);

      await biometricService.disableBiometric();
      expect(await biometricService.isBiometricEnabled(), false);

      final creds = await biometricService.getSavedCredentials();
      expect(creds, isNull);
    });

    test('getSavedCredentials returns null when not configured', () async {
      final creds = await biometricService.getSavedCredentials();
      expect(creds, isNull);
    });

    test('getBiometricTypesText returns correct text', () {
      final text = biometricService.getBiometricTypesText([]);
      expect(text, 'Nenhuma');
    });
  });

  group('BiometricService Singleton Tests', () {
    test('returns same instance', () {
      final instance1 = BiometricService();
      final instance2 = BiometricService();

      expect(identical(instance1, instance2), true);
    });
  });
}
