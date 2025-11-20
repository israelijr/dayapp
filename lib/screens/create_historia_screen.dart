import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia_foto.dart';
import '../models/historia_audio.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../helpers/notification_helper.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'rich_text_editor_screen.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/video_recorder_widget.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/emoji_selection_modal.dart';
import '../services/emoji_service.dart';
import '../widgets/entry_toolbar.dart';

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
    String capitalizeText(String text) {
      if (text.isEmpty) return text;

      // Capitaliza a primeira letra do texto
      String result = text;
      if (result.isNotEmpty) {
        result = result[0].toUpperCase() + result.substring(1);
      }

      // Capitaliza após pontos finais (., !, ?) seguidos de espaço e letra minúscula
      result = result.replaceAllMapped(
        RegExp(r'([.!?]\s+)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      // Capitaliza após quebras de linha
      result = result.replaceAllMapped(
        RegExp(r'(\n)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      return result;
    }

    final capitalized = capitalizeText(newValue.text);
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
  final List<Map<String, dynamic>> audios =
      []; // {audio: Uint8List, duration: int}
  final List<Map<String, dynamic>> videos =
      []; // {video: Uint8List, thumbnail: Uint8List?, duration: int}
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  String? selectedEmoticon;
  String? selectedEmojiTranslation;

  // Controle de alterações não salvas
  bool _hasUnsavedChanges = false;



  String _capitalizeText(String text) {
    if (text.isEmpty) return text;

    // Capitaliza a primeira letra do texto
    String result = text;
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }

    // Capitaliza após pontos finais (., !, ?) seguidos de espaço e letra minúscula
    result = result.replaceAllMapped(
      RegExp(r'([.!?]\s+)([a-z])'),
      (match) => match.group(1)! + match.group(2)!.toUpperCase(),
    );

    // Capitaliza após quebras de linha
    result = result.replaceAllMapped(
      RegExp(r'(\n)([a-z])'),
      (match) => match.group(1)! + match.group(2)!.toUpperCase(),
    );

    return result;
  }

  @override
  void initState() {
    super.initState();
    // Adiciona listeners para detectar mudanças
    titleController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
    tagsController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    // Na tela de criação, qualquer coisa digitada é considerada mudança
    final hasChanges =
        titleController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        tagsController.text.isNotEmpty ||
        fotos.isNotEmpty ||
        audios.isNotEmpty ||
        videos.isNotEmpty ||
        selectedEmoticon != null;

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_checkForChanges);
    descriptionController.removeListener(_checkForChanges);
    tagsController.removeListener(_checkForChanges);
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        fotos.add(bytes);
        _checkForChanges();
      });
    }
  }

  void _removeFoto(int index) {
    setState(() {
      fotos.removeAt(index);
      _checkForChanges();
    });
  }

  Future<void> _recordAudio() async {
    showDialog(
      context: context,
      builder: (context) => AudioRecorderWidget(
        onAudioRecorded: (audio, duration) {
          setState(() {
            audios.add({'audio': audio, 'duration': duration});
            _checkForChanges();
          });
        },
      ),
    );
  }

  void _removeAudio(int index) {
    setState(() {
      audios.removeAt(index);
      _checkForChanges();
    });
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      builder: (context) => VideoRecorderWidget(
        onVideoRecorded: (video, duration) {
          setState(() {
            videos.add({
              'video': video,
              'thumbnail': null,
              'duration': duration,
            });
            _checkForChanges();
          });
        },
      ),
    );
  }

  void _removeVideo(int index) {
    setState(() {
      videos.removeAt(index);
      _checkForChanges();
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
    if (!mounted) return;
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (!mounted) return;
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
    await NotificationHelper().showNotificationDialog(
      context,
      historiaId,
      selectedDate,
      titleController.text,
      descriptionController.text,
    );
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
            : _capitalizeText(descriptionController.text.trim()),
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

      // Salva os áudios (se houver)
      for (final audioData in audios) {
        await HistoriaAudioHelper().insertAudio(
          HistoriaAudio(
            historiaId: historiaId,
            audio: audioData['audio'],
            duracao: audioData['duration'],
          ),
        );
      }

      // Salva os vídeos (se houver)
      for (final videoData in videos) {
        await HistoriaVideoHelper().insertVideoFromBytes(
          historiaId: historiaId,
          videoBytes: videoData['video'],
          duracao: videoData['duration'],
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

  Future<void> _selectEmoji() async {
    final Emoji? result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmojiSelectionModal(),
    );
    if (result != null) {
      setState(() {
        selectedEmoticon = result.char;
        selectedEmojiTranslation = result.translation;
        _checkForChanges();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          Navigator.of(context).pop();
          return;
        }
        if (_isLoading) return;

        final dialogResult = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Descartar história?'),
            content: const Text(
              'Você tem uma nova história não salva. Deseja sair sem salvar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('discard'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Descartar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('save'),
                child: const Text('Salvar'),
              ),
            ],
          ),
        );

        if (!context.mounted) return;

        if (dialogResult == 'save') {
          await _saveHistoria();
        } else if (dialogResult == 'discard') {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nova História'),
          actions: [
             IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDateTime,
              tooltip: 'Alterar Data',
            ),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Date and Emoji
                    Row(
                      children: [
                        Text(
                          dateFormat.format(selectedDate),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (selectedEmoticon != null)
                          Chip(
                            avatar: Text(selectedEmoticon!),
                            label: Text(selectedEmojiTranslation ?? ''),
                            onDeleted: () {
                              setState(() {
                                selectedEmoticon = null;
                                selectedEmojiTranslation = null;
                                _checkForChanges();
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    TextField(
                      controller: titleController,
                      style: theme.textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Título',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                    ),
                    const Divider(),
                    
                    // Description
                    TextField(
                      key: const Key('description_field'),
                      controller: descriptionController,
                      maxLines: null,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Escreva sua história...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.upload_file),
                              onPressed: _pickTxtFileForDescription,
                              tooltip: 'Importar .txt',
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_full),
                              onPressed: _expandDescriptionEditor,
                              tooltip: 'Expandir',
                            ),
                          ],
                        ),
                      ),
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Media Previews
                    if (fotos.isNotEmpty) ...[
                      Text('Fotos', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: fotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
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
                                  child: IconButton.filled(
                                    onPressed: () => _removeFoto(i),
                                    icon: const Icon(Icons.close, size: 14),
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(24, 24),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (audios.isNotEmpty) ...[
                      Text('Áudios', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: audios.asMap().entries.map((entry) {
                          return CompactAudioIcon(
                            audioData: entry.value['audio'],
                            duration: entry.value['duration'],
                            onDelete: () => _removeAudio(entry.key),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (videos.isNotEmpty) ...[
                      Text('Vídeos', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: videos.asMap().entries.map((entry) {
                          return CompactVideoIcon(
                            videoData: entry.value['video'],
                            thumbnail: entry.value['thumbnail'],
                            duration: entry.value['duration'],
                            onDelete: () => _removeVideo(entry.key),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Toolbar
            EntryToolbar(
              onPickPhoto: _pickImage,
              onPickVideo: _pickVideo,
              onRecordAudio: _recordAudio,
              onSelectEmoji: _selectEmoji,
            ),
          ],
        ),
      ),
    );
  }
}
