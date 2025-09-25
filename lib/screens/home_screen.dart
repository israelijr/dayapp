import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m3_carousel/m3_carousel.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../models/historia_foto.dart';
import '../providers/auth_provider.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Historia>> _fetchHistorias() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('historia', orderBy: 'data DESC');
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
      setState(() {});
    }
  }

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

  Widget _buildCardView(Historia historia) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 100),
            const SizedBox(height: 12),
            Text(
              historia.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (historia.emoticon != null && historia.emoticon!.isNotEmpty) ...[
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  historia.tag!,
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              historia.descricao ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(historia.data),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.black38),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditHistoriaScreen(historia: historia),
                        ),
                      ).then((updated) {
                        if (updated == true) setState(() {});
                      });
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
          ],
        ),
      ),
    );
  }

  Widget _buildIconView(Historia historia) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(
          'assets/image/image.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        title: Text(
          historia.titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy', 'pt_BR').format(historia.data),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.black38),
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHistoriaScreen(historia: historia),
                ),
              ).then((updated) {
                if (updated == true) setState(() {});
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
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(child: _buildCardView(historia)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon/icon.png', width: 32, height: 32),
            const SizedBox(width: 12),
            const Text('Diário', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFB388FF)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
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
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                if (mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Historia>>(
        future: _fetchHistorias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final historias = snapshot.data ?? [];
          if (historias.isEmpty) {
            return const Center(child: Text('Nenhuma história cadastrada.'));
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              key: ValueKey<bool>(_isCardView),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateHistoriaScreen()),
            ).then((created) {
              // Atualiza a lista após criar uma nova história
              setState(() {});
            });
          },
          backgroundColor: const Color(0xFFB388FF),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
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

        return SizedBox(
          height: height,
          child: M3Carousel(
            children: fotos.map((foto) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Image.memory(Uint8List.fromList(foto.foto)),
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
                    Uint8List.fromList(foto.foto),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
