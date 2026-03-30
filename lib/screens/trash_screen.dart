import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/rich_text_viewer_widget.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final List<Historia> _selectedItems = [];
  bool _isSelectionMode = false;

  Future<List<Historia>> _fetchDeletedHistorias() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';

    // Garante que itens com mais de 30 dias não apareçam mais na lixeira.
    await DatabaseHelper().deleteExpiredTrashStories(userId: userId);

    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where: 'user_id = ? AND excluido = ?',
      whereArgs: [userId, 'sim'],
      orderBy: 'data_exclusao DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList();
  }

  Future<void> _restoreHistoria(Historia historia) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'excluido': null,
        'data_exclusao': null,
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
      },
      where: 'id = ?',
      whereArgs: [historia.id],
    );
    if (!mounted) return;
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.refresh();
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });

    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.successStoryRestored)));
  }

  Future<void> _restoreSelected() async {
    if (_selectedItems.isEmpty) return;

    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.restoreStoriesTitle),
        content: Text(loc.restoreStoriesConfirm(_selectedItems.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.restoreLabel),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      for (final historia in _selectedItems) {
        await db.update(
          'historia',
          {
            'excluido': null,
            'data_exclusao': null,
            'data_update': DateTime.now().toIso8601String(),
            'backed_up': 0,
          },
          where: 'id = ?',
          whereArgs: [historia.id],
        );
      }
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedItems.length} história(s) restaurada(s)'),
        ),
      );
    }
  }

  Future<void> _permanentlyDeleteHistoria(Historia historia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.permanentlyDeleteTitle),
          content: Text(loc.permanentlyDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                loc.permanentlyDeleteLabel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      await db.delete('historia', where: 'id = ?', whereArgs: [historia.id]);
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.successStoryDeletedPermanently)),
      );
    }
  }

  Future<void> _emptyTrash() async {
    final historias = await _fetchDeletedHistorias();
    if (historias.isEmpty) {
      // ignore: use_build_context_synchronously
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(loc.trashAlreadyEmpty)));
      return;
    }

    final confirm = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.emptyTrashTitle),
          content: Text(loc.emptyTrashConfirm(historias.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                loc.emptyTrashLabel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      // ignore: use_build_context_synchronously
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id ?? '';
      await db.delete(
        'historia',
        where: 'user_id = ? AND excluido = ?',
        whereArgs: [userId, 'sim'],
      );
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${historias.length} história(s) excluída(s) permanentemente',
          ),
        ),
      );
    }
  }

  void _toggleSelection(Historia historia) {
    setState(() {
      if (_selectedItems.contains(historia)) {
        _selectedItems.remove(historia);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(historia);
        _isSelectionMode = true;
      }
    });
  }

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna o próprio valor se já for um emoji
  String _convertLegacyEmoticon(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '😊';
      case 'Tranquilo':
        return '😌';
      case 'Aliviado':
        return '😮‍💨';
      case 'Pensativo':
        return '🤔';
      case 'Sono':
        return '😴';
      case 'Preocupado':
        return '😟';
      case 'Assustado':
        return '😨';
      case 'Bravo':
        return '😠';
      case 'Triste':
        return '😢';
      case 'Muito Triste':
        return '😭';
      default:
        return emoticon; // Já é um emoji Unicode
    }
  }

  Widget _buildHistoriaCard(Historia historia) {
    final isSelected = _selectedItems.contains(historia);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1 * 255)
          : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(historia);
          } else {
            _showHistoriaOptions(historia);
          }
        },
        onLongPress: () {
          _toggleSelection(historia);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  if (historia.emoticon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _convertLegacyEmoticon(historia.emoticon!),
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historia.titulo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.labelColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateFormatter.format(historia.data)} às ${timeFormatter.format(historia.data)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (historia.assunto != null) ...[
                const SizedBox(height: 8),
                Text(
                  historia.assunto!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (historia.descricao != null &&
                  historia.descricao!.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: RichTextViewerWidget(jsonContent: historia.descricao),
                ),
              ],
              if (historia.dataExclusao != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Excluído em ${dateFormatter.format(historia.dataExclusao!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.emoticonRed,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              // Mostra fotos com visualizador completo e áudios/vídeos
              HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 100),
              HistoriaMediaRow(
                historiaId: historia.id ?? 0,
                emoticon: historia.emoticon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoriaOptions(Historia historia) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.restore, color: AppColors.emoticonGreen),
              title: Text(
                'Restaurar',
                style: TextStyle(color: AppColors.labelColor(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                _restoreHistoria(historia);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: AppColors.emoticonRed),
              title: Text(
                'Excluir permanentemente',
                style: TextStyle(color: AppColors.labelColor(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                _permanentlyDeleteHistoria(historia);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refreshProvider = Provider.of<RefreshProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedItems.length} selecionado(s)')
            : const Text('Lixeira'),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Restaurar selecionados',
              onPressed: _restoreSelected,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancelar seleção',
              onPressed: () {
                setState(() {
                  _selectedItems.clear();
                  _isSelectionMode = false;
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Esvaziar lixeira',
              onPressed: _emptyTrash,
            ),
          ],
        ],
      ),
      body: FutureBuilder<List<Historia>>(
        key: ValueKey(refreshProvider.refreshCounter),
        future: _fetchDeletedHistorias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar lixeira: ${snapshot.error}'),
            );
          }

          final historias = snapshot.data ?? [];

          if (historias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lixeira vazia',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'As histórias excluídas aparecerão aqui',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: historias.length,
            itemBuilder: (context, index) {
              return _buildHistoriaCard(historias[index]);
            },
          );
        },
      ),
    );
  }
}
