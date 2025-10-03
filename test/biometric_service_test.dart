import 'package:flutter_test/flutter_test.dart';
import 'package:dayapp/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BiometricService Tests', () {
    late BiometricService biometricService;

    setUp(() {
      biometricService = BiometricService();
      // Inicializar SharedPreferences com valores vazios para testes
      SharedPreferences.setMockInitialValues({});
    });

    test('isBiometricEnabled deve retornar false por padrão', () async {
      final enabled = await biometricService.isBiometricEnabled();
      expect(enabled, false);
    });

    test('enableBiometric deve salvar credenciais', () async {
      const email = 'test@example.com';
      const password = 'password123';

      await biometricService.enableBiometric(email, password);

      final enabled = await biometricService.isBiometricEnabled();
      expect(enabled, true);

      final credentials = await biometricService.getSavedCredentials();
      expect(credentials, isNotNull);
      expect(credentials!['email'], email);
      expect(credentials['password'], password);
    });

    test('disableBiometric deve remover credenciais', () async {
      const email = 'test@example.com';
      const password = 'password123';

      // Habilitar primeiro
      await biometricService.enableBiometric(email, password);
      expect(await biometricService.isBiometricEnabled(), true);

      // Desabilitar
      await biometricService.disableBiometric();
      expect(await biometricService.isBiometricEnabled(), false);

      final credentials = await biometricService.getSavedCredentials();
      expect(credentials, isNull);
    });

    test(
      'getSavedCredentials deve retornar null quando não configurado',
      () async {
        final credentials = await biometricService.getSavedCredentials();
        expect(credentials, isNull);
      },
    );

    test('getBiometricTypesText deve retornar texto correto', () {
      // Teste será executado apenas em dispositivo real com biometria
      // Este é um teste de unidade para a lógica de formatação
      final text = biometricService.getBiometricTypesText([]);
      expect(text, 'Nenhuma');
    });
  });

  group('BiometricService Singleton Tests', () {
    test('deve retornar sempre a mesma instância', () {
      final instance1 = BiometricService();
      final instance2 = BiometricService();

      expect(identical(instance1, instance2), true);
    });
  });
}
