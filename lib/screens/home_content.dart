import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/tag_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/historia.dart';
import '../models/insight.dart';
import '../models/tag.dart';
import '../providers/auth_provider.dart';
import '../providers/insight_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../providers/scroll_position_provider.dart';
import '../services/pdf_export_service.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/compact_historia_card.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/insight_card.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';
import 'pdf_preview_screen.dart';
import 'search_screen.dart';

class HomeContent extends StatefulWidget {
  final bool isCardView;
  final bool showChapterShortcutCard;
  const HomeContent({
    required this.isCardView,
    required this.showChapterShortcutCard,
    super.key,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Constantes e estado do componente home
  static const double cardMargin = 24.0;
  static const int _pageSize = 15; // Número de histórias por página

  bool _isCardView = true;

  // Controle de paginação
  final ScrollController _scrollController = ScrollController();
  final List<Historia> _historias = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  Future<void> _exportHistoria(Historia historia) async {
    try {
      // Salva referências do contexto antes das operações assíncronas
      final navigator = Navigator.of(context);
      final localizations = AppLocalizations.of(context)!;
      final localeName = localizations.localeName;

      final fotosData = await HistoriaFotoHelper().getFotosComBytesByHistoria(
        historia.id ?? 0,
      );
      final images = fotosData.map((f) => f.bytes).toList();
      final content = RichTextHelper.jsonToPlainText(historia.descricao);
      final pdfBytes = await PdfExportService.generatePdfFromHistoria(
        title: historia.titulo,
        content: content,
        date: historia.data,
        images: images,
        tags: historia.tag,
        emoticon: historia.emoticon,
        locale: localeName,
      );
      final filename =
          'historia_${historia.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            initialPdfBytes: pdfBytes,
            onGenerate: (highQuality) =>
                PdfExportService.generatePdfFromHistoria(
                  title: historia.titulo,
                  content: content,
                  date: historia.data,
                  images: images,
                  tags: historia.tag,
                  emoticon: historia.emoticon,
                  highQuality: highQuality,
                  locale: localeName,
                ),
            filename: filename,
            title: localizations.previewTitle(historia.titulo),
            onSave: null,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final localizations = AppLocalizations.of(context)!;
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.exportPdfError(e.toString()))),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detecta scroll perto do final para carregar mais dados
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// Carrega os dados iniciais (primeira página)
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _historias.clear();
      _hasMoreData = true;
    });

