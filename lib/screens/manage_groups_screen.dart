import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../db/database_helper.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  Future<List<Grupo>> _loadGrupos() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return [];
    return await GrupoHelper().getGruposByUser(userId);
  }

  Future<void> _deleteGrupo(Grupo grupo) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    // Verificar se há histórias vinculadas
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM historia WHERE user_id = ? AND tag = ?',
      [userId, grupo.nome],
    );
    final historiasCount = result.isNotEmpty ? result.first['count'] as int : 0;

    bool confirmDelete = true;
    if (historiasCount > 0) {
      confirmDelete =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmar exclusão'),
                content: Text(
                  'Este grupo tem $historiasCount história(s) vinculada(s). Ao excluir, essas histórias voltarão para a tela inicial (sem grupo). Deseja continuar?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Excluir'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    if (confirmDelete) {
      await GrupoHelper().deleteGrupoAndUpdateHistorias(
        grupo.id!,
        grupo.nome,
        userId,
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo excluído com sucesso')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Grupos')),
      body: FutureBuilder<List<Grupo>>(
        future: _loadGrupos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final grupos = snapshot.data ?? [];
          if (grupos.isEmpty) {
            return const Center(child: Text('Nenhum grupo encontrado'));
          }
          return ListView.builder(
            itemCount: grupos.length,
            itemBuilder: (context, index) {
              final grupo = grupos[index];
              return ListTile(
                title: Text(grupo.nome),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteGrupo(grupo),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
