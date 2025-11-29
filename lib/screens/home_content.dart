import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia.dart';
import '../models/historia_video_v2.dart' as v2;
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/thumbnail_service.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';

class HomeContent extends StatefulWidget {
  final bool isCardView;
  const HomeContent({required this.isCardView, super.key});

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
        _historias.addAll(newHistorias);
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
        title: const Text('Excluir história'),
        content: const Text('Deseja mover esta história para a lixeira?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text('História movida para a lixeira')),
      );
    }
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;
    await _updateHistoria(
      historia,
      updates: {'arquivado': 'sim', 'grupo': null},
    );
    if (!mounted) return;
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.refresh();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('História arquivada'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            await _updateHistoria(
              historia,
              updates: {'arquivado': null, 'grupo': previousGrupo},
            );
          },
        ),
      ),
    );
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.archive,
                label: 'Arquivar',
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.group,
                label: 'Grupo',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                            'pt_BR',
                          ).format(historia.data),
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
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
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ],
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
        color: Colors.blue,
        child: const Text(
          'Arquivar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.green,
        child: const Text(
          'Grupo',
          style: TextStyle(
            color: Colors.white,
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
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image,
              color: Theme.of(context).iconTheme.color,
              size: 24,
            ),
          ),
          title: Text(
            historia.titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy', 'pt_BR').format(historia.data),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
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
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: SingleChildScrollView(
                      child: _buildCardView(historia),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                );
              },
            );
          },
        ),
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
  @override
  void initState() {
    super.initState();
    // Recarrega dados quando a key muda (RefreshProvider foi atualizado)
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    // Mostra loading inicial
    if (widget.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostra mensagem se não houver histórias
    if (widget.historias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/home_vazia.png', width: 100, height: 100),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma história para exibir aqui.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elas estão agrupadas ou arquivadas.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Lista com paginação
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
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
        child: ListView.builder(
          key: ValueKey<bool>(widget.isCardView),
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          // +1 para o indicador de carregamento no final
          itemCount: widget.historias.length + (widget.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            // Indicador de carregamento no final da lista
            if (index == widget.historias.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: widget.isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }

            final historia = widget.historias[index];
            return widget.isCardView
                ? widget.buildCardView(historia)
                : widget.buildIconView(historia);
          },
        ),
      ),
    );
  }
}

class HistoriaFotosGrid extends StatelessWidget {
  final int historiaId;
  final double height;
  const HistoriaFotosGrid({
    required this.historiaId,
    super.key,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FotoComBytes>>(
      future: HistoriaFotoHelper().getFotosComBytesByHistoria(historiaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image, color: Colors.grey, size: 48),
            ),
          );
        }

