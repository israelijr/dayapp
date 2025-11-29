import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../helpers/audio_file_helper.dart';
import '../helpers/image_compression_helper.dart';
import '../helpers/notification_helper.dart';
import '../helpers/photo_file_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/historia.dart';
import '../services/emoji_service.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/emoji_selection_modal.dart';
import '../widgets/entry_toolbar.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/rich_text_editor_widget.dart';
import '../widgets/video_recorder_widget.dart';
import 'rich_text_editor_screen.dart';

class SentenceCapitalizationTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Se apenas a seleção mudou (texto é igual), não fazer nada
    // Isso permite seleção de múltiplas palavras sem interferência
    if (oldValue.text == newValue.text) {
      return newValue;
    }

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

class EditHistoriaScreen extends StatefulWidget {
  final Historia historia;
  const EditHistoriaScreen({required this.historia, super.key});

  @override
  State<EditHistoriaScreen> createState() => _EditHistoriaScreenState();
}

class _EditHistoriaScreenState extends State<EditHistoriaScreen> {
  late TextEditingController titleController;
  late QuillController richTextController;
  late TextEditingController tagsController;
  late DateTime selectedDate;
  List<Uint8List> fotos = [];
  List<int> fotoIds = [];
  List<Map<String, dynamic>> audios = []; // {audio: Uint8List, duration: int}
  List<int> audioIds = []; // IDs dos áudios existentes
  List<Map<String, dynamic>> videos =
      []; // Para novos: {video: Uint8List, duration: int}, Para existentes: {videoPath: String, duration: int, id: int}
  List<int> videoIds = []; // IDs dos vídeos existentes
  String? selectedEmoticon;
  String? selectedEmojiTranslation;
  bool _isArchived = false;

  // Controle de alterações não salvas
  bool _hasUnsavedChanges = false;
  late String _initialTitle;
  late String _initialDescription;
  late String _initialTags;
  late DateTime _initialDate;
  late String? _initialEmoticon;
  late bool _initialIsArchived;

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
    titleController = TextEditingController(text: widget.historia.titulo);
    // Inicializa o Rich Text Controller com o conteúdo existente
    richTextController = RichTextHelper.smartController(
      widget.historia.descricao,
    );
    tagsController = TextEditingController(text: widget.historia.tag ?? '');
    selectedDate = widget.historia.data;
    selectedEmoticon = widget.historia.emoticon;
    _isArchived = widget.historia.arquivado == 'sim';

    // Salva valores iniciais para detectar mudanças
    _initialTitle = widget.historia.titulo;
    _initialDescription = richTextController.document.toPlainText();
    _initialTags = widget.historia.tag ?? '';
    _initialDate = widget.historia.data;
    _initialEmoticon = widget.historia.emoticon;
    _initialIsArchived = widget.historia.arquivado == 'sim';

    // Adiciona listeners para detectar mudanças
    titleController.addListener(_checkForChanges);
    richTextController.addListener(_checkForChanges);
    tagsController.addListener(_checkForChanges);

