import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Inicializa binding e registra mocks comuns para testes:
/// - `path_provider` -> getApplicationDocumentsDirectory retorna `/tmp`
/// - `flutter_secure_storage` canais (duas variantes) com armazenamento em memória
void initTestBindingsAndMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock do SharedPreferences para evitar MissingPluginException
  SharedPreferences.setMockInitialValues({});

  // Mock do path_provider
  const MethodChannel pathChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathChannel, (call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return '/tmp';
        }
        return null;
      });

  // Mocks para flutter_secure_storage (duas possíveis channels usadas em ambientes diferentes)
  const MethodChannel secureStorageChannel = MethodChannel(
    'plugins.flutter.io/flutter_secure_storage',
  );
  const MethodChannel secureStorageChannelAlt = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final Map<String, String?> secureStorage = {};

  Future<dynamic> secureHandler(MethodCall call) async {
    final args = call.arguments is Map
        ? Map<String, dynamic>.from(call.arguments as Map)
        : <String, dynamic>{};
    switch (call.method) {
      case 'write':
        final key = args['key'] as String;
        final value = args['value'] as String?;
        secureStorage[key] = value;
        return null;
      case 'read':
        final key = args['key'] as String;
        return secureStorage[key];
      case 'delete':
        final key = args['key'] as String;
        secureStorage.remove(key);
        return null;
      case 'deleteAll':
        secureStorage.clear();
        return null;
      default:
        return null;
    }
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, secureHandler);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannelAlt, secureHandler);
}

/// Remove os mocks registrados (opcionalmente chamar em tearDownAll)
void clearTestMocks() {
  const MethodChannel pathChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathChannel, null);
  const MethodChannel secureStorageChannel = MethodChannel(
    'plugins.flutter.io/flutter_secure_storage',
  );
  const MethodChannel secureStorageChannelAlt = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannelAlt, null);
}
