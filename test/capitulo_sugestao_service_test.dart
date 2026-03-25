import 'package:dayapp/db/capitulo_helper.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/services/capitulo_sugestao_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCapituloHelper extends CapituloHelper {
  FakeCapituloHelper({
    required this.entradas,
    this.ignoradas = const <String>{},
    this.vinculadas = const <int>{},
  });

  final List<Historia> entradas;
  final Set<String> ignoradas;
  final Set<int> vinculadas;

  @override
  Future<List<Historia>> listEntradasElegiveis(String userId) async => entradas;

  @override
  Future<Set<String>> getIgnoredSuggestionFingerprints(String userId) async {
    return ignoradas;
  }

  @override
  Future<Set<int>> getEntradasJaVinculadas(String userId) async {
    return vinculadas;
  }
}

Historia _entry({
  required int id,
  required DateTime data,
  required String titulo,
  required String? tag,
  String descricao = '',
}) {
  return Historia(
    id: id,
    userId: 'u1',
    titulo: titulo,
    data: data,
    tag: tag,
    descricao: descricao,
    humor: 4,
    energia: 2,
  );
}

void main() {
  group('CapituloSugestaoService', () {
    test(
      'retorna vazio quando houver menos de 4 entradas candidatas',
      () async {
        final helper = FakeCapituloHelper(
          entradas: [
            _entry(
              id: 1,
              data: DateTime(2026, 1, 1),
              titulo: 'Entrada 1',
              tag: 'trabalho',
            ),
            _entry(
              id: 2,
              data: DateTime(2026, 1, 2),
              titulo: 'Entrada 2',
              tag: 'trabalho',
            ),
            _entry(
              id: 3,
              data: DateTime(2026, 1, 3),
              titulo: 'Entrada 3',
              tag: 'trabalho',
            ),
          ],
        );

        final service = CapituloSugestaoService(capituloHelper: helper);
        final sugestoes = await service.sugerirCapitulos('u1');

        expect(sugestoes, isEmpty);
      },
    );

    test('gera sugestao com 4 entradas e usa top tag no titulo', () async {
      final helper = FakeCapituloHelper(
        entradas: [
          _entry(
            id: 10,
            data: DateTime(2026, 1, 1),
            titulo: 'Planejamento',
            tag: 'trabalho, projeto',
            descricao: 'Foco no projeto com equipe',
          ),
          _entry(
            id: 11,
            data: DateTime(2026, 1, 7),
            titulo: 'Execucao',
            tag: 'trabalho',
            descricao: 'Reuniao e entregas do projeto',
          ),
          _entry(
            id: 12,
            data: DateTime(2026, 1, 15),
            titulo: 'Ajustes',
            tag: 'trabalho',
            descricao: 'Revisao com equipe e entregas',
          ),
          _entry(
            id: 13,
            data: DateTime(2026, 1, 22),
            titulo: 'Conclusao',
            tag: 'trabalho',
            descricao: 'Projeto finalizado com equipe',
          ),
        ],
      );

      final service = CapituloSugestaoService(capituloHelper: helper);
      final sugestoes = await service.sugerirCapitulos('u1');

      expect(sugestoes.length, 1);
      final s = sugestoes.first;
      expect(s.tituloSugerido, 'Trabalho');
      expect(s.entradaIds, [10, 11, 12, 13]);
      expect(s.fingerprint, '10-11-12-13');
      expect(s.topTags.first, 'trabalho');
      expect(s.entradas.map((e) => e.id).toList(), [13, 12, 11, 10]);
    });

    test('nao sugere quando fingerprint ja foi ignorado', () async {
      final helper = FakeCapituloHelper(
        entradas: [
          _entry(id: 1, data: DateTime(2026, 2, 1), titulo: 'E1', tag: 'saude'),
          _entry(id: 2, data: DateTime(2026, 2, 2), titulo: 'E2', tag: 'saude'),
          _entry(id: 3, data: DateTime(2026, 2, 3), titulo: 'E3', tag: 'saude'),
          _entry(id: 4, data: DateTime(2026, 2, 4), titulo: 'E4', tag: 'saude'),
        ],
        ignoradas: {'1-2-3-4'},
      );

      final service = CapituloSugestaoService(capituloHelper: helper);
      final sugestoes = await service.sugerirCapitulos('u1');

      expect(sugestoes, isEmpty);
    });

    test(
      'desconsidera entradas ja vinculadas e pode ficar abaixo do minimo',
      () async {
        final helper = FakeCapituloHelper(
          entradas: [
            _entry(
              id: 21,
              data: DateTime(2026, 3, 1),
              titulo: 'E1',
              tag: 'familia',
            ),
            _entry(
              id: 22,
              data: DateTime(2026, 3, 2),
              titulo: 'E2',
              tag: 'familia',
            ),
            _entry(
              id: 23,
              data: DateTime(2026, 3, 3),
              titulo: 'E3',
              tag: 'familia',
            ),
            _entry(
              id: 24,
              data: DateTime(2026, 3, 4),
              titulo: 'E4',
              tag: 'familia',
            ),
          ],
          vinculadas: {24},
        );

        final service = CapituloSugestaoService(capituloHelper: helper);
        final sugestoes = await service.sugerirCapitulos('u1');

        expect(sugestoes, isEmpty);
      },
    );

    test(
      'nao agrupa quando intervalo entre entradas passa de 30 dias',
      () async {
        final helper = FakeCapituloHelper(
          entradas: [
            _entry(
              id: 31,
              data: DateTime(2026, 1, 1),
              titulo: 'E1',
              tag: 'carreira',
            ),
            _entry(
              id: 32,
              data: DateTime(2026, 1, 10),
              titulo: 'E2',
              tag: 'carreira',
            ),
            _entry(
              id: 33,
              data: DateTime(2026, 1, 20),
              titulo: 'E3',
              tag: 'carreira',
            ),
            _entry(
              id: 34,
              data: DateTime(2026, 3, 5),
              titulo: 'E4',
              tag: 'carreira',
            ),
          ],
        );

        final service = CapituloSugestaoService(capituloHelper: helper);
        final sugestoes = await service.sugerirCapitulos('u1');

        expect(sugestoes, isEmpty);
      },
    );

    test(
      'nao agrupa quando similaridade fica abaixo do limiar minimo',
      () async {
        final helper = FakeCapituloHelper(
          entradas: [
            _entry(
              id: 41,
              data: DateTime(2026, 4, 1),
              titulo: 'Treino de corrida',
              tag: 'esporte',
              descricao: 'atividade fisica no parque',
            ),
            _entry(
              id: 42,
              data: DateTime(2026, 4, 2),
              titulo: 'Curso de ingles',
              tag: 'estudo',
              descricao: 'aula de gramatica e vocabulario',
            ),
            _entry(
              id: 43,
              data: DateTime(2026, 4, 3),
              titulo: 'Revisao financeira',
              tag: 'financas',
              descricao: 'planilha de custos e despesas',
            ),
            _entry(
              id: 44,
              data: DateTime(2026, 4, 4),
              titulo: 'Consulta medica',
              tag: 'saude',
              descricao: 'retorno clinico e exames',
            ),
          ],
        );

        final service = CapituloSugestaoService(capituloHelper: helper);
        final sugestoes = await service.sugerirCapitulos('u1');

        expect(sugestoes, isEmpty);
      },
    );

    test(
      'usa top palavra no titulo quando nao houver tags relevantes',
      () async {
        final helper = FakeCapituloHelper(
          entradas: [
            _entry(
              id: 51,
              data: DateTime(2026, 5, 1),
              titulo: 'Log',
              tag: null,
              descricao: 'viagem praia familia descanso',
            ),
            _entry(
              id: 52,
              data: DateTime(2026, 5, 5),
              titulo: 'Log',
              tag: null,
              descricao: 'viagem familia passeio',
            ),
            _entry(
              id: 53,
              data: DateTime(2026, 5, 10),
              titulo: 'Log',
              tag: null,
              descricao: 'viagem roteiro passeio',
            ),
            _entry(
              id: 54,
              data: DateTime(2026, 5, 15),
              titulo: 'Log',
              tag: null,
              descricao: 'viagem passeio descanso',
            ),
          ],
        );

        final service = CapituloSugestaoService(capituloHelper: helper);
        final sugestoes = await service.sugerirCapitulos('u1');

        expect(sugestoes.length, 1);
        expect(sugestoes.first.tituloSugerido, 'Viagem');
        expect(sugestoes.first.topTags, isEmpty);
        expect(sugestoes.first.topPalavras.first, 'viagem');
      },
    );
  });
}
