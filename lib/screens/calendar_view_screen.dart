import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:typed_data';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../models/historia_foto.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import 'edit_historia_screen.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late final ValueNotifier<List<Historia>> _selectedHistorias;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Historia>> _historiasMap = {};
  bool _isLoading = true;

  String _getEmoticonImage(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '1_feliz.png';
      case 'Tranquilo':
        return '2_tranquilo.png';
      case 'Aliviado':
        return '3_aliviado.png';
      case 'Pensativo':
        return '4_pensativo.png';
      case 'Sono':
        return '5_sono.png';
      case 'Preocupado':
        return '6_preocupado.png';
      case 'Assustado':
        return '7_assustado.png';
      case 'Bravo':
        return '8_bravo.png';
      case 'Triste':
        return '9_triste.png';
      case 'Muito Triste':
        return '10_muito_triste.png';
      default:
        return '1_feliz.png';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedHistorias = ValueNotifier([]);
    _loadHistorias();

    // Adicionar listener para atualizar quando houver mudanças
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.addListener(_onRefresh);
    });
  }

  void _onRefresh() {
    if (mounted) {
      _loadHistorias();
    }
  }

  @override
  void dispose() {
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.removeListener(_onRefresh);
    _selectedHistorias.dispose();
    super.dispose();
  }

  Future<void> _loadHistorias() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      if (userId == null) return;

      final db = await DatabaseHelper().database;
      final result = await db.query(
        'historia',
        where: 'user_id = ? AND arquivado IS NULL',
        whereArgs: [userId],
        orderBy: 'data DESC',
      );

      final historias = result.map((map) => Historia.fromMap(map)).toList();

      // Agrupar histórias por data (ignorando hora)
      final Map<DateTime, List<Historia>> map = {};
      for (var historia in historias) {
        final date = DateTime(
          historia.data.year,
          historia.data.month,
          historia.data.day,
        );
        if (!map.containsKey(date)) {
          map[date] = [];
        }
        map[date]!.add(historia);
      }

      setState(() {
        _historiasMap = map;
        _isLoading = false;
      });

      // Atualizar histórias do dia selecionado
      _updateSelectedHistorias(_selectedDay!);
    } catch (e) {
      debugPrint('Erro ao carregar histórias: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateSelectedHistorias(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    _selectedHistorias.value = _historiasMap[date] ?? [];
  }

  List<Historia> _getHistoriasForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _historiasMap[date] ?? [];
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta história?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = await DatabaseHelper().database;
        await db.delete('historia', where: 'id = ?', whereArgs: [historia.id]);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('História excluída com sucesso')),
        );

        _loadHistorias();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir história: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Calendário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendário
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  child: TableCalendar<Historia>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getHistoriasForDay,
                    locale: 'pt_BR',
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _updateSelectedHistorias(selectedDay);
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),

                // Divisor
                const Divider(height: 1),

                // Lista de histórias do dia selecionado
                Expanded(
                  child: ValueListenableBuilder<List<Historia>>(
                    valueListenable: _selectedHistorias,
                    builder: (context, historias, _) {
                      if (historias.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum registro neste dia',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: historias.length,
                        itemBuilder: (context, index) {
                          final historia = historias[index];
                          return _buildHistoriaCard(historia);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHistoriaCard(Historia historia) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          _showHistoriaDetails(historia);
        },
        onDoubleTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditHistoriaScreen(historia: historia),
            ),
          );
          if (result == true) {
            _loadHistorias();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (historia.emoticon != null)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        'assets/image/${_getEmoticonImage(historia.emoticon!)}',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.sentiment_satisfied_alt,
                            size: 40,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historia.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format(historia.data),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditHistoriaScreen(historia: historia),
                          ),
                        );
                        if (result == true) {
                          _loadHistorias();
                        }
                      } else if (value == 'delete') {
                        await _deleteHistoria(historia);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ],
              ),
              if (historia.descricao != null &&
                  historia.descricao!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  historia.descricao!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
              // Preview de fotos
              FutureBuilder<List<HistoriaFoto>>(
                future: HistoriaFotoHelper().getFotosByHistoria(
                  historia.id ?? 0,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final fotos = snapshot.data!.take(3).toList();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: fotos.map((foto) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: MemoryImage(Uint8List.fromList(foto.foto)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoriaDetails(Historia historia) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle do modal
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Conteúdo
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: _buildDetailedHistoriaView(historia),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedHistoriaView(Historia historia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com emoticon e título
        Row(
          children: [
            if (historia.emoticon != null)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  'assets/image/${_getEmoticonImage(historia.emoticon!)}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 60,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historia.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                      'pt_BR',
                    ).format(historia.data),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Descrição
        if (historia.descricao != null && historia.descricao!.isNotEmpty) ...[
          const Text(
            'Descrição:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(historia.descricao!, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 16),
        ],

        // Fotos
        FutureBuilder<List<HistoriaFoto>>(
          future: HistoriaFotoHelper().getFotosByHistoria(historia.id ?? 0),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final fotos = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fotos:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: fotos.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        Uint8List.fromList(fotos[index].foto),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
