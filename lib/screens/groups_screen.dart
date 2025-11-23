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
  List<Grupo> _grupos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrupos();
  }

  Future<void> _loadGrupos() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      if (userId != null) {
        final grupos = await GrupoHelper().getGruposByUser(userId);
        setState(() {
          _grupos = grupos;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _grupos.length + 1,
              itemBuilder: (context, index) {
                if (index == _grupos.length) {
                  return Column(
                    children: [
                      const Divider(height: 1, thickness: 1),
                      ListTile(
                        title: const Text('Arquivados'),
                        leading: const Icon(Icons.archive, color: Colors.grey),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

                final grupo = _grupos[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      grupo.emoticon ?? '📁',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(grupo.nome),
                  subtitle: Text(
                    'Criado em ${grupo.dataCriacao?.toLocal().toString().split(' ')[0] ?? ''}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupStoriesScreen(grupo: grupo),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
