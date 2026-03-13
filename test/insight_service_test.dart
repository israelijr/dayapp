import 'package:dayapp/models/insight.dart';
import 'package:dayapp/services/insight_service.dart';
import 'package:dayapp/services/word_insight_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsightService word insights', () {
    final service = InsightService();

    test('cria insights de palavras positivas e difíceis', () {
      const analysis = WordInsightAnalysis(
        positiveWords: [
          WordAssociation(word: 'amigos', frequency: 4, averageMood: 4.5),
          WordAssociation(word: 'parque', frequency: 3, averageMood: 4.3),
        ],
        difficultWords: [
          WordAssociation(word: 'problema', frequency: 4, averageMood: 1.5),
          WordAssociation(word: 'atraso', frequency: 3, averageMood: 1.8),
        ],
        totalStoriesAnalyzed: 8,
        totalUniqueWords: 12,
      );

      final insights = service.createWordInsights(analysis);

      expect(insights.map((item) => item.type).toList(), [
        InsightType.positiveWords,
        InsightType.difficultWords,
      ]);
      expect(insights.first.metadata?['words'], ['amigos', 'parque']);
      expect(insights.first.metadata?['search_query'], 'amigos');
      expect(insights.last.metadata?['words'], ['problema', 'atraso']);
      expect(insights.last.metadata?['search_query'], 'problema');
    });

    test('não cria insights quando não há palavras elegíveis', () {
      const analysis = WordInsightAnalysis(
        positiveWords: [],
        difficultWords: [],
        totalStoriesAnalyzed: 3,
        totalUniqueWords: 4,
      );

      expect(service.createWordInsights(analysis), isEmpty);
    });
  });
}
