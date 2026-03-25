import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/services/capitulo_save_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CapituloSaveService - Validação', () {
    final mockL10n = _MockAppLocalizations();
    final service = CapituloSaveService();

    test('validateCapituloConfig: retorna null se modo é none', () {
      final result = service.validateCapituloConfig(
        modo: CapituloVinculoModo.none,
        l10n: mockL10n,
      );
      expect(result, isNull);
    });

    test(
      'validateCapituloConfig: retorna erro se modo existing sem capituloId',
      () {
        final result = service.validateCapituloConfig(
          modo: CapituloVinculoModo.existing,
          l10n: mockL10n,
          capituloId: null,
        );
        expect(result, equals('Please select an existing chapter'));
      },
    );

    test('validateCapituloConfig: passa se modo existing com capituloId', () {
      final result = service.validateCapituloConfig(
        modo: CapituloVinculoModo.existing,
        l10n: mockL10n,
        capituloId: 42,
      );
      expect(result, isNull);
    });

    test('validateCapituloConfig: retorna erro se newChapter sem título', () {
      final result = service.validateCapituloConfig(
        modo: CapituloVinculoModo.newChapter,
        l10n: mockL10n,
        novoCapituloTitulo: '',
        novoCapituloEntradasCount: 3,
      );
      expect(result, equals('Chapter title is required'));
    });

    test(
      'validateCapituloConfig: retorna erro se newChapter com < 3 entradas',
      () {
        final result = service.validateCapituloConfig(
          modo: CapituloVinculoModo.newChapter,
          l10n: mockL10n,
          novoCapituloTitulo: 'Meu Capítulo',
          novoCapituloEntradasCount: 2,
        );
        expect(result, equals('At least 3 related entries are required'));
      },
    );

    test('validateCapituloConfig: passa se newChapter com 3+ entradas', () {
      final result = service.validateCapituloConfig(
        modo: CapituloVinculoModo.newChapter,
        l10n: mockL10n,
        novoCapituloTitulo: 'Meu Capítulo',
        novoCapituloEntradasCount: 3,
      );
      expect(result, isNull);
    });

    test('validateCapituloConfig: passa se newChapter com muitas entradas', () {
      final result = service.validateCapituloConfig(
        modo: CapituloVinculoModo.newChapter,
        l10n: mockL10n,
        novoCapituloTitulo: 'Outro Capítulo',
        novoCapituloEntradasCount: 10,
      );
      expect(result, isNull);
    });
  });
}

class _MockAppLocalizations implements AppLocalizations {
  @override
  String get chapterSelectExistingRequired =>
      'Please select an existing chapter';
  @override
  String get chapterTitleRequired => 'Chapter title is required';
  @override
  String get chapterMinimumRelatedWithCurrent =>
      'At least 3 related entries are required';

  @override
  Never noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
