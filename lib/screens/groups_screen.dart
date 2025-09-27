import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import 'group_stories_screen.dart';
import 'archived_stories_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  Future<List<Grupo>> _loadGrupos() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return [];
    return await GrupoHelper().getGruposByUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
      body: FutureBuilder<List<Grupo>>(
        future: _loadGrupos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final grupos = snapshot.data ?? [];
          return ListView.builder(
            itemCount: grupos.length + 1, // +1 para o item "Arquivados"
            itemBuilder: (context, index) {
              // Último item é "Arquivados"
              if (index == grupos.length) {
                return Column(
                  children: [
                    const Divider(height: 1, thickness: 1),
                    ListTile(
                      title: const Text('Arquivados'),
                      leading: const Icon(Icons.archive, color: Colors.grey),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArchivedStoriesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }

              // Itens normais dos grupos
              final grupo = grupos[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(grupo.nome),
                    subtitle: Text(
                      'Criado em ${grupo.dataCriacao?.toLocal().toString().split(' ')[0] ?? ''}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupStoriesScreen(grupo: grupo),
                        ),
                      );
                    },
                  ),
                  if (index < grupos.length - 1) const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
