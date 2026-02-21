import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/historia.dart';
import '../models/historia_video_v2.dart' as v2;
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/pdf_export_service.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'edit_profile_screen.dart';
import 'group_selection_screen.dart';
import 'pdf_preview_screen.dart';

class ArchivedStoriesScreen extends StatefulWidget {
  const ArchivedStoriesScreen({super.key});

  @override
  State<ArchivedStoriesScreen> createState() => _ArchivedStoriesScreenState();
}

class _ArchivedStoriesScreenState extends State<ArchivedStoriesScreen> {
  // Constantes para melhor organização
  static const double cardMargin = 24.0;

  bool _isCardView = true; // true = modo blocos, false = modo ícones

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

  Future<void> _exportHistoria(Historia historia) async {
    try {
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
      );
      final filename =
          'historia_${historia.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      if (!mounted) return;
      Navigator.push(
        context,
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
                ),
            filename: filename,
            title: 'Preview - ${historia.titulo}',
            onSave: null,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar PDF: $e')));
    }
  }

  Future<List<Historia>> _fetchHistoriasArquivadas() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where: 'user_id = ? AND arquivado = ? AND excluido IS NULL',
      whereArgs: [userId, 'sim'],
      orderBy: 'data DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList();
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

  Future<void> _updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    final db = await DatabaseHelper().database;
    final Map<String, dynamic> updateData = {
      'data_update': DateTime.now().toIso8601String(),
    };

    if (updates != null) {
      updateData.addAll(updates);
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
                  // Desarquivar (remover flag de arquivado)
                  await _updateHistoria(historia, updates: {'arquivado': null});
                },
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.restore,
                label: 'Desarquivar',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final selectedGroup = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GroupSelectionScreen(),
                    ),
                  );
                  if (selectedGroup != null) {
                    await _updateHistoria(
                      historia,
                      updates: {'grupo': selectedGroup, 'arquivado': null},
                    );
                  }
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.group,
                label: 'Grupo',
              ),
            ],
          ),
          child: GestureDetector(
            onDoubleTap: () {
              final refreshProvider = Provider.of<RefreshProvider>(
                context,
                listen: false,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHistoriaScreen(historia: historia),
                ),
              ).then((updated) {
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
                        Row(
                          children: [
                            if (historia.emoticon != null &&
                                historia.emoticon!.isNotEmpty)
                              Builder(
                                builder: (context) {
                                  final convertedEmoji = _convertLegacyEmoticon(
                                    historia.emoticon!,
                                  );
                                  final displayEmoji =
                                      convertedEmoji ?? historia.emoticon!;
                                  return Container(
                                    width: 36,
                                    alignment: Alignment.center,
                                    child: Text(
                                      displayEmoji,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        height: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (historia.emoticon != null &&
                                historia.emoticon!.isNotEmpty)
                              const SizedBox(width: 6),
                            SizedBox(
                              width: 140,
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
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final refreshProvider =
                                  Provider.of<RefreshProvider>(
                                    context,
                                    listen: false,
                                  );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditHistoriaScreen(historia: historia),
                                ),
                              ).then((updated) {
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
                              child: Text('Editar - 2 toques'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tags: movidas para abaixo da linha da data
                    if (historia.tag != null && historia.tag!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[700]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          historia.tag!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[100]
                                : Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
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
        color: Colors.green,
        child: const Text(
          'Desarquivar',
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
        color: Colors.blue,
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
          await _updateHistoria(
            historia,
            updates: {'arquivado': null, 'tag': null, 'grupo': null},
          );
          return true; // Remove o item da lista visualmente
        } else if (direction == DismissDirection.endToStart) {
          final selectedGroup = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
          );
          if (selectedGroup != null) {
            await _updateHistoria(
              historia,
              updates: {'grupo': selectedGroup, 'arquivado': null, 'tag': null},
            );
            return true; // Remove o item da lista visualmente
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Builder(
                builder: (context) {
                  if (historia.emoticon != null &&
                      historia.emoticon!.isNotEmpty) {
                    final converted = _convertLegacyEmoticon(
                      historia.emoticon!,
                    );
                    final display = converted ?? historia.emoticon!;
                    return Text(
                      display,
                      style: const TextStyle(fontSize: 20, height: 1),
                    );
                  }
                  return Icon(
                    Icons.image,
                    color: Theme.of(context).iconTheme.color,
                    size: 26,
                  );
                },
              ),
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
              } else if (value == 'export') {
                await _exportHistoria(historia);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'export', child: Text('Exportar PDF')),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon/icon.png', width: 32, height: 32),
            const SizedBox(width: 12),
            const Text(
              'Arquivados',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              _isCardView
                  ? 'assets/image/card.png'
                  : 'assets/image/icone_pequeno.png',
              width: 34,
              height: 34,
            ),
            onPressed: () {
              setState(() {
                _isCardView = !_isCardView;
              });
            },
            tooltip: _isCardView
                ? 'Alternar para modo ícones'
                : 'Alternar para modo blocos',
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final pinProvider = Provider.of<PinProvider>(
                  context,
                  listen: false,
                );
                final navigator = Navigator.of(context);
                await auth.logout();
                // Atualiza o status de login no PinProvider
                pinProvider.updateUserLoginStatus(false);
                if (!mounted) return;
                navigator.pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: Consumer<RefreshProvider>(
        builder: (context, refreshProvider, child) {
          return FutureBuilder<List<Historia>>(
            key: ValueKey<int>(refreshProvider.refreshCounter),
            future: _fetchHistoriasArquivadas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final historias = snapshot.data ?? [];
              if (historias.isEmpty) {
                return const Center(child: Text('Nenhuma história arquivada.'));
              }
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
          onPressed: () {
            final refreshProvider = Provider.of<RefreshProvider>(
              context,
              listen: false,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateHistoriaScreen()),
            ).then((created) {
              if (!mounted) return;
              refreshProvider.refresh();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Nova História'),
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
              child: Image.memory(
                fotos[0].bytes,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        final displayFotos = fotos;
        final total = displayFotos.length;

        void openViewer(int initialIndex) {
          showDialog(
            context: context,
            builder: (_) {
              return Dialog(
                insetPadding: const EdgeInsets.all(8),
                backgroundColor: Colors.black,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: PageView.builder(
                    controller: PageController(initialPage: initialIndex),
                    itemCount: total,
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        child: Image.memory(
                          displayFotos[index].bytes,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }

        Widget tileForIndex(int index) {
          final foto = displayFotos[index];
          final isLast = index == 3 && total > 4;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () => openViewer(index),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(foto.bytes, fit: BoxFit.cover),
                  if (isLast)
                    ColoredBox(
                      color: Colors.black45,
                      child: Center(
                        child: Text(
                          '+${total - 3}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        if (total == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () => openViewer(0),
              child: Image.memory(
                displayFotos[0].bytes,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
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

// Widget para exibir emoticon + áudios + vídeos em uma linha horizontal
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

        // Se não tem mídia (áudios ou vídeos), não mostra nada aqui.
        // Emoticon agora é exibido na linha da data, então não reserva altura por ele.
        if (audios.isEmpty && videos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Emoticon: removido do row de mídia (será mostrado na linha da data)
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
                      videoPath: video.videoPath,
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
