import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:typed_data';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/grupo.dart';
import '../models/historia.dart';
import '../models/historia_foto.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'edit_profile_screen.dart';
import 'group_selection_screen.dart';

class GroupStoriesScreen extends StatefulWidget {
  final Grupo grupo;

  const GroupStoriesScreen({super.key, required this.grupo});

  @override
  State<GroupStoriesScreen> createState() => _GroupStoriesScreenState();
}

class _GroupStoriesScreenState extends State<GroupStoriesScreen> {
  // Constantes para melhor organização
  static const double cardMargin = 24.0;

  bool _isCardView = true; // true = modo blocos, false = modo ícones

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

  Future<List<Historia>> _fetchHistoriasByGrupo() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where: 'user_id = ? AND grupo = ? AND arquivado IS NULL',
      whereArgs: [userId, widget.grupo.nome],
      orderBy: 'data DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList();
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir história'),
        content: const Text('Deseja realmente excluir esta história?'),
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
      await db.delete('historia', where: 'id = ?', whereArgs: [historia.id]);
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
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

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousTag = historia.tag;
    final previousGrupo = historia.grupo;

    await _updateHistoria(
      historia,
      updates: {'arquivado': 'sim', 'grupo': null},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('História arquivada'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            await _updateHistoria(
              historia,
              updates: {
                'arquivado': null,
                'tag': previousTag,
                'grupo': previousGrupo,
              },
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
                  Text(
                    historia.titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  if (historia.emoticon != null &&
                      historia.emoticon!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/image/${_getEmoticonImage(historia.emoticon!)}',
                      width: 32,
                      height: 32,
                    ),
                  ],
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[100]
                              : Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    historia.descricao ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
                          } else if (value == 'desagrupar') {
                            final refreshProvider =
                                Provider.of<RefreshProvider>(
                                  context,
                                  listen: false,
                                );
                            final messenger = ScaffoldMessenger.of(context);
                            await _updateHistoria(
                              historia,
                              updates: {
                                'tag': null,
                                'arquivado': null,
                                'grupo': null,
                              },
                            );
                            if (!mounted) return;
                            refreshProvider.refresh();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('História desagrupada'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'desagrupar',
                            child: Text('Desagrupar'),
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
          final navigator = Navigator.of(context);
          final selectedGroup = await navigator.push<String>(
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
              } else if (value == 'desagrupar') {
                final refreshProvider = Provider.of<RefreshProvider>(
                  context,
                  listen: false,
                );
                await _updateHistoria(
                  historia,
                  updates: {'tag': null, 'arquivado': null, 'grupo': null},
                );
                if (!mounted) return;
                refreshProvider.refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('História desagrupada')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(
                value: 'desagrupar',
                child: Text('Desagrupar'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
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
            Expanded(
              child: Text(
                widget.grupo.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
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
          // delete group
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _deleteGroup(),
            tooltip: 'Excluir Grupo',
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
                final navigator = Navigator.of(context);
                await auth.logout();
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
            future: _fetchHistoriasByGrupo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final historias = snapshot.data ?? [];
              if (historias.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhuma história no grupo "${widget.grupo.nome}".',
                  ),
                );
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
        child: FloatingActionButton(
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
          backgroundColor: const Color(0xFFB388FF),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Future<void> _deleteGroup() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir grupo'),
        content: Text(
          'Deseja remover o grupo "${widget.grupo.nome}" das suas histórias?',
        ),
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
      await db.update(
        'historia',
        {'grupo': null, 'data_update': DateTime.now().toIso8601String()},
        where: 'user_id = ? AND grupo = ?',
        whereArgs: [userId, widget.grupo.nome],
      );

      // Optionally remove the group from grupos table if present
      try {
        await db.delete(
          'grupos',
          where: 'user_id = ? AND nome = ?',
          whereArgs: [userId, widget.grupo.nome],
        );
      } catch (_) {}

      if (!mounted) return;
      navigator.pushReplacementNamed('/home');
    }
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

        // Use the same responsive collage layout as home_content
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
                          Uint8List.fromList(displayFotos[index].foto),
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
                  Image.memory(
                    Uint8List.fromList(foto.foto),
                    fit: BoxFit.cover,
                  ),
                  if (isLast)
                    Container(
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
                Uint8List.fromList(displayFotos[0].foto),
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