    _loadFotos();
    _loadAudios();
    _loadVideos();
    _loadEmojiTranslation();
  }

  final List<String> legacyEmoticons = [
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

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna o próprio valor se já for um emoji
  String _convertLegacyEmoticon(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '😊';
      case 'Tranquilo':
        return '😌';
      case 'Aliviado':
        return '😮‍💨';
      case 'Pensativo':
        return '🤔';
      case 'Sono':
        return '😴';
      case 'Preocupado':
        return '😟';
      case 'Assustado':
        return '😨';
      case 'Bravo':
        return '😠';
      case 'Triste':
        return '😢';
      case 'Muito Triste':
        return '😭';
      default:
        return emoticon; // Já é um emoji Unicode
    }
  }

  Future<void> _loadEmojiTranslation() async {
    if (selectedEmoticon != null &&
        !legacyEmoticons.contains(selectedEmoticon)) {
      await EmojiService().loadEmojis();
      final emoji = EmojiService().findByChar(selectedEmoticon!);
      if (mounted && emoji != null) {
        setState(() {
          selectedEmojiTranslation = emoji.translation;
        });
      }
    }
  }

  void _checkForChanges() {
    final currentDescription = richTextController.document.toPlainText();
    final hasChanges =
        titleController.text != _initialTitle ||
        currentDescription != _initialDescription ||
        tagsController.text != _initialTags ||
        selectedDate != _initialDate ||
        selectedEmoticon != _initialEmoticon ||
        _isArchived != _initialIsArchived;

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  Future<void> _loadFotos() async {
    final fotosDb = await HistoriaFotoHelper().getFotosByHistoria(
      widget.historia.id ?? 0,
    );
    if (!mounted) return;

    // Carregar bytes das fotos do sistema de arquivos
    final List<Uint8List> fotoBytes = [];
    final List<int> ids = [];
    for (final foto in fotosDb) {
      final bytes = await PhotoFileHelper.readPhoto(foto.fotoPath);
      if (bytes != null) {
        fotoBytes.add(bytes);
        ids.add(foto.id ?? 0);
      }
    }

    if (!mounted) return;
    setState(() {
      fotos = fotoBytes;
      fotoIds = ids;
    });
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => ImagePickerWidget(
        onImagePicked: (bytes) async {
          // Compress image to avoid SQLite CursorWindow limit (2MB)
          final compressedBytes = await ImageCompressionHelper.compressImage(
            bytes,
          );

          if (!mounted) return;
          setState(() {
            fotos.add(compressedBytes);
            fotoIds.add(0); // 0 indica nova foto
            _checkForChanges();
          });
        },
      ),
    );
  }

  void _removeFoto(int index) async {
    if (fotoIds[index] != 0) {
      final db = await DatabaseHelper().database;
      await db.delete(
        'historia_fotos',
        where: 'id = ?',
        whereArgs: [fotoIds[index]],
      );
    }
    if (!mounted) return;
    setState(() {
      fotos.removeAt(index);
      fotoIds.removeAt(index);
    });
  }

  Future<void> _loadAudios() async {
    final audiosDb = await HistoriaAudioHelper().getAudiosByHistoria(
      widget.historia.id ?? 0,
    );
    if (!mounted) return;

    // Carregar bytes dos áudios do sistema de arquivos
    final List<Map<String, dynamic>> audioData = [];
    final List<int> ids = [];
    for (final audio in audiosDb) {
      final bytes = await AudioFileHelper.readAudio(audio.audioPath);
      if (bytes != null) {
        audioData.add({'audio': bytes, 'duration': audio.duracao});
        ids.add(audio.id ?? 0);
      }
    }

    if (!mounted) return;
    setState(() {
      audios = audioData;
      audioIds = ids;
    });
  }

  Future<void> _loadVideos() async {
    try {
      final videosDb = await HistoriaVideoHelper().getVideosByHistoria(
        widget.historia.id ?? 0,
      );
      if (!mounted) return;
      setState(() {
        videos = videosDb
            .map(
              (v) => {
                'videoPath': v.videoPath, // Caminho ao invés de bytes
                'duration': v.duracao,
                'id': v.id,
              },
            )
            .toList();
        videoIds = videosDb.map((v) => v.id ?? 0).toList();
      });
    } catch (e) {
      // Error loading videos
    }
  }

  Future<void> _recordAudio() async {
    showDialog(
      context: context,
      builder: (context) => AudioRecorderWidget(
        onAudioRecorded: (audio, duration) {
          setState(() {
            audios.add({'audio': audio, 'duration': duration});
            audioIds.add(0); // 0 indica novo áudio
          });
        },
      ),
    );
  }

  void _removeAudio(int index) async {
    if (audioIds[index] != 0) {
      await HistoriaAudioHelper().deleteAudio(audioIds[index]);
    }
    if (!mounted) return;
    setState(() {
      audios.removeAt(index);
      audioIds.removeAt(index);
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
            videoIds.add(0); // 0 indica novo vídeo
          });
        },
      ),
    );
  }

  void _removeVideo(int index) async {
    if (videoIds[index] != 0) {
      // Vídeo existente - precisa deletar do banco e do sistema de arquivos
      final videoPath = videos[index]['videoPath'] as String;
      await HistoriaVideoHelper().deleteVideo(videoIds[index], videoPath);
    }
    if (!mounted) return;
    setState(() {
      videos.removeAt(index);
      videoIds.removeAt(index);
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
          _checkForChanges();
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
      richTextController.document.toPlainText(),
    );
  }

  Future<void> _save() async {
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': RichTextHelper.controllerToJson(richTextController),
        'tag': tagsController.text.trim().isEmpty
            ? null
            : tagsController.text.trim(),
        'emoticon': selectedEmoticon,
        'data': selectedDate.toIso8601String(),
        'data_update': DateTime.now().toIso8601String(),
        'arquivado': _isArchived ? 'sim' : null,
      },
      where: 'id = ?',
      whereArgs: [widget.historia.id],
    );

    // Verifica se a data foi alterada
    if (selectedDate != _initialDate) {
      // Cancela notificação existente (se houver)
      await NotificationHelper().cancelEntryNotification(widget.historia.id!);

      // Se a nova data permitir notificação (pelo menos 2 horas à frente), oferece criar notificação
      if (NotificationHelper().shouldScheduleNotification(selectedDate)) {
        if (mounted) {
          await _showNotificationDialog(widget.historia.id!);
        }
      }
    }

    // Salva novas fotos
    for (int i = 0; i < fotos.length; i++) {
      if (fotoIds[i] == 0) {
        await HistoriaFotoHelper().insertFotoFromBytes(
          historiaId: widget.historia.id ?? 0,
          fotoBytes: fotos[i],
        );
      }
    }

    // Salva novos áudios
    for (int i = 0; i < audios.length; i++) {
      if (audioIds[i] == 0) {
        await HistoriaAudioHelper().insertAudioFromBytes(
          historiaId: widget.historia.id ?? 0,
          audioBytes: audios[i]['audio'],
          duracao: audios[i]['duration'],
        );
      }
    }

    // Salva novos vídeos
    for (int i = 0; i < videos.length; i++) {
      if (videoIds[i] == 0) {
        try {
          await HistoriaVideoHelper().insertVideoFromBytes(
            historiaId: widget.historia.id ?? 0,
            videoBytes: videos[i]['video'],
            duracao: videos[i]['duration'],
          );
        } catch (e) {
          // Error saving video
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _expandDescriptionEditor() async {
    final navigator = Navigator.of(context);
    final richTextJson = RichTextHelper.controllerToJson(richTextController);
    final result = await navigator.push<String>(
      PageRouteBuilder<String>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RichTextEditorScreen(initialText: richTextJson),
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
        // Reconstrói o controller com o JSON retornado
        final newController = RichTextHelper.smartController(result);
        // Substitui todo o documento
        richTextController.replaceText(
          0,
          richTextController.document.length - 1,
          newController.document.toDelta(),
          null,
        );
      });
    }
  }

  Future<void> _pickTxtFileForDescription() async {
    try {
      const typeGroup = XTypeGroup(extensions: ['txt']);
      final files = await openFiles(acceptedTypeGroups: [typeGroup]);
      if (files.isEmpty) return; // canceled
      final file = files.first;
      final content = await file.readAsString();
      if (!mounted) return;
      setState(() {
        richTextController.document.delete(
          0,
          richTextController.document.length,
        );
        richTextController.document.insert(0, content);
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
  void dispose() {
    titleController.removeListener(_checkForChanges);
    richTextController.removeListener(_checkForChanges);
    tagsController.removeListener(_checkForChanges);
    titleController.dispose();
    richTextController.dispose();
    tagsController.dispose();
    super.dispose();
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
        final dialogResult = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Descartar alterações?'),
            content: const Text(
              'Você tem alterações não salvas. Deseja sair sem salvar?',
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
          await _save();
        } else if (dialogResult == 'discard') {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar História'),
          actions: [
            TextButton(
              onPressed: _save,
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
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 20),
                          onPressed: _pickDateTime,
                          tooltip: 'Alterar Data',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        const Spacer(),
                        if (selectedEmoticon != null)
                          Chip(
                            avatar: Text(
                              _convertLegacyEmoticon(selectedEmoticon!),
                              style: const TextStyle(fontSize: 20),
                            ),
                            label: Text(
                              selectedEmojiTranslation ??
                                  selectedEmoticon ??
                                  '',
                            ),
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
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Digite o título',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    RichTextEditorWidget(
                      key: const Key('description_field'),
                      controller: richTextController,
                      hintText: 'Escreva sua história...',
                      minLines: 8,
                      maxLines: 15,
                      showToolbar: true,
                      onChanged: () {
                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      },
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
                    const SizedBox(height: 16),

                    // Archive Switch
                    SwitchListTile(
                      title: const Text('Arquivado'),
                      subtitle: const Text('Ocultar da tela inicial'),
                      value: _isArchived,
                      onChanged: (value) {
                        setState(() {
                          _isArchived = value;
                          _checkForChanges();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
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
                            videoPath: entry.value['videoPath'],
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

            // Description Toolbar (above main toolbar)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: _pickTxtFileForDescription,
                      tooltip: 'Importar .txt',
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.open_in_full),
                      onPressed: _expandDescriptionEditor,
                      tooltip: 'Expandir',
                    ),
                  ),
                ],
              ),
            ),
            // Main Toolbar (photos, videos, audio, emoji)
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
