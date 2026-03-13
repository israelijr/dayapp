import 'package:dayapp/services/word_insight_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const analyzer = WordInsightAnalyzer();

  group('WordInsightAnalyzer', () {
    test('normaliza texto removendo acentos e pontuacao', () {
      final normalized = analyzer.normalizeText(
        'Hoje fui ao parque, com meus amigos! Café e reunião.',
      );

      expect(normalized, 'hoje fui ao parque com meus amigos cafe e reuniao');
    });

    test('tokeniza removendo stopwords, numeros e palavras curtas', () {
      final tokens = analyzer.tokenize(
        'Hoje fui ao parque com meus amigos em 2026 e foi muito bom',
      );

      expect(tokens, ['parque', 'amigos']);
    });

    test('remove palavras neutras de tempo como agora', () {
      final tokens = analyzer.tokenize(
        'Agora me sinto bem com amigos no parque',
      );

      expect(tokens, ['sinto', 'amigos', 'parque']);
      expect(tokens, isNot(contains('agora')));
    });

    test('remove palavras funcionais sem perder contexto util', () {
      final tokens = analyzer.tokenize(
        'Agora aqui e ali penso no trabalho e depois volto ao parque com amigos',
      );

      expect(tokens, ['penso', 'trabalho', 'volto', 'parque', 'amigos']);
      expect(tokens, isNot(contains('agora')));
      expect(tokens, isNot(contains('aqui')));
      expect(tokens, isNot(contains('ali')));
      expect(tokens, isNot(contains('depois')));
    });

    test('conta cada palavra uma vez por historia por padrao', () {
      final analysis = analyzer.analyzeStories(
        const [
          StoryTextEntry(
            title: 'Parque',
            description: 'parque parque amigos',
            mood: 5,
          ),
          StoryTextEntry(
            title: 'Passeio',
            description: 'parque com amigos',
            mood: 4,
          ),
        ],
        minFrequency: 2,
        positiveMoodThreshold: 3.0,
        topWordsLimit: 5,
      );

      final parque = analysis.positiveWords.firstWhere(
        (association) => association.word == 'parque',
      );

      expect(parque.frequency, 2);
      expect(parque.averageMood, 4.5);
    });

    test('separa palavras positivas e dificeis com ranking por frequencia', () {
      final analysis = analyzer.analyzeStories(
        const [
          StoryTextEntry(
            title: 'Viagem com amigos',
            description: 'Passeio no parque com amigos',
            mood: 5,
          ),
          StoryTextEntry(
            title: 'Passeio leve',
            description: 'Parque e viagem com amigos',
            mood: 4,
          ),
          StoryTextEntry(
            title: 'Viagem especial',
            description: 'Amigos no parque',
            mood: 5,
          ),
          StoryTextEntry(
            title: 'Problema no trabalho',
            description: 'Atraso e cobranca no trabalho',
            mood: 1,
          ),
          StoryTextEntry(
            title: 'Mais problema',
            description: 'Cobranca e atraso no trabalho',
            mood: 2,
          ),
          StoryTextEntry(
            title: 'Problema recorrente',
            description: 'Atraso no trabalho',
            mood: 1,
          ),
        ],
        minFrequency: 3,
        positiveMoodThreshold: 3.5,
        difficultMoodThreshold: 2.5,
        topWordsLimit: 3,
      );

      expect(
        analysis.positiveWords.map((association) => association.word).toList(),
        ['amigos', 'parque', 'viagem'],
      );
      expect(
        analysis.difficultWords.map((association) => association.word).toList(),
        ['atraso', 'problema', 'trabalho'],
      );
      expect(analysis.totalStoriesAnalyzed, 6);
      expect(analysis.hasAnyInsight, isTrue);
    });
  });
}
