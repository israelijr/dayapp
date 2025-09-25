import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia_foto.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import 'dart:io';

class CreateHistoriaScreen extends StatefulWidget {
  const CreateHistoriaScreen({super.key});

  @override
  State<CreateHistoriaScreen> createState() => _CreateHistoriaScreenState();
}

class _CreateHistoriaScreenState extends State<CreateHistoriaScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
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
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
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

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
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
                          {
                            'label': 'Imediata (teste)',
                            'duration': Duration.zero,
                          },
                          {
                            'label': 'Agora (teste)',
                            'duration': const Duration(seconds: 10),
                          },
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificação agendada com sucesso')),
          );
        }
      }
    }
  }

  Future<void> _saveHistoria() async {
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
      final db = await DatabaseHelper().database;

      // Salva a história
      final historiaId = await db.insert('historia', {
        'user_id': auth.user?.id ?? '',
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': _capitalizeText(descriptionController.text.trim()),
        'tag': tagsController.text.trim(),
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

      // Navega para a tela inicial
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
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
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: Colors.deepPurple,
                          ),
                          onPressed: _pickDateTime,
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
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.text,
                      enableSuggestions: true,
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
