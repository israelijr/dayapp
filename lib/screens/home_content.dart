import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'dart:convert'; // not used
import 'package:share_plus/share_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia.dart';
import '../models/historia_foto.dart';
import '../models/historia_audio.dart';
import '../models/historia_video_v2.dart' as v2;
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/markdown_text.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';

class HomeContent extends StatefulWidget {
  final bool isCardView;
  const HomeContent({super.key, required this.isCardView});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Constants and state used by the home content
  static const double cardMargin = 24.0;
  bool _isCardView = true;

  String? _getEmoticonImage(String emoticon) {
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
        return null;
    }
  }

  Future<List<Historia>> _fetchHistorias() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;
    // Only show stories that are not grouped, not archived, and not deleted
    final result = await db.query(
      'historia',
      where:
          'user_id = ? AND grupo IS NULL AND arquivado IS NULL AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList();
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
    return FutureBuilder<List<HistoriaFoto>>(
      future: HistoriaFotoHelper().getFotosByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final hasImages = snapshot.hasData && snapshot.data!.isNotEmpty;

        return Slidable(
          startActionPane: ActionPane(
            motion: BehindMotion(),
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
            motion: BehindMotion(),
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
                      getEmoticonImage: _getEmoticonImage,
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
                    MarkdownText(
                      text: historia.descricao ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
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
        return FutureBuilder<List<Historia>>(
          future: _fetchHistorias(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar histórias: ${snapshot.error}'),
              );
            }
            final historias = snapshot.data ?? [];
            if (historias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/home_vazia.png',
                      width: 100,
                      height: 100,
                    ),
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
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: ListView.builder(
                key: ValueKey<bool>(_isCardView),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemCount: historias.length,
                itemBuilder: (context, index) {
                  final historia = historias[index];
                  return _isCardView
                      ? _buildCardView(historia)
                      : _buildIconView(historia);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class HistoriaFotosGrid extends StatelessWidget {
  final int historiaId;
  final double height;
  const HistoriaFotosGrid({
    super.key,
    required this.historiaId,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoriaFoto>>(
      future: HistoriaFotoHelper().getFotosByHistoria(historiaId),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Image.memory(Uint8List.fromList(fotos[0].foto)),
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
              child: Image.memory(
                Uint8List.fromList(fotos[0].foto),
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        // Build a responsive collage for 2..4+ photos.
        final displayFotos = fotos;
        final total = displayFotos.length;

        void openViewer(int initialIndex) {
          final parentContext = context;
          final images = displayFotos
              .map((f) => Uint8List.fromList(f.foto))
              .toList();
          final ids = displayFotos.map((f) => f.id ?? -1).toList();

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
                                                      .insertFoto(
                                                        HistoriaFoto(
                                                          historiaId:
                                                              historiaId,
                                                          foto: deletedBytes,
                                                          legenda: null,
                                                        ),
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
                      child: Image.memory(
                        Uint8List.fromList(foto.foto),
                        fit: BoxFit.cover,
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
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'mais',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
  final String? Function(String) getEmoticonImage;

  const HistoriaMediaRow({
    super.key,
    required this.historiaId,
    this.emoticon,
    required this.getEmoticonImage,
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
          debugPrint('Erro ao carregar mídia: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final audios = data['audios'] as List<HistoriaAudio>;
        final videos = data['videos'] as List<v2.HistoriaVideo>;

        debugPrint(
          'HistoriaMediaRow - ID: $historiaId, Emoticon: $emoticon, Audios: ${audios.length}, Videos: ${videos.length}',
        );

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
                        final imagePath = getEmoticonImage(emoticon!);
                        if (imagePath != null) {
                          return Image.asset(
                            'assets/image/$imagePath',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.mood, size: 40);
                            },
                          );
                        } else {
                          return Center(
                            child: Text(
                              emoticon!,
                              style: const TextStyle(fontSize: 32),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                // Áudios
                ...audios.map((audio) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CompactAudioIcon(
                      audioData: audio.audio,
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
      final audios = await HistoriaAudioHelper().getAudiosByHistoria(
        historiaId,
      );
      final videos = await HistoriaVideoHelper().getVideosByHistoria(
        historiaId,
      );
      debugPrint(
        '_loadMediaData - Historia $historiaId: ${audios.length} áudios, ${videos.length} vídeos',
      );
      return {'audios': audios, 'videos': videos};
    } catch (e) {
      debugPrint('Erro em _loadMediaData: $e');
      return {'audios': <HistoriaAudio>[], 'videos': <v2.HistoriaVideo>[]};
    }
  }
}

// Widget para exibir áudios de uma história (mantido para compatibilidade)
class HistoriaAudiosSection extends StatelessWidget {
  final int historiaId;

  const HistoriaAudiosSection({super.key, required this.historiaId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoriaAudio>>(
      future: HistoriaAudioHelper().getAudiosByHistoria(historiaId),
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
                audioData: audio.audio,
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

  const HistoriaVideosSection({super.key, required this.historiaId});

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
