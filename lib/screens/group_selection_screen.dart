import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final TextEditingController _newGroupController = TextEditingController();

  Future<List<Grupo>> _loadGrupos() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return [];
    return await GrupoHelper().getGruposByUser(userId);
  }

  void _selectGroup(String group) {
    Navigator.pop(context, group);
  }

  void _createNewGroup() async {
    final newGroupName = _newGroupController.text.trim();
    if (newGroupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o grupo')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    // Verificar se já existe
    final existing = await GrupoHelper().getGrupoByNome(userId, newGroupName);
    if (existing != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Grupo já existe')));
      return;
    }

    // Criar novo grupo
    final newGrupo = Grupo(
      userId: userId,
      nome: newGroupName,
      dataCriacao: DateTime.now(),
    );
    await GrupoHelper().insertGrupo(newGrupo);
    if (!mounted) return;
    Navigator.pop(context, newGroupName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Grupo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Grupo>>(
          future: _loadGrupos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final grupos = snapshot.data ?? [];
            return Column(
              children: [
                const Text(
                  'Grupos Existentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = grupos[index];
                      return ListTile(
                        title: Text(grupo.nome),
                        onTap: () => _selectGroup(grupo.nome),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Criar Novo Grupo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newGroupController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Grupo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createNewGroup,
                  child: const Text('Criar e Selecionar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
