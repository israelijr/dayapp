import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// ...existing code...
import '../services/file_utils.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  DateTime? _selectedDate;
  String? _errorMessage;
  bool _isLoading = false;
  String? _pickedImagePath;
  AuthProvider? _authProvider; // Salvar referência

  // Helper para mostrar SnackBar
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void initState() {
    super.initState();
    // Inicializar controllers vazios
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _birthDateController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Acessar context aqui é seguro
    if (_authProvider == null) {
      _authProvider = context.read<AuthProvider>();
      final user = _authProvider!.user!;
      _nameController.text = user.nome;
      _emailController.text = user.email;
      _selectedDate = user.dtNascimento;
      _birthDateController.text = user.dtNascimento != null
          ? DateFormat('dd/MM/yyyy').format(user.dtNascimento!)
          : '';
      _pickedImagePath = user.fotoPerfil;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateUser(
      nome: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dtNascimento: _selectedDate,
      fotoPerfil:
          _pickedImagePath ??
          authProvider.user!.fotoPerfil, // mantém nova foto (ou a atual)
    );
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Mostrar mensagem de sucesso
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Aguardar um pouco para usuário ver a mensagem
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Remover o SnackBar antes de voltar
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      // Pequeno delay para garantir que o SnackBar foi removido
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = 'Erro ao atualizar perfil. Tente novamente.';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        final File tmpFile = File(picked.path);
        final oldPath = _pickedImagePath;
        // copy into app directory
        final savedPath = await FileUtils.copyProfileImageToApp(tmpFile);

        // if oldPath points to a local file inside profile_images, delete it
        if (oldPath != null && oldPath.isNotEmpty && oldPath != savedPath) {
          await FileUtils.deleteFileIfExists(oldPath);
        }

        if (!mounted) return;
        setState(() {
          _pickedImagePath = savedPath;
        });
      }
    } catch (e) {
      // Mostrar erro
      _showSnackBar('Erro ao selecionar imagem');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Salvar',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _pickedImagePath != null
                          ? (_pickedImagePath!.startsWith('http')
                                ? NetworkImage(_pickedImagePath!)
                                      as ImageProvider
                                : (File(_pickedImagePath!).existsSync()
                                      ? FileImage(File(_pickedImagePath!))
                                      : null))
                          : (context.watch<AuthProvider>().user!.fotoPerfil !=
                                    null
                                ? (context
                                          .watch<AuthProvider>()
                                          .user!
                                          .fotoPerfil!
                                          .startsWith('http')
                                      ? NetworkImage(
                                              context
                                                  .watch<AuthProvider>()
                                                  .user!
                                                  .fotoPerfil!,
                                            )
                                            as ImageProvider
                                      : (File(
                                              context
                                                  .watch<AuthProvider>()
                                                  .user!
                                                  .fotoPerfil!,
                                            ).existsSync()
                                            ? FileImage(
                                                File(
                                                  context
                                                      .watch<AuthProvider>()
                                                      .user!
                                                      .fotoPerfil!,
                                                ),
                                              )
                                            : null))
                                : null),
                      child:
                          (_pickedImagePath == null &&
                              context.watch<AuthProvider>().user!.fotoPerfil ==
                                  null)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome completo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-mail é obrigatório';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Digite um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Salvar Alterações',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
