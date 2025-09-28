import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia_foto.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/notification_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'rich_text_editor_screen.dart';

// Note: This file implements two UI features requested by the team:
// 1) Importar arquivo .txt na descrição usando `file_selector` (_pickTxtFileForDescription).
/// 2) Animação de expansão do editor de descrição bottom-to-top ao abrir a tela de edição (_expandDescriptionEditor).
// The expanded editor screen is in `lib/screens/rich_text_editor_screen.dart` which
// provides drag-to-save (swipe down) behavior.

class SentenceCapitalizationTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String _capitalizeText(String text) {
      if (text.isEmpty) return text;
      // Capitalize first letter
      String result =
          text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
      // Capitalize after sentence endings
      result = result.replaceAllMapped(RegExp(r'([.!?]\s*)([a-z])'), (match) {
        return match.group(1)! + match.group(2)!.toUpperCase();
      });
      return result;
    }

    final capitalized = _capitalizeText(newValue.text);
    return newValue.copyWith(text: capitalized, selection: newValue.selection);
  }
}

class CreateHistoriaScreen extends StatefulWidget {
  const CreateHistoriaScreen({super.key});

  @override
  State<CreateHistoriaScreen> createState() => _CreateHistoriaScreenState();
}

class _CreateHistoriaScreenState extends State<CreateHistoriaScreen> {
  final titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final tagsController = TextEditingController();
  final List<Uint8List> fotos = [];
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  String? selectedEmoticon;

  final List<String> emoticons = [
    'Feliz',
    'Tranquilo',
    'Aliviado',
    'Pensativo',
    'Sono',
    'Preocupado',
    'Assustado',
    'Bravo',
    'Triste',
    'Muito Triste',
  ];

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

  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    // Capitalize first letter
    String result =
        text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
    // Capitalize after sentence endings
    result = result.replaceAllMapped(RegExp(r'([.!?]\s*)([a-z])'), (match) {
      return match.group(1)! + match.group(2)!.toUpperCase();
    });
    return result;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        fotos.add(bytes);
      });
    }
  }

  void _removeFoto(int index) {
    setState(() {
      fotos.removeAt(index);
    });
  }

  Future<void> _showNotificationDialog(int historiaId) async {
    Duration? selectedDuration;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agendar Notificação'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quando você gostaria de ser notificado sobre esta história?',
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...[
                          // {
                          //   'label': 'Imediata (teste)',
                          //   'duration': Duration.zero,
                          // },
                          // {
                          //   'label': 'Agora (teste)',
                          //   'duration': const Duration(seconds: 10),
                          // },
                          {
                            'label': '1 hora antes',
                            'duration': const Duration(hours: 1),
                          },
                          {
                            'label': '1 dia antes',
                            'duration': const Duration(days: 1),
                          },
                          {
                            'label': '1 semana antes',
                            'duration': const Duration(days: 7),
                          },
                        ].map(
                          (option) => RadioListTile<Duration>(
                            title: Text(option['label'] as String),
                            value: option['duration'] as Duration,
                            groupValue: selectedDuration,
                            onChanged: (Duration? value) {
                              setState(() {
                                selectedDuration = value;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selectedDuration != null) {
      DateTime notificationTime;
      if (selectedDuration == Duration.zero) {
        // Para teste imediato, mostrar notificação agora
        await NotificationService().showImmediateNotification(
          id: historiaId,
          title: 'Lembrete de História',
          body: 'Não esqueça: ${titleController.text}',
          payload: historiaId.toString(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notificação mostrada')));
        return;
      } else if (selectedDuration == const Duration(seconds: 10)) {
        // Para teste, notificar em 10 segundos a partir de agora
        notificationTime = DateTime.now().add(selectedDuration!);
      } else {
        // Para outros, notificar antes da data da história
        notificationTime = selectedDate.subtract(selectedDuration!);
      }
      if (notificationTime.isAfter(DateTime.now())) {
        if (Platform.isWindows) {
          // Notificações agendadas não são suportadas no Windows
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notificações agendadas não são suportadas no Windows',
              ),
            ),
          );
        } else {
          await NotificationService().scheduleNotification(
            id: historiaId,
            title: 'Lembrete de História',
            body: 'Não esqueça: ${titleController.text}',
            scheduledDate: notificationTime,
            payload: historiaId.toString(),
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificação agendada com sucesso')),
          );
        }
      }
    }
  }

  Future<void> _saveHistoria() async {
    selectedDate = DateTime.now();
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Título é obrigatório!')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Capture these before any async gaps to avoid using BuildContext after awaits
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      final navigator = Navigator.of(context);
      final db = await DatabaseHelper().database;

      // Salva a história (garante arquivado=null e grupo=null para aparecer na Home)
      final historiaId = await db.insert('historia', {
        'user_id': auth.user?.id ?? '',
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        'tag': tagsController.text.trim().isEmpty
            ? null
            : tagsController.text.trim(),
        'grupo': null,
        'arquivado': null,
        'emoticon': selectedEmoticon,
        'data': selectedDate.toIso8601String(),
        'data_criacao': DateTime.now().toIso8601String(),
        'data_update': DateTime.now().toIso8601String(),
      });

      // Salva as fotos (se houver)
      for (final foto in fotos) {
        await HistoriaFotoHelper().insertFoto(
          HistoriaFoto(historiaId: historiaId, foto: foto),
        );
      }

      // Se a data for futura, perguntar sobre notificação
      if (selectedDate.isAfter(DateTime.now())) {
        await _showNotificationDialog(historiaId);
      }

      // Atualiza a tela inicial
      if (!mounted) return;
      refreshProvider.refresh();

      // Navega para a tela inicial
      navigator.pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar história: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _expandDescriptionEditor() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<String>(
      PageRouteBuilder<String>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RichTextEditorScreen(initialText: descriptionController.text),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from bottom
          final slideTween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));
          // Fade in
          final fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              // child includes the AppBar so it will animate in parallel
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
    if (result != null) {
      if (!mounted) return;
      setState(() {
        descriptionController.text = result;
      });
    }
  }

  Future<void> _pickTxtFileForDescription() async {
    try {
      final typeGroup = XTypeGroup(extensions: ['txt']);
      final files = await openFiles(acceptedTypeGroups: [typeGroup]);
      if (files.isEmpty) return; // canceled
      final file = files.first;
      final content = await file.readAsString();

      if (!mounted) return;
      setState(() {
        descriptionController.text = content;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar arquivo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova História'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveHistoria,
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid de fotos
                    SizedBox(
                      height: 100,
                      child: fotos.isEmpty
                          ? GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.deepPurple,
                                  size: 32,
                                ),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: fotos.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                if (i < fotos.length) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          fotos[i],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => _removeFoto(i),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[700]
                                                  : Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.deepPurple,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateFormat.format(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Descrição',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/image/upload_file.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.upload_file, size: 20),
                                ),
                              ),
                              tooltip: 'Carregar .txt',
                              onPressed: _pickTxtFileForDescription,
                            ),
                            IconButton(
                              icon: SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/image/maximize.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.open_in_full, size: 20),
                                ),
                              ),
                              onPressed: _expandDescriptionEditor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: descriptionController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(8),
                              border: InputBorder.none,
                            ),
                            inputFormatters: [
                              SentenceCapitalizationTextInputFormatter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (separadas por vírgula)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selecione um Emoticon:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: emoticons
                          .map(
                            (emoticon) => GestureDetector(
                              onTap: () =>
                                  setState(() => selectedEmoticon = emoticon),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedEmoticon == emoticon
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  'assets/image/${_getEmoticonImage(emoticon)}',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
