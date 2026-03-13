import '../helpers/rich_text_helper.dart';

/// Entrada textual simplificada usada na análise por palavras.
class StoryTextEntry {
  final String title;
  final String? description;
  final int mood;

  const StoryTextEntry({
    required this.title,
    required this.description,
    required this.mood,
  });

  /// Texto consolidado da história para análise.
  String get combinedText {
    final rawDescription = description?.trim() ?? '';
    final plainDescription = rawDescription.isEmpty
        ? ''
        : RichTextHelper.isValidQuillJson(rawDescription)
        ? RichTextHelper.jsonToPlainText(rawDescription).trim()
        : rawDescription;
    final parts = <String>[title.trim()];
    if (plainDescription.isNotEmpty) {
      parts.add(plainDescription);
    }
    return parts.where((part) => part.isNotEmpty).join(' ').trim();
  }
}

/// Estatísticas agregadas de uma palavra após o processamento.
class WordAssociation {
  final String word;
  final int frequency;
  final double averageMood;

  const WordAssociation({
    required this.word,
    required this.frequency,
    required this.averageMood,
  });
}

/// Resultado completo da análise textual por histórias.
class WordInsightAnalysis {
  final List<WordAssociation> positiveWords;
  final List<WordAssociation> difficultWords;
  final int totalStoriesAnalyzed;
  final int totalUniqueWords;

  const WordInsightAnalysis({
    required this.positiveWords,
    required this.difficultWords,
    required this.totalStoriesAnalyzed,
    required this.totalUniqueWords,
  });

  bool get hasAnyInsight =>
      positiveWords.isNotEmpty || difficultWords.isNotEmpty;
}

class _WordAccumulator {
  int frequency = 0;
  int moodSum = 0;

  void add(int mood) {
    frequency += 1;
    moodSum += mood;
  }
}

/// Analisa o texto das histórias para descobrir palavras recorrentes.
///
/// A estratégia desta fase prioriza previsibilidade e baixo custo:
/// - normaliza texto
/// - remove stopwords
/// - ignora palavras curtas
/// - conta cada palavra no máximo uma vez por história
/// - calcula média de humor por palavra
class WordInsightAnalyzer {
  static const int defaultMinWordLength = 4;
  static const int defaultMinFrequency = 3;
  static const int defaultTopWordsLimit = 5;
  static const double defaultPositiveMoodThreshold = 3.4;
  static const double defaultDifficultMoodThreshold = 2.6;