        final fotos = snapshot.data!;
        if (fotos.length == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () {
                // Abre visualizador com imagem em tamanho original
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Image.memory(fotos[0].bytes),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fechar'),
                        ),
                      ],
                    );
                  },
                );
              },
              // Usa thumbnail para preview na lista
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: _ThumbnailImage(
                  imageBytes: fotos[0].bytes,
                  identifier: 'foto_${fotos[0].id}',
                ),
              ),
            ),
          );
        }

        // Build a responsive collage for 2..4+ photos.
        final displayFotos = fotos;
        final total = displayFotos.length;

        void openViewer(int initialIndex) {
          final parentContext = context;
          final images = displayFotos.map((f) => f.bytes).toList();
          final ids = displayFotos.map((f) => f.id).toList();

          // Simpler dialog-based viewer (balanced parentheses)
          final localImages = List<Uint8List>.from(images);
          final localIds = List<int>.from(ids);

          final refreshProviderForDialog = Provider.of<RefreshProvider>(
            parentContext,
            listen: false,
          );

          showDialog<bool>(
            context: parentContext,
            barrierDismissible: true,
            builder: (ctx) {
              int currentIndex = initialIndex;
              final controller = PageController(initialPage: initialIndex);
              return StatefulBuilder(
                builder: (ctx2, setState) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(8),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(parentContext).size.width * 0.98,
                      height: MediaQuery.of(parentContext).size.height * 0.88,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: PageView.builder(
                              controller: controller,
                              itemCount: localImages.length,
                              onPageChanged: (i) =>
                                  setState(() => currentIndex = i),
                              itemBuilder: (c, i) => InteractiveViewer(
                                panEnabled: true,
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: Center(
                                  child: Image.memory(
                                    localImages[i],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (localImages.length > 1)
                            Positioned(
                              left: 12,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: currentIndex > 0 ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 120),
                                  child: Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    elevation: 8,
                                    child: IconButton(
                                      iconSize: 44,
                                      color: Colors.white,
                                      onPressed: currentIndex > 0
                                          ? () => controller.previousPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOut,
                                            )
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (localImages.length > 1)
                            Positioned(
                              right: 12,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: currentIndex < localImages.length - 1
                                      ? 1.0
                                      : 0.0,
                                  duration: const Duration(milliseconds: 120),
                                  child: Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    elevation: 8,
                                    child: IconButton(
                                      iconSize: 44,
                                      color: Colors.white,
                                      onPressed:
                                          currentIndex < localImages.length - 1
                                          ? () => controller.nextPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOut,
                                            )
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          Positioned(
                            right: 8,
                            top: 8,
                            child: SafeArea(
                              child: Material(
                                color: Colors.black45,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(ctx2).pop(false),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.black54,
                                  shape: const CircleBorder(),
                                  elevation: 6,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(
                                        parentContext,
                                      );
                                      try {
                                        final bytes = localImages[currentIndex];
                                        final tempDir =
                                            await getTemporaryDirectory();
                                        final file = File(
                                          '${tempDir.path}/image_${currentIndex + 1}.png',
                                        );
                                        await file.writeAsBytes(bytes);
                                        // ignore: deprecated_member_use
                                        await Share.shareXFiles([
                                          XFile(file.path),
                                        ]);
                                      } catch (_) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Erro ao compartilhar',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (localIds.isNotEmpty)
                                  Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    elevation: 6,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final id = localIds[currentIndex];
                                        final refreshProviderForDialog =
                                            Provider.of<RefreshProvider>(
                                              parentContext,
                                              listen: false,
                                            );
                                        final messenger = ScaffoldMessenger.of(
                                          parentContext,
                                        );
                                        final navigator = Navigator.of(ctx2);
                                        final confirm = await showDialog<bool>(
                                          context: parentContext,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Excluir foto'),
                                            content: const Text(
                                              'Deseja realmente excluir esta foto?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  parentContext,
                                                  false,
                                                ),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  parentContext,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'Excluir',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final deletedBytes =
                                              localImages[currentIndex];
                                          await HistoriaFotoHelper().deleteFoto(
                                            id,
                                          );
                                          setState(() {
                                            localImages.removeAt(currentIndex);
                                            localIds.removeAt(currentIndex);
                                            if (currentIndex >=
                                                    localImages.length &&
                                                localImages.isNotEmpty) {
                                              currentIndex =
                                                  localImages.length - 1;
                                              controller.jumpToPage(
                                                currentIndex,
                                              );
                                            }
                                          });

                                          messenger.hideCurrentSnackBar();
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Foto excluída',
                                              ),
                                              action: SnackBarAction(
                                                label: 'Desfazer',
                                                onPressed: () async {
                                                  await HistoriaFotoHelper()
                                                      .insertFotoFromBytes(
                                                        historiaId: historiaId,
                                                        fotoBytes: deletedBytes,
                                                      );
                                                  refreshProviderForDialog
                                                      .refresh();
                                                },
                                              ),
                                            ),
                                          );

                                          if (localImages.isEmpty) {
                                            navigator.pop(true);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          Positioned(
                            bottom: 18,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(localImages.length, (i) {
                                final active = i == currentIndex;
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: active ? 10 : 6,
                                  height: active ? 10 : 6,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.white
                                        : Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ).then((deleted) {
            if (deleted == true) {
              refreshProviderForDialog.refresh();
            }
          });
        }

        Widget tileForIndex(int index) {
          final foto = displayFotos[index];
          final isOverlay = index == 3 && total > 4;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.grey[200],
              child: InkWell(
                onTap: () => openViewer(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Semantics(
                      label: 'Foto ${index + 1} de $total',
                      image: true,
                      child: _ThumbnailImage(
                        imageBytes: foto.bytes,
                        identifier: 'foto_${foto.id}',
                      ),
                    ),
                    if (isOverlay)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+${total - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'mais',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        if (total == 2) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(child: tileForIndex(0)),
                const SizedBox(width: 4),
                Expanded(child: tileForIndex(1)),
              ],
            ),
          );
        }

        if (total == 3) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(flex: 2, child: tileForIndex(0)),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(child: tileForIndex(1)),
                      const SizedBox(height: 4),
                      Expanded(child: tileForIndex(2)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // total >= 4
        return SizedBox(
          height: height,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: tileForIndex(0)),
                    const SizedBox(width: 4),
                    Expanded(child: tileForIndex(1)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: tileForIndex(2)),
                    const SizedBox(width: 4),
                    Expanded(child: tileForIndex(3)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget combinado para exibir emoticon, áudios e vídeos em linha horizontal
class HistoriaMediaRow extends StatelessWidget {
  final int historiaId;
  final String? emoticon;
  final String? Function(String) convertLegacyEmoticon;

  const HistoriaMediaRow({
    required this.historiaId,
    required this.convertLegacyEmoticon,
    super.key,
    this.emoticon,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadMediaData(),
      builder: (context, snapshot) {
        // Mostra loading enquanto carrega
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        // Mostra erro se houver
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final audios = data['audios'] as List<AudioComBytes>;
        final videos = data['videos'] as List<v2.HistoriaVideo>;

        // Se não tem emoticon nem mídia, não mostra nada
        if ((emoticon == null || emoticon!.isEmpty) &&
            audios.isEmpty &&
            videos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Emoticon
                if (emoticon != null && emoticon!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Builder(
                      builder: (context) {
                        // Converte emoticons legados para emojis
                        final convertedEmoji = convertLegacyEmoticon(emoticon!);
                        final displayEmoji = convertedEmoji ?? emoticon!;
                        return Center(
                          child: Text(
                            displayEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        );
                      },
                    ),
                  ),
                // Áudios
                ...audios.map((audio) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CompactAudioIcon(
                      audioData: audio.bytes,
                      duration: audio.duracao,
                    ),
                  );
                }),
                // Vídeos
                ...videos.map((video) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CompactVideoIcon(
                      videoPath: video.videoPath, // Caminho do arquivo
                      duration: video.duracao,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadMediaData() async {
    try {
      final audios = await HistoriaAudioHelper().getAudiosComBytesByHistoria(
        historiaId,
      );
      final videos = await HistoriaVideoHelper().getVideosByHistoria(
        historiaId,
      );

      return {'audios': audios, 'videos': videos};
    } catch (e) {
      return {'audios': <AudioComBytes>[], 'videos': <v2.HistoriaVideo>[]};
    }
  }
}

// Widget para exibir áudios de uma história (mantido para compatibilidade)
class HistoriaAudiosSection extends StatelessWidget {
  final int historiaId;

  const HistoriaAudiosSection({required this.historiaId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioComBytes>>(
      future: HistoriaAudioHelper().getAudiosComBytesByHistoria(historiaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final audios = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: audios.map((audio) {
              return CompactAudioIcon(
                audioData: audio.bytes,
                duration: audio.duracao,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// Widget para exibir vídeos de uma história (mantido para compatibilidade)
class HistoriaVideosSection extends StatelessWidget {
  final int historiaId;

  const HistoriaVideosSection({required this.historiaId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<v2.HistoriaVideo>>(
      future: HistoriaVideoHelper().getVideosByHistoria(historiaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final videos = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: videos.map((video) {
              return CompactVideoIcon(
                videoPath: video.videoPath, // Caminho do arquivo
                duration: video.duracao,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Widget para exibir thumbnail de imagem com cache
/// Usa o ThumbnailService para gerar e cachear thumbnails
class _ThumbnailImage extends StatefulWidget {
  final Uint8List imageBytes;
  final String identifier;

  const _ThumbnailImage({required this.imageBytes, required this.identifier});

  @override
  State<_ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<_ThumbnailImage> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final thumbnail = await ThumbnailService().getThumbnailFromBytes(
        widget.imageBytes,
        widget.identifier,
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = thumbnail;
          _isLoading = false;
        });
      }
    } catch (_) {
      // Em caso de erro, usa imagem original
      if (mounted) {
        setState(() {
          _thumbnailBytes = widget.imageBytes;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Image.memory(
      _thumbnailBytes ?? widget.imageBytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