    await _fetchHistoriasPaginated(offset: 0);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  /// Carrega mais dados (próxima página)
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchHistoriasPaginated(offset: _historias.length);

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Busca histórias com paginação
  Future<void> _fetchHistoriasPaginated({required int offset}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;

    final result = await db.query(
      'historia',
      where:
          'user_id = ? AND grupo IS NULL AND arquivado IS NULL AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
      limit: _pageSize,
      offset: offset,
    );

    final newHistorias = result.map((map) => Historia.fromMap(map)).toList();

    if (mounted) {
      setState(() {
        // Evita duplicatas verificando IDs existentes
        final existingIds = _historias.map((h) => h.id).toSet();
        final filteredHistorias = newHistorias
            .where((h) => !existingIds.contains(h.id))
            .toList();
        _historias.addAll(filteredHistorias);
        _hasMoreData = newHistorias.length == _pageSize;
      });
    }
  }

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna null se já for um emoji (default case)
  String? _convertLegacyEmoticon(String emoticon) {
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
        return null; // Já é um emoji Unicode
    }
  }

  Future<void> _updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    final db = await DatabaseHelper().database;
    final Map<String, dynamic> updateData = {
      'data_update': DateTime.now().toIso8601String(),
    };

    if (updates != null) updateData.addAll(updates);

    // Se a atualização não explicitar o estado de backup, marcar como não salvo
    // para que a história seja incluída no próximo backup.
    if (!updateData.containsKey('backed_up')) {
      updateData['backed_up'] = 0;
    }

    await db.update(
      'historia',
      updateData,
      where: 'id = ?',
      whereArgs: [historia.id],
    );
    if (!mounted) return;
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.refresh();
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteStoryTitle),
        content: Text(AppLocalizations.of(context)!.deleteStoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context)!.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      // Soft delete: marca como excluído ao invés de deletar
      await db.update(
        'historia',
        {
          'excluido': 'sim',
          'data_exclusao': DateTime.now().toIso8601String(),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.movedToTrash)),
      );
    }
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;

    // Atualiza o BD diretamente, sem disparar o refresh ainda,
    // para que o Consumer<RefreshProvider> não reconstrua antes do snackbar.
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'arquivado': 'sim',
        'grupo': null,
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
      },
      where: 'id = ?',
      whereArgs: [historia.id],
    );

    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Text(localizations.storyArchived),
        action: SnackBarAction(
          label: localizations.undo,
          onPressed: () async {
            await _updateHistoria(
              historia,
              updates: {'arquivado': null, 'grupo': previousGrupo},
            );
          },
        ),
      ),
    );
    // Backup: fecha o snackbar após 5 s sem depender de mounted
    Future.delayed(const Duration(seconds: 5), controller.close);

    // Dispara o refresh no próximo frame, após o snackbar já estar na fila.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<RefreshProvider>(context, listen: false).refresh();
    });
  }

  Widget _buildCardView(Historia historia) {
    return FutureBuilder<List<FotoComBytes>>(
      future: HistoriaFotoHelper().getFotosComBytesByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final hasImages = snapshot.hasData && snapshot.data!.isNotEmpty;

        return Slidable(
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  await _archiveWithUndo(historia);
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: Icons.archive,
                label: AppLocalizations.of(context)!.archiveLabel,
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final navigator = Navigator.of(context);
                  final selectedGroup = await navigator.push<String>(
                    MaterialPageRoute(
                      builder: (_) => const GroupSelectionScreen(),
                    ),
                  );
                  if (selectedGroup != null) {
                    await _updateHistoria(
                      historia,
                      updates: {'grupo': selectedGroup},
                    );
                  }
                },
                backgroundColor: AppColors.emoticonGreen,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: Icons.group,
                label: AppLocalizations.of(context)!.group,
              ),
            ],
          ),
          child: GestureDetector(
            onDoubleTap: () {
              final navigator = Navigator.of(context);
              final refreshProvider = Provider.of<RefreshProvider>(
                context,
                listen: false,
              );
              navigator
                  .push(
                    MaterialPageRoute(
                      builder: (_) => EditHistoriaScreen(historia: historia),
                    ),
                  )
                  .then((updated) {
                    if (!mounted) return;
                    if (updated == true) {
                      refreshProvider.refresh();
                    }
                  });
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: cardMargin),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImages) ...[
                      HistoriaFotosGrid(
                        historiaId: historia.id ?? 0,
                        height: 100,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Linha combinada: Emoticon + Áudios + Vídeos
                    HistoriaMediaRow(
                      historiaId: historia.id ?? 0,
                      emoticon: historia.emoticon,
                      convertLegacyEmoticon: _convertLegacyEmoticon,
                    ),
                    Text(
                      historia.titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: RichTextViewerWidget(
                        jsonContent: historia.descricao,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Data
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (historia.emoticon != null &&
                                  historia.emoticon!.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    final convertedEmoji =
                                        _convertLegacyEmoticon(
                                          historia.emoticon!,
                                        );
                                    final displayEmoji =
                                        convertedEmoji ?? historia.emoticon!;
                                    return Text(
                                      displayEmoji,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1,
                                      ),
                                    );
                                  },
                                ),
                              if (historia.emoticon != null &&
                                  historia.emoticon!.isNotEmpty)
                                const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                    'pt_BR',
                                  ).format(historia.data),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final navigator = Navigator.of(context);
                              final refreshProvider =
                                  Provider.of<RefreshProvider>(
                                    context,
                                    listen: false,
                                  );
                              navigator
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => EditHistoriaScreen(
                                        historia: historia,
                                      ),
                                    ),
                                  )
                                  .then((updated) {
                                    if (!mounted) return;
                                    if (updated == true) {
                                      refreshProvider.refresh();
                                    }
                                  });
                            } else if (value == 'delete') {
                              await _deleteHistoria(historia);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                AppLocalizations.of(context)!.editTip,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                AppLocalizations.of(context)!.deleteLabel,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tags da história (novo sistema + legado)
                    FutureBuilder<List<Tag>>(
                      future: TagHelper().getTagsByHistoria(historia.id ?? 0),
                      builder: (context, tagSnapshot) {
                        final newTags = tagSnapshot.data ?? [];
                        final legacyTag = historia.tag;
                        final tagNames = newTags.isNotEmpty
                            ? newTags.map((t) => t.nome).toList()
                            : (legacyTag != null && legacyTag.isNotEmpty
                                  ? [legacyTag]
                                  : <String>[]);
                        if (tagNames.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: tagNames
                                  .map(
                                    (name) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconView(Historia historia) {
    return Dismissible(
      key: Key('icon_${historia.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          AppLocalizations.of(context)!.archiveLabel,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.emoticonGreen,
        child: Text(
          AppLocalizations.of(context)!.group,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _archiveWithUndo(historia);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          final selectedGroup = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
          );
          if (selectedGroup != null) {
            await _updateHistoria(historia, updates: {'grupo': selectedGroup});
          }
        }
        return false;
      },
      onDismissed: (direction) {
        // Já tratado no confirmDismiss
      },
      child: CompactHistoriaCard(
        historia: historia,
        localeName: AppLocalizations.of(context)!.localeName,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            color: Theme.of(context).iconTheme.color,
          ),
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHistoriaScreen(historia: historia),
                ),
              ).then((updated) {
                if (!mounted) return;
                if (updated == true) {
                  final refreshProvider = Provider.of<RefreshProvider>(
                    context,
                    listen: false,
                  );
                  refreshProvider.refresh();
                }
              });
            } else if (value == 'delete') {
              await _deleteHistoria(historia);
            } else if (value == 'export') {
              await _exportHistoria(historia);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(AppLocalizations.of(context)!.edit),
            ),
            PopupMenuItem(
              value: 'export',
              child: Text(AppLocalizations.of(context)!.exportPdf),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(AppLocalizations.of(context)!.deleteLabel),
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(child: _buildCardView(historia)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isCardView = widget.isCardView;
    return Consumer<RefreshProvider>(
      builder: (context, refreshProvider, child) {
        // Recarrega dados quando o RefreshProvider é atualizado
        // Usa o refreshCounter como chave para detectar mudanças
        return _PaginatedHomeContent(
          key: ValueKey(refreshProvider.refreshCounter),
          isCardView: _isCardView,
          showChapterShortcutCard: widget.showChapterShortcutCard,
          historias: _historias,
          isInitialLoading: _isInitialLoading,
          isLoadingMore: _isLoadingMore,
          hasMoreData: _hasMoreData,
          scrollController: _scrollController,
          onRefresh: _loadInitialData,
          buildCardView: _buildCardView,
          buildIconView: _buildIconView,
        );
      },
    );
  }
}

/// Widget interno para conteúdo paginado
class _PaginatedHomeContent extends StatefulWidget {
  final bool isCardView;
  final bool showChapterShortcutCard;
  final List<Historia> historias;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Widget Function(Historia) buildCardView;
  final Widget Function(Historia) buildIconView;

  const _PaginatedHomeContent({
    required this.isCardView,
    required this.showChapterShortcutCard,
    required this.historias,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.scrollController,
    required this.onRefresh,
    required this.buildCardView,
    required this.buildIconView,
    super.key,
  });

  @override
  State<_PaginatedHomeContent> createState() => _PaginatedHomeContentState();
}

class _PaginatedHomeContentState extends State<_PaginatedHomeContent> {
  bool _hasRefreshed = false;
  // Chave para identificar a posição do scroll desta tela
  static const String _scrollPositionKey = 'home_list_scroll';

  @override
  void initState() {
    super.initState();
    // Recarrega dados quando a key muda (RefreshProvider foi atualizado)
    // Usa addPostFrameCallback para evitar setState durante build
    // Só executa uma vez por instância do widget
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasRefreshed) {
        _hasRefreshed = true;
        await widget.onRefresh();
        // Carrega insights ao abrir a Home
        if (!mounted) return;
        final userId =
            Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
        if (userId.isNotEmpty) {
          // Usa refresh (força recálculo) para garantir dados atualizados
          // após qualquer mutação de histórias
          Provider.of<InsightProvider>(context, listen: false).refresh(userId);
        }
        // Restaura posição do scroll após dados serem carregados
        if (!mounted) return;
        _restoreScrollPositionAfterLoad();
      }
    });
  }

  /// Restaura a posição do scroll após os dados serem carregados
  /// Aguarda um frame para garantir que o ListView tem clientes
  void _restoreScrollPositionAfterLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scrollProvider = Provider.of<ScrollPositionProvider>(
        context,
        listen: false,
      );
      final savedPosition = scrollProvider.getScrollPosition(
        _scrollPositionKey,
      );
      if (widget.scrollController.hasClients && savedPosition > 0) {
        widget.scrollController.jumpTo(savedPosition);
      }
    });
  }

  /// Salva a posição do scroll antes de sair da tela
  void _saveScrollPosition() {
    if (widget.scrollController.hasClients) {
      final scrollProvider = Provider.of<ScrollPositionProvider>(
        context,
        listen: false,
      );
      scrollProvider.saveScrollPosition(
        _scrollPositionKey,
        widget.scrollController.offset,
      );
    }
  }

  @override
  void deactivate() {
    // Salva a posição quando o widget é removido da widget tree
    _saveScrollPosition();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // Mostra loading inicial
    if (widget.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lista com paginação
    return AnimatedSwitcher(
      duration: AppDurations.listSwitch,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: Consumer<InsightProvider>(
          builder: (context, insightProvider, _) {
            final insights = insightProvider.insights;
            final storiesCount = widget.historias.length;
            final extraChapterCard = widget.showChapterShortcutCard ? 1 : 0;

            Widget chapterShortcutCard() {
              final l10n = AppLocalizations.of(context)!;
              final premium = context.watch<PremiumProvider>();
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    premium.canUseChapters
                        ? Icons.auto_stories_rounded
                        : Icons.workspace_premium,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.chaptersHomeCardTitle),
                  subtitle: Text(
                    premium.canUseChapters
                        ? l10n.chaptersHomeCardSubtitle
                        : l10n.chaptersPremiumRequired,
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => Navigator.pushNamed(context, '/chapters'),
                    child: Text(l10n.chapterOpenLabel),
                  ),
                ),
              );
            }

            // userId necessário para o callback de dispensa
            final userId =
                Provider.of<AuthProvider>(context, listen: false).user?.id ??
                '';
            final devMode = insightProvider.devMode;
            final hasDevBanner = devMode && insights.isNotEmpty;
            final extraDevBanner = hasDevBanner ? 1 : 0;
            final headerCount =
                extraChapterCard + extraDevBanner + insights.length;

            Widget devModeBanner() {
              final colorScheme = Theme.of(context).colorScheme;
              final l10n = AppLocalizations.of(context)!;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.tertiary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.developer_mode,
                      size: 14,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.insightDevModeActive,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            /// Constrói um InsightCard com todos os callbacks configurados.
            Widget buildInsightCard(Insight insight) {
              return InsightCard(
                insight: insight,
                onDismiss: () =>
                    insightProvider.dismissInsight(userId, insight.type),
                onPremiumCTA: () =>
                    Navigator.of(context).pushNamed('/settings'),
                onSeeStories: (query) {
                  final searchType = insight.type == InsightType.positiveTag
                      ? SearchType.tag
                      : SearchType.text;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(
                        initialQuery: query,
                        initialSearchType: searchType,
                      ),
                    ),
                  );
                },
              );
            }

            // Estado verdadeiramente vazio: sem histórias e sem insights.
            if (storiesCount == 0 && insights.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (widget.showChapterShortcutCard) chapterShortcutCard(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image/home_vazia.png',
                            width: 250,
                            height: 250,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noStoriesHere,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.storiesGroupedOrArchived,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Lista unificada: capítulo + insights (topo) + histórias (corpo).
            final totalBodyItems = storiesCount == 0
                ? 1 // placeholder de lista vazia
                : storiesCount + (widget.hasMoreData ? 1 : 0);
            final totalItems = headerCount + totalBodyItems;

            return ListView.builder(
              key: ValueKey<bool>(widget.isCardView),
              controller: storiesCount > 0 ? widget.scrollController : null,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                // Card de capítulos
                if (widget.showChapterShortcutCard && index == 0) {
                  return chapterShortcutCard();
                }

                // Banner de modo desenvolvimento
                if (hasDevBanner && index == extraChapterCard) {
                  return devModeBanner();
                }

                // Cards de insights no topo (abaixo do card de capítulos)
                if (index < headerCount) {
                  final insightIndex =
                      index - extraChapterCard - extraDevBanner;
                  return buildInsightCard(insights[insightIndex]);
                }

                // Índice no corpo (histórias / mensagem vazia)
                final bodyIndex = index - headerCount;

                // Mensagem de lista vazia quando há insights mas não há histórias
                if (storiesCount == 0) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image/home_vazia.png',
                            width: 180,
                            height: 180,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.noStoriesHere,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Histórias
                if (bodyIndex < storiesCount) {
                  final historia = widget.historias[bodyIndex];
                  return widget.isCardView
                      ? widget.buildCardView(historia)
                      : widget.buildIconView(historia);
                }

                // Indicador de carregamento de mais dados
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: widget.isLoadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
