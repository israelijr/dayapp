import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../services/emoji_service.dart';
import '../widgets/emoji_selection_modal.dart';
import 'archived_stories_screen.dart';

class GroupsMaintenanceScreen extends StatefulWidget {
  const GroupsMaintenanceScreen({super.key});

  @override
  State<GroupsMaintenanceScreen> createState() =>
      _GroupsMaintenanceScreenState();
}

class _GroupsMaintenanceScreenState extends State<GroupsMaintenanceScreen> {
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

  Future<void> _showGroupDialog({Grupo? grupo}) async {
    final isEditing = grupo != null;
    final nameController = TextEditingController(text: grupo?.nome);
    String? selectedEmoticon = grupo?.emoticon;
    String? selectedEmojiTranslation;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Grupo' : 'Novo Grupo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final Emoji? result = await showModalBottomSheet<Emoji>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const EmojiSelectionModal(),
                    );
                    if (result != null) {
                      setStateDialog(() {
                        selectedEmoticon = result.char;
                        selectedEmojiTranslation = result.translation;
                      });
                    }
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      selectedEmoticon ?? '😀',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedEmojiTranslation ?? 'Escolher ícone',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Grupo',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final userId = auth.user?.id;
                  if (userId == null) return;

                  try {
                    if (isEditing) {
                      final updatedGrupo = Grupo(
                        id: grupo.id,
                        userId: userId,
                        nome: name,
                        emoticon: selectedEmoticon,
                        dataCriacao: grupo.dataCriacao,
                      );
                      await GrupoHelper().updateGrupo(updatedGrupo);
                    } else {
                      final newGrupo = Grupo(
                        userId: userId,
                        nome: name,
                        emoticon: selectedEmoticon,
                        dataCriacao: DateTime.now(),
                      );
                      await GrupoHelper().insertGrupo(newGrupo);
                    }
                    if (context.mounted) Navigator.pop(context);
                    _loadGrupos();
                  } catch (e) {
                    // Tratar erro se necessário
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteGrupo(Grupo grupo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: Text(
          'Deseja excluir o grupo "${grupo.nome}"? As histórias deste grupo não serão excluídas, apenas removidas do grupo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      if (userId != null && grupo.id != null) {
        await GrupoHelper().deleteGrupoAndUpdateHistorias(
          grupo.id!,
          grupo.nome,
          userId,
        );
        _loadGrupos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Grupos')),
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
                        // Arquivados não é editável, apenas visualização/navegação
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showGroupDialog(grupo: grupo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteGrupo(grupo),
                      ),
                    ],
                  ),
                  onTap: () => _showGroupDialog(grupo: grupo),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
