// ignore_for_file: unused_local_variable

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;

    // Buscar todas as histórias não excluídas
    final result = await db.query(
      'historia',
      where: 'user_id = ? AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
    );

    _historias = result.map((map) => Historia.fromMap(map)).toList();

    // Calcular estatísticas
    _calculateEmoticonStatistics();
    _calculateStreaks();

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
        return const Color(0xFF81D4FA); // Azul claro
      case 'bem':
        return const Color(0xFF80CBC4); // Verde água
      case 'ok':
        return const Color(0xFFB39DDB); // Roxo claro
      case 'triste':
        return const Color(0xFFFFCC80); // Laranja
      case 'infeliz':
        return const Color(0xFFF48FB1); // Rosa
      case 'preocupado':
        return const Color(0xFFA5D6A7); // Verde
      case 'bravo':
        return const Color(0xFFFFAB91); // Vermelho claro
      case 'assustado':
        return const Color(0xFFFFE082); // Amarelo
      case 'pensativo':
        return const Color(0xFFCE93D8); // Roxo
      case 'sono':
        return const Color(0xFF90CAF9); // Azul
      default:
        return Colors.grey;
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

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas'), elevation: 0),
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
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma história registrada ainda',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comece a registrar seus dias para ver as estatísticas',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                    _buildTendenciasCard(isDark),
                    const SizedBox(height: 16),
                    _buildDiasSeguidosCard(isDark),
                    const SizedBox(height: 16),
                    _buildTabelaHumoresCard(isDark),
                    const SizedBox(height: 16),
                    _buildContagemHumorCard(isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTendenciasCard(bool isDark) {
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
            const Text(
              'Tendências',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildDiasSeguidosCard(bool isDark) {
    final today = DateTime.now();
    final weekDayNames = [
      'sábado',
      'domingo',
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
    ];
    final startIndex =
        (today.weekday + 1) % 7; // Ajustar para começar 6 dias atrás

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
                const Text(
                  'Dias seguidos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final dayIndex = (startIndex + index) % 7;
                    final hasEntry = _weekDays[index];
                    final isToday = index == 6;

                    return Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasEntry ? primaryColor : Colors.grey[300],
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
                                      : const Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                          size: 20,
                                        )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekDayNames[dayIndex].substring(0, 3),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sequência mais longa: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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

  Widget _buildTabelaHumoresCard(bool isDark) {
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
            const Text(
              'Tabela de humores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildContagemHumorCard(bool isDark) {
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
            const Text(
              'Contagem de humor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            color: isDark ? Colors.grey[400] : Colors.grey[600],
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
