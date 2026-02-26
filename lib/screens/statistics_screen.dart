// ignore_for_file: unused_local_variable

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';

import '../db/database_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/statistics_provider.dart';
import '../theme/m3_expressive_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Historia> _historias = [];
  bool _isLoading = true;
  final Map<String, int> _emoticonCounts = {};
  final Map<String, double> _emoticonPercentages = {};
  int _longestStreak = 0;
  List<bool> _weekDays = List.filled(7, false);
  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _timeSeries = [];
  List<Map<String, dynamic>> _heatmapRows = [];
  List<Map<String, dynamic>> _topTags = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    // Capturar providers/context antes de qualquer await para evitar uso
    // de BuildContext após gaps assíncronos.
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final statsProvider = Provider.of<StatisticsProvider>(
      context,
      listen: false,
    );
    final String? userId = auth.user?.id; // null se usuário não autenticado

    final db = await DatabaseHelper().database;

    // Buscar todas as histórias não excluídas (ainda usadas para charts locais)
    final result = await db.query(
      'historia',
      where: userId != null
          ? 'user_id = ? AND excluido IS NULL'
          : 'excluido IS NULL',
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'data DESC',
    );

    _historias = result.map((map) => Historia.fromMap(map)).toList();

    // Usar StatisticsProvider para métricas já encapsuladas (capturado acima)

    try {
      final emotionRows = await statsProvider.fetchEmotionBreakdown(
        userId: userId,
      );
      _emoticonCounts.clear();
      for (final row in emotionRows) {
        final key = (row['key'] ?? '') as String;
        final cnt = (row['cnt'] ?? 0) as int;
        if (key.isNotEmpty) {
          _emoticonCounts[key] = cnt;
        }
      }

      // calcular porcentagens locally
      final total = _emoticonCounts.values.fold<int>(0, (s, v) => s + v);
      _emoticonPercentages.clear();
      if (total > 0) {
        _emoticonCounts.forEach((k, v) {
          _emoticonPercentages[k] = (v / total) * 100;
        });
      }

      final streaks = await statsProvider.fetchStreaks(userId: userId);
      _longestStreak = streaks['bestStreak'] ?? 0;

      // Buscar overview, série temporal, heatmap e top tags
      _overview = await statsProvider.fetchOverview(userId: userId);
      _timeSeries = await statsProvider.fetchTimeSeries(
        days: 30,
        userId: userId,
      );
      _heatmapRows = await statsProvider.fetchHeatmap(userId: userId);
      _topTags = await statsProvider.fetchTopTags(limit: 10, userId: userId);

      // manter cálculo local de _weekDays (exibe últimos 7 dias)
      _calculateStreaks();
    } catch (e) {
      // fallback: manter cálculos locais caso provider falhe
      _calculateEmoticonStatistics();
      _calculateStreaks();
    }

    setState(() => _isLoading = false);
  }

  void _calculateEmoticonStatistics() {
    _emoticonCounts.clear();

    for (var historia in _historias) {
      if (historia.emoticon != null && historia.emoticon!.isNotEmpty) {
        final emoticon = _normalizeEmoticon(historia.emoticon!);
        _emoticonCounts[emoticon] = (_emoticonCounts[emoticon] ?? 0) + 1;
      }
    }

    // Calcular porcentagens
    final total = _emoticonCounts.values.fold(0, (sum, count) => sum + count);
    _emoticonPercentages.clear();

    if (total > 0) {
      _emoticonCounts.forEach((emoticon, count) {
        _emoticonPercentages[emoticon] = (count / total) * 100;
      });
    }
  }

  void _calculateStreaks() {
    if (_historias.isEmpty) {
      _longestStreak = 0;
      _weekDays = List.filled(7, false);
      return;
    }

    // Ordenar por data crescente
    final sortedHistorias = List<Historia>.from(_historias)
      ..sort((a, b) => a.data.compareTo(b.data));

    // Obter datas únicas
    final uniqueDates = <DateTime>{};
    for (var historia in sortedHistorias) {
      final date = DateTime(
        historia.data.year,
        historia.data.month,
        historia.data.day,
      );
      uniqueDates.add(date);
    }

    final sortedDates = uniqueDates.toList()..sort();

    // Calcular streak mais longa
    int currentStreak = 1;
    int longestStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        longestStreak = math.max(longestStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }

    // Calcular streak atual
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate = sortedDates.last;
    final daysSinceLastEntry = todayDate.difference(lastDate).inDays;

    if (daysSinceLastEntry <= 1) {
      int streak = 1;
      for (int i = sortedDates.length - 2; i >= 0; i--) {
        final diff = sortedDates[i + 1].difference(sortedDates[i]).inDays;
        if (diff == 1) {
          streak++;
        } else {
          break;
        }
      }
    } else {}

    _longestStreak = longestStreak;

    // Calcular dias da semana (últimos 7 dias)
    _weekDays = List.filled(7, false);
    for (int i = 0; i < 7; i++) {
      final date = todayDate.subtract(Duration(days: 6 - i));
      _weekDays[i] = uniqueDates.contains(date);
    }
  }

  String _normalizeEmoticon(String emoticon) {
    // Mapear emoticons similares
    switch (emoticon.toLowerCase()) {
      case 'feliz':
        return 'Feliz';
      case 'tranquilo':
      case 'bem':
        return 'Bem';
      case 'aliviado':
      case 'ok':
        return 'OK';
      case 'triste':
        return 'Triste';
      case 'muito triste':
      case 'infeliz':
        return 'Infeliz';
      default:
        return emoticon;
    }
  }

  Color _getEmoticonColor(String emoticon) {
    switch (emoticon.toLowerCase()) {
      case 'feliz':
        return AppColors.emoticonBlue; // Azul claro
      case 'bem':
        return AppColors.emoticonTeal; // Verde água
      case 'ok':
        return AppColors.emoticonLightPurple; // Roxo claro
      case 'triste':
        return AppColors.emoticonOrange; // Laranja
      case 'infeliz':
        return AppColors.emoticonPink; // Rosa
      case 'preocupado':
        return AppColors.emoticonGreen; // Verde
      case 'bravo':
        return AppColors.emoticonRed; // Vermelho claro
      case 'assustado':
        return AppColors.emoticonYellow; // Amarelo
      case 'pensativo':
        return AppColors.emoticonPurple; // Roxo
      case 'sono':
        return AppColors.emoticonBlue2; // Azul
      default:
        return AppColors.emoticonBlue2;
    }
  }

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna o próprio valor se já for um emoji
  String _convertLegacyEmoticon(String emoticon) {
    switch (emoticon.toLowerCase()) {
      case 'feliz':
        return '😊';
      case 'bem':
      case 'tranquilo':
        return '😌';
      case 'ok':
      case 'aliviado':
        return '😮‍💨';
      case 'pensativo':
        return '🤔';
      case 'sono':
        return '😴';
      case 'preocupado':
        return '😟';
      case 'assustado':
        return '😨';
      case 'bravo':
        return '😠';
      case 'triste':
        return '😢';
      case 'infeliz':
      case 'muito triste':
        return '😭';
      default:
        return emoticon; // Já é um emoji Unicode
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.statistics), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historias.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.noStoriesYetTitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.noStoriesYetSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildTendenciasCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildDiasSeguidosCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildTabelaHumoresCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildContagemHumorCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildTimeSeriesCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildHeatmapCard(context, isDark),
                    const SizedBox(height: 16),
                    _buildTopTagsCard(context, isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTendenciasCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    if (_emoticonPercentages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordenar por porcentagem decrescente
    final sortedEmoticons = _emoticonPercentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.trends,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Gráfico de pizza
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: PieChartPainter(
                      data: sortedEmoticons
                          .map((e) => MapEntry(e.key, e.value))
                          .toList(),
                      getColor: _getEmoticonColor,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Legenda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedEmoticons.take(5).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              _convertLegacyEmoticon(entry.key),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    final totalStories = _overview['totalStories'] ?? 0;
    final activeDays = _overview['activeDays'] ?? 0;
    final avg = (_overview['avgPerActiveDay'] ?? 0.0) as double;
    final totalMedia = _overview['totalMedia'] ?? 0;

    Widget infoTile(String title, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            infoTile(loc.storiesLabel, '$totalStories'),
            infoTile(loc.activeDaysLabel, '$activeDays'),
            infoTile(loc.avgPerDayLabel, avg.toStringAsFixed(1)),
            infoTile(loc.mediaLabel, '$totalMedia'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    if (_timeSeries.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.last30Days,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: LineSparklinePainter(data: _timeSeries),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    if (_heatmapRows.isEmpty) return const SizedBox.shrink();

    // Agregar por weekday
    final weekdayCounts = List<int>.filled(7, 0);
    for (final r in _heatmapRows) {
      final w = r['weekday'] is int
          ? r['weekday'] as int
          : int.parse(r['weekday'] as String);
      final cnt = r['count'] is int
          ? r['count'] as int
          : (r['count'] as num).toInt();
      weekdayCounts[w] += cnt;
    }

    final maxCnt = weekdayCounts.reduce((a, b) => a > b ? a : b);

    // nomes de dias curtos no locale atual
    final localeName = Localizations.localeOf(context).toString();
    final weekdayNames = List<String>.generate(7, (i) {
      // calcula data correspondente ao dia da semana i (0=domingo)
      final now = DateTime.now();
      // pega domingo da semana atual
      final sunday = now.subtract(Duration(days: now.weekday % 7));
      final date = sunday.add(Duration(days: i));
      return DateFormat.E(localeName).format(date);
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.activityByWeekday,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final cnt = weekdayCounts[i];
                final height = maxCnt > 0 ? (cnt / maxCnt) * 80 : 0.0;
                return Column(
                  children: [
                    Container(
                      width: 18,
                      height: height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(weekdayNames[i], style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTagsCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    if (_topTags.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.topTags,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: _topTags.map((t) {
                final tag = t['tag'] ?? t['key'] ?? '';
                final cnt = t['cnt'] ?? t['count'] ?? 0;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(tag.toString().substring(0, 1).toUpperCase()),
                  ),
                  title: Text(tag.toString()),
                  trailing: Text(cnt.toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiasSeguidosCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    final today = DateTime.now();
    // nomes de dias curtos (ex: Seg, Ter) no idioma atual
    final localeName = Localizations.localeOf(context).toString();
    final weekDayNames = List<String>.generate(7, (i) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - i));
      return DateFormat.E(localeName).format(date);
    });
    // não precisamos mais de startIndex pois calculamos diretamente pelo date acima

    return Builder(
      builder: (context) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.streaksTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final hasEntry = _weekDays[index];
                    final isToday = index == 6;

                    return Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasEntry
                                ? primaryColor
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            border: isToday && !hasEntry
                                ? Border.all(color: primaryColor, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: hasEntry
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : (isToday
                                      ? Text(
                                          '0',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                          size: 20,
                                        )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekDayNames[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${loc.longestStreakPrefix} ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '$_longestStreak',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabelaHumoresCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    if (_historias.isEmpty) return const SizedBox.shrink();

    // Agrupar histórias por data e calcular média de humor
    final Map<DateTime, List<String>> historiasPerDay = {};

    for (var historia in _historias) {
      final date = DateTime(
        historia.data.year,
        historia.data.month,
        historia.data.day,
      );
      if (historia.emoticon != null) {
        historiasPerDay.putIfAbsent(date, () => []).add(historia.emoticon!);
      }
    }

    // Pegar últimos 30 dias com dados
    final sortedDates = historiasPerDay.keys.toList()..sort();
    final recentDates = sortedDates.length > 30
        ? sortedDates.sublist(sortedDates.length - 30)
        : sortedDates;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.tableOfMoods,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: AreaChartPainter(
                  dates: recentDates,
                  historiasPerDay: historiasPerDay,
                  isDark: isDark,
                ),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContagemHumorCard(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    if (_emoticonCounts.isEmpty) return const SizedBox.shrink();

    final maxCount = _emoticonCounts.values.reduce(math.max);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.moodCount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: _emoticonCounts.entries.length <= 6
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _emoticonCounts.entries.map((entry) {
                        final height = (entry.value / maxCount) * 180;

                        return Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 28,
                                height: height,
                                decoration: BoxDecoration(
                                  color: _getEmoticonColor(entry.key),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _convertLegacyEmoticon(entry.key),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _emoticonCounts.entries.map((entry) {
                          final height = (entry.value / maxCount) * 180;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 28,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: _getEmoticonColor(entry.key),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _convertLegacyEmoticon(entry.key),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final Color Function(String) getColor;

  PieChartPainter({required this.data, required this.getColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2;

    for (var entry in data) {
      final sweepAngle = (entry.value / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = getColor(entry.key)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Desenhar círculo branco no centro
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AreaChartPainter extends CustomPainter {
  final List<DateTime> dates;
  final Map<DateTime, List<String>> historiasPerDay;
  final bool isDark;
  static const Color primaryColor = Color(0xFFB388FF);

  AreaChartPainter({
    required this.dates,
    required this.historiasPerDay,
    required this.isDark,
  });

  double _getEmoticonScore(String emoticon) {
    switch (emoticon.toLowerCase()) {
      case 'feliz':
        return 10;
      case 'tranquilo':
      case 'bem':
        return 8;
      case 'aliviado':
      case 'ok':
        return 6;
      case 'pensativo':
        return 5;
      case 'preocupado':
        return 4;
      case 'triste':
        return 3;
      case 'bravo':
        return 2;
      case 'infeliz':
      case 'muito triste':
        return 1;
      default:
        return 5;
    }
  }

  String _getEmoticonFromScore(double score) {
    if (score >= 9) return '😎'; // Feliz
    if (score >= 7) return '🙂'; // Bem
    if (score >= 5.5) return '😐'; // OK
    if (score >= 4.5) return '🤔'; // Pensativo
    if (score >= 3.5) return '😟'; // Preocupado
    if (score >= 2.5) return '😢'; // Triste
    if (score >= 1.5) return '😠'; // Bravo
    return '😭'; // Infeliz
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dates.isEmpty) return;

    // Margem à esquerda para os emoticons
    const leftMargin = 30.0;
    final chartWidth = size.width - leftMargin;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.6 * 255),
          primaryColor.withValues(alpha: 0.3 * 255),
          primaryColor.withValues(alpha: 0.1 * 255),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, 0, chartWidth, size.height));

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final linePath = Path();

    final stepX = chartWidth / (dates.length - 1);

    for (int i = 0; i < dates.length; i++) {
      final emoticons = historiasPerDay[dates[i]] ?? [];
      final avgScore = emoticons.isEmpty
          ? 5.0
          : emoticons.map(_getEmoticonScore).reduce((a, b) => a + b) /
                emoticons.length;

      final x = leftMargin + (i * stepX);
      final y = size.height - (avgScore / 10 * size.height);

      if (i == 0) {
        path.moveTo(x, size.height);
        path.lineTo(x, y);
        linePath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        linePath.lineTo(x, y);
      }
    }

    path.lineTo(leftMargin + chartWidth, size.height);
    path.lineTo(leftMargin, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);

    // Desenhar emoticons no eixo Y
    final emoticonScores = [10.0, 8.0, 6.0, 4.0, 2.0];
    for (var score in emoticonScores) {
      final y = size.height - (score / 10 * size.height);
      final emoticon = _getEmoticonFromScore(score);

      final textSpan = TextSpan(
        text: emoticon,
        style: const TextStyle(fontSize: 16),
      );
      final textPainter =
          TextPainter(text: textSpan, textAlign: TextAlign.center)
            ..textDirection = ui.TextDirection.ltr
            ..layout();

      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Desenhar datas (apenas algumas)
    final indicesToShow = [0, dates.length ~/ 2, dates.length - 1];
    for (var i in indicesToShow) {
      if (i >= 0 && i < dates.length) {
        final x = leftMargin + (i * stepX);
        final textSpan = TextSpan(
          text: DateFormat('dd.MMM', 'pt_BR').format(dates[i]),
          style: TextStyle(
            color: isDark
                ? AppColors.neutralGrey.withValues(alpha: 0.4)
                : AppColors.neutralGrey.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        );
        final textPainter =
            TextPainter(text: textSpan, textAlign: TextAlign.center)
              ..textDirection = ui.TextDirection.ltr
              ..layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineSparklinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data; // {'day': 'YYYY-MM-DD', 'count': N}
  final Color lineColor;

  LineSparklinePainter({
    required this.data,
    this.lineColor = const Color(0xFF6C63FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final counts = data.map((e) => (e['count'] as num).toDouble()).toList();
    final maxV = counts.reduce((a, b) => a > b ? a : b);
    final minV = counts.reduce((a, b) => a < b ? a : b);

    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    final path = Path();
    final bool singlePoint = counts.length == 1;
    final stepX = singlePoint ? 0.0 : size.width / (counts.length - 1);

    for (var i = 0; i < counts.length; i++) {
      final x = singlePoint ? size.width / 2 : i * stepX;
      final y = size.height - ((counts[i] - minV) / span) * size.height;
      // Proteção contra valores não finitos
      final safeX = x.isFinite ? x : 0.0;
      final safeY = y.isFinite ? y : size.height / 2;

      if (i == 0) {
        path.moveTo(safeX, safeY);
      } else {
        path.lineTo(safeX, safeY);
      }
    }

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < counts.length; i++) {
      final x = singlePoint ? size.width / 2 : i * stepX;
      final y = size.height - ((counts[i] - minV) / span) * size.height;
      final safeX = x.isFinite ? x : 0.0;
      final safeY = y.isFinite ? y : size.height / 2;
      canvas.drawCircle(Offset(safeX, safeY), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