  static const Map<String, String> _accentMap = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ý': 'y',
    'ÿ': 'y',
  };

  static const Set<String> _defaultStopwords = {
    'a',
    'ainda',
    'ali',
    'ao',
    'aos',
    'aquela',
    'aquelas',
    'aquele',
    'aqueles',
    'aquilo',
    'agora',
    'amanha',
    'antes',
    'as',
    'assim',
    'ate',
    'aqui',
    'com',
    'como',
    'contra',
    'daqui',
    'da',
    'das',
    'dali',
    'dessa',
    'dessas',
    'desse',
    'desses',
    'de',
    'dela',
    'delas',
    'dele',
    'deles',
    'depois',
    'do',
    'dos',
    'e',
    'ela',
    'elas',
    'ele',
    'eles',
    'em',
    'entre',
    'era',
    'eram',
    'essa',
    'essas',
    'esse',
    'esses',
    'esta',
    'está',
    'estao',
    'durante',
    'enquanto',
    'estar',
    'estas',
    'estava',
    'estavam',
    'este',
    'estes',
    'eu',
    'foi',
    'foram',
    'ha',
    'hoje',
    'ontem',
    'isso',
    'isto',
    'ja',
    'la',
    'logo',
    'mais',
    'mas',
    'me',
    'meu',
    'meus',
    'minha',
    'minhas',
    'muito',
    'na',
    'nao',
    'nas',
    'nem',
    'no',
    'nos',
    'nossa',
    'nossas',
    'nosso',
    'nossos',
    'onde',
    'num',
    'numa',
    'o',
    'os',
    'ou',
    'para',
    'pela',
    'pelas',
    'pelo',
    'pelos',
    'por',
    'porque',
    'pra',
    'pras',
    'pro',
    'pros',
    'quando',
    'que',
    'quem',
    'se',
    'sem',
    'ser',
    'seu',
    'seus',
    'sua',
    'suas',
    'tambem',
    'te',
    'tem',
    'tendo',
    'tenho',
    'ter',
    'teve',
    'tinha',
    'tinham',
    'to',
    'toda',
    'todas',
    'todo',
    'todos',
    'tu',
    'um',
    'uma',
    'umas',
    'uns',
    'vou',
  };

  const WordInsightAnalyzer();

  String normalizeText(String text) {
    var normalized = text.toLowerCase().trim();

    for (final entry in _accentMap.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  List<String> tokenize(
    String text, {
    int minWordLength = defaultMinWordLength,
    Set<String> stopwords = _defaultStopwords,
  }) {
    if (text.trim().isEmpty) return const [];

    final normalized = normalizeText(text);
    if (normalized.isEmpty) return const [];

    return normalized
        .split(' ')
        .where((token) => token.isNotEmpty)
        .where((token) => token.length >= minWordLength)
        .where((token) => !RegExp(r'\d').hasMatch(token))
        .where((token) => !stopwords.contains(token))
        .toList(growable: false);
  }

  WordInsightAnalysis analyzeStories(
    Iterable<StoryTextEntry> stories, {
    int minWordLength = defaultMinWordLength,
    int minFrequency = defaultMinFrequency,
    int topWordsLimit = defaultTopWordsLimit,
    double positiveMoodThreshold = defaultPositiveMoodThreshold,
    double difficultMoodThreshold = defaultDifficultMoodThreshold,
    bool countWordOncePerStory = true,
    Set<String> stopwords = _defaultStopwords,
  }) {
    final accumulators = <String, _WordAccumulator>{};
    var totalStoriesAnalyzed = 0;

    for (final story in stories) {
      final text = story.combinedText;
      if (text.isEmpty) {
        continue;
      }

      final tokens = tokenize(
        text,
        minWordLength: minWordLength,
        stopwords: stopwords,
      );
      if (tokens.isEmpty) {
        continue;
      }

      totalStoriesAnalyzed += 1;
      final iterable = countWordOncePerStory ? tokens.toSet() : tokens;
      for (final word in iterable) {
        final accumulator = accumulators.putIfAbsent(
          word,
          _WordAccumulator.new,
        );
        accumulator.add(story.mood);
      }
    }

    final rankedWords = accumulators.entries
        .where((entry) => entry.value.frequency >= minFrequency)
        .map(
          (entry) => WordAssociation(
            word: entry.key,
            frequency: entry.value.frequency,
            averageMood: entry.value.moodSum / entry.value.frequency,
          ),
        )
        .toList(growable: false);

    List<WordAssociation> rank(
      bool Function(WordAssociation association) predicate,
      bool descendingMood,
    ) {
      final filtered = rankedWords.where(predicate).toList();
      filtered.sort((a, b) {
        final frequencyCompare = b.frequency.compareTo(a.frequency);
        if (frequencyCompare != 0) return frequencyCompare;

        final moodCompare = descendingMood
            ? b.averageMood.compareTo(a.averageMood)
            : a.averageMood.compareTo(b.averageMood);
        if (moodCompare != 0) return moodCompare;

        return a.word.compareTo(b.word);
      });
      return filtered.take(topWordsLimit).toList(growable: false);
    }

    return WordInsightAnalysis(
      positiveWords: rank(
        (association) => association.averageMood >= positiveMoodThreshold,
        true,
      ),
      difficultWords: rank(
        (association) => association.averageMood <= difficultMoodThreshold,
        false,
      ),
      totalStoriesAnalyzed: totalStoriesAnalyzed,
      totalUniqueWords: accumulators.length,
    );
  }
}
