import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';

/// Provider que expõe métodos para obter estatísticas da base de dados.
/// Comentários em português; nomes de métodos/variáveis em inglês.
class StatisticsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- Overview básico ---
  Future<Map<String, dynamic>> fetchOverview({String? userId}) async {
    final db = await _dbHelper.database;
    final totalStoriesRes = await db.rawQuery(
      userId != null
          ? 'SELECT COUNT(*) as cnt FROM historia WHERE user_id = ?'
          : 'SELECT COUNT(*) as cnt FROM historia',
      userId != null ? [userId] : null,
    );
    final totalStories = (totalStoriesRes.isNotEmpty)
        ? totalStoriesRes.first['cnt'] as int
        : 0;

    final activeDaysRes = await db.rawQuery(
      userId != null
          ? 'SELECT COUNT(DISTINCT date(data)) as days FROM historia WHERE user_id = ?'
          : 'SELECT COUNT(DISTINCT date(data)) as days FROM historia',
      userId != null ? [userId] : null,
    );
    final activeDays = (activeDaysRes.isNotEmpty)
        ? activeDaysRes.first['days'] as int
        : 0;

    // Média por dia considerando dias ativos
    final avgPerActiveDay = activeDays > 0 ? totalStories / activeDays : 0.0;

    // Totais de mídias
    final photosRes = await db.rawQuery(
      userId != null
          ? 'SELECT COUNT(hf.id) as cnt FROM historia_fotos hf JOIN historia h ON hf.historia_id = h.id WHERE h.user_id = ?'
          : 'SELECT COUNT(*) as cnt FROM historia_fotos',
      userId != null ? [userId] : null,
    );
    final photos = (photosRes.isNotEmpty) ? photosRes.first['cnt'] as int : 0;

    final audiosRes = await db.rawQuery(
      userId != null
          ? 'SELECT COUNT(ha.id) as cnt FROM historia_audios ha JOIN historia h ON ha.historia_id = h.id WHERE h.user_id = ?'
          : 'SELECT COUNT(*) as cnt FROM historia_audios',
      userId != null ? [userId] : null,
    );
    final audios = (audiosRes.isNotEmpty) ? audiosRes.first['cnt'] as int : 0;

    final videosRes = await db.rawQuery(
      userId != null
          ? 'SELECT COUNT(hv.id) as cnt FROM historia_videos hv JOIN historia h ON hv.historia_id = h.id WHERE h.user_id = ?'
          : 'SELECT COUNT(*) as cnt FROM historia_videos',
      userId != null ? [userId] : null,
    );
    final videos = (videosRes.isNotEmpty) ? videosRes.first['cnt'] as int : 0;

    return {
      'totalStories': totalStories,
      'activeDays': activeDays,
      'avgPerActiveDay': avgPerActiveDay,
      'photos': photos,
      'audios': audios,
      'videos': videos,
      'totalMedia': photos + audios + videos,
    };
  }

  // --- Streaks (dias consecutivos com pelo menos uma história) ---
  Future<Map<String, int>> fetchStreaks({String? userId}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      userId != null
          ? 'SELECT DISTINCT date(data) as d FROM historia WHERE user_id = ? ORDER BY d DESC'
          : 'SELECT DISTINCT date(data) as d FROM historia ORDER BY d DESC',
      userId != null ? [userId] : null,
    );

    final dates = rows.map((r) => DateTime.parse(r['d'] as String)).toList();

    int currentStreak = 0;
    int bestStreak = 0;

    DateTime? prev;
    for (final d in dates) {
      if (prev == null) {
        currentStreak = 1;
      } else {
        final diff = prev.difference(d).inDays;
        if (diff == 1) {
          currentStreak += 1;
        } else if (diff == 0) {
          // mesma data duplicada (já tratado por DISTINCT), ignora
        } else {
          if (currentStreak > bestStreak) bestStreak = currentStreak;
          currentStreak = 1;
        }
      }
      prev = d;
    }

    if (currentStreak > bestStreak) bestStreak = currentStreak;

    // Determinar se o último dia é hoje para considerar 'streak atual'
    final today = DateTime.now();
    final hasToday =
        dates.isNotEmpty &&
        dates.first.year == today.year &&
        dates.first.month == today.month &&
        dates.first.day == today.day;

    final streakCurrent = hasToday ? currentStreak : 0;

    return {'currentStreak': streakCurrent, 'bestStreak': bestStreak};
  }

  // --- Top tags ---
  Future<List<Map<String, dynamic>>> fetchTopTags({
    int limit = 10,
    String? userId,
  }) async {
    final db = await _dbHelper.database;
    if (userId != null) {
      final rows = await db.rawQuery(
        'SELECT tag, COUNT(*) as cnt FROM historia WHERE user_id = ? AND tag IS NOT NULL AND tag <> "" GROUP BY tag ORDER BY cnt DESC LIMIT ?',
        [userId, limit],
      );
      return rows;
    }

    final rows = await db.rawQuery(
      'SELECT tag, COUNT(*) as cnt FROM historia WHERE tag IS NOT NULL AND tag <> "" GROUP BY tag ORDER BY cnt DESC LIMIT ?',
      [limit],
    );
    return rows;
  }

  // --- Sentimentos / emoticons breakdown ---
  Future<List<Map<String, dynamic>>> fetchEmotionBreakdown({
    String? userId,
  }) async {
    final db = await _dbHelper.database;
    final sql = userId != null
        ? 'SELECT sentimento as key, COUNT(*) as cnt FROM historia WHERE user_id = ? AND sentimento IS NOT NULL GROUP BY sentimento ORDER BY cnt DESC'
        : 'SELECT sentimento as key, COUNT(*) as cnt FROM historia WHERE sentimento IS NOT NULL GROUP BY sentimento ORDER BY cnt DESC';
    final rows = await db.rawQuery(sql, userId != null ? [userId] : null);
    return rows;
  }

  // --- Heatmap dia x hora ---
  Future<List<Map<String, dynamic>>> fetchHeatmap({String? userId}) async {
    final db = await _dbHelper.database;
    String sql =
        '''
      SELECT strftime('%w', data) as weekday, strftime('%H', data) as hour, COUNT(*) as cnt
      FROM historia
    '''
            .trim();

    List<Object?>? args;
    if (userId != null) {
      sql += ' WHERE user_id = ?';
      args = [userId];
    }

    sql += ' GROUP BY weekday, hour ORDER BY weekday, hour';

    final rows = await db.rawQuery(sql, args);
    return rows
        .map(
          (r) => {
            'weekday': r['weekday'] is int
                ? r['weekday'] as int
                : int.parse(r['weekday'] as String),
            'hour': r['hour'] is int
                ? r['hour'] as int
                : int.parse(r['hour'] as String),
            'count': r['cnt'] is int
                ? r['cnt'] as int
                : (r['cnt'] as num).toInt(),
          },
        )
        .toList();
  }

  // --- Série temporal de histórias por dia (últimos N dias) ---
  Future<List<Map<String, dynamic>>> fetchTimeSeries({
    int days = 30,
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    String sql =
        "SELECT date(data) as day, COUNT(*) as cnt FROM historia WHERE date(data) >= date('now', '-${days - 1} days')";
    List<Object?>? args;
    if (userId != null) {
      sql += ' AND user_id = ?';
      args = [userId];
    }
    sql += ' GROUP BY day ORDER BY day';

    final rows = await db.rawQuery(sql, args);

    return rows
        .map(
          (r) => {
            'day': r['day'],
            'count': r['cnt'] is int
                ? r['cnt'] as int
                : (r['cnt'] as num).toInt(),
          },
        )
        .toList();
  }
}
