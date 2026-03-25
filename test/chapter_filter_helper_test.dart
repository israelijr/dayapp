import 'package:dayapp/helpers/chapter_filter_helper.dart';
import 'package:dayapp/models/capitulo.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers para criar objetos de teste sem banco de dados
// ---------------------------------------------------------------------------

Capitulo _cap({
  required String titulo,
  String? descricao,
  DateTime? dataInicio,
  DateTime? dataFim,
  bool automatico = false,
  int id = 1,
}) {
  return Capitulo(
    id: id,
    userId: 'user1',
    titulo: titulo,
    descricao: descricao,
    dataInicio: dataInicio ?? DateTime(2024, 1, 1),
    dataFim: dataFim ?? DateTime(2024, 1, 31),
    criadoAutomaticamente: automatico,
  );
}

CapituloResumo _resumo({
  required Capitulo capitulo,
  int totalEntradas = 5,
  List<String> topTags = const [],
}) {
  return CapituloResumo(
    capitulo: capitulo,
    totalEntradas: totalEntradas,
    humorMedio: 3.0,
    topTags: topTags,
  );
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  // ---- matchesChapterFilter -----------------------------------------------

  group('matchesChapterFilter — busca por texto', () {
    final resumo = _resumo(
      capitulo: _cap(titulo: 'Viagem ao Sul', descricao: 'dias incríveis'),
      topTags: ['aventura', 'família'],
    );

    test('consulta vazia corresponde a qualquer capítulo', () {
      expect(matchesChapterFilter(resumo, '', ChapterOriginFilter.all), isTrue);
    });

    test('encontra pelo título (case-insensitive)', () {
      expect(
        matchesChapterFilter(resumo, 'VIAGEM', ChapterOriginFilter.all),
        isTrue,
      );
    });

    test('encontra pela descrição', () {
      expect(
        matchesChapterFilter(resumo, 'incríveis', ChapterOriginFilter.all),
        isTrue,
      );
    });

    test('encontra pela tag', () {
      expect(
        matchesChapterFilter(resumo, 'família', ChapterOriginFilter.all),
        isTrue,
      );
    });

    test('não encontra texto inexistente', () {
      expect(
        matchesChapterFilter(resumo, 'xyzzy', ChapterOriginFilter.all),
        isFalse,
      );
    });

    test('espaços em branco na consulta são ignorados', () {
      expect(
        matchesChapterFilter(resumo, '   sul   ', ChapterOriginFilter.all),
        isTrue,
      );
    });
  });

  group('matchesChapterFilter — filtro por origem', () {
    final automatico = _resumo(
      capitulo: _cap(titulo: 'Auto', automatico: true),
    );
    final manual = _resumo(capitulo: _cap(titulo: 'Manual', automatico: false));

    test('filtro "all" aceita automáticos', () {
      expect(
        matchesChapterFilter(automatico, '', ChapterOriginFilter.all),
        isTrue,
      );
    });

    test('filtro "all" aceita manuais', () {
      expect(matchesChapterFilter(manual, '', ChapterOriginFilter.all), isTrue);
    });

    test('filtro "automatic" aceita apenas automáticos', () {
      expect(
        matchesChapterFilter(automatico, '', ChapterOriginFilter.automatic),
        isTrue,
      );
      expect(
        matchesChapterFilter(manual, '', ChapterOriginFilter.automatic),
        isFalse,
      );
    });

    test('filtro "manual" aceita apenas manuais', () {
      expect(
        matchesChapterFilter(manual, '', ChapterOriginFilter.manual),
        isTrue,
      );
      expect(
        matchesChapterFilter(automatico, '', ChapterOriginFilter.manual),
        isFalse,
      );
    });

    test('texto e filtro de origem combinados', () {
      // Automático com título que contém "Auto" — passa filtro automatic + query
      expect(
        matchesChapterFilter(automatico, 'auto', ChapterOriginFilter.automatic),
        isTrue,
      );
      // Automático com título que NÃO corresponde ao filtro manual — falha
      expect(
        matchesChapterFilter(automatico, 'auto', ChapterOriginFilter.manual),
        isFalse,
      );
    });
  });

  // ---- sortCapitulos --------------------------------------------------------

  group('sortCapitulos', () {
    final jan = _resumo(
      capitulo: _cap(titulo: 'Zebra', dataInicio: DateTime(2024, 1, 1), id: 1),
      totalEntradas: 10,
    );
    final mar = _resumo(
      capitulo: _cap(titulo: 'Alpha', dataInicio: DateTime(2024, 3, 1), id: 2),
      totalEntradas: 4,
    );
    final jun = _resumo(
      capitulo: _cap(titulo: 'Médio', dataInicio: DateTime(2024, 6, 1), id: 3),
      totalEntradas: 7,
    );

    final lista = [jan, mar, jun];

    test('newestPeriod ordena do mais recente para o mais antigo', () {
      final sorted = sortCapitulos(lista, ChapterSortOption.newestPeriod);
      expect(sorted.map((r) => r.capitulo.id), [3, 2, 1]);
    });

    test('oldestPeriod ordena do mais antigo para o mais recente', () {
      final sorted = sortCapitulos(lista, ChapterSortOption.oldestPeriod);
      expect(sorted.map((r) => r.capitulo.id), [1, 2, 3]);
    });

    test('title ordena alfabeticamente (case-insensitive)', () {
      final sorted = sortCapitulos(lista, ChapterSortOption.title);
      // Alpha, Médio, Zebra
      expect(sorted.map((r) => r.capitulo.titulo), ['Alpha', 'Médio', 'Zebra']);
    });

    test('stories ordena pela maior quantidade de histórias', () {
      final sorted = sortCapitulos(lista, ChapterSortOption.stories);
      // 10, 7, 4
      expect(sorted.map((r) => r.totalEntradas), [10, 7, 4]);
    });

    test('não modifica a lista original', () {
      final original = [...lista];
      sortCapitulos(lista, ChapterSortOption.newestPeriod);
      expect(lista, equals(original));
    });

    test('lista vazia não gera erro', () {
      expect(sortCapitulos([], ChapterSortOption.newestPeriod), isEmpty);
    });
  });
}
