import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/historia.dart';
import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia_foto.dart';
import '../models/historia_audio.dart';
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
import '../helpers/notification_helper.dart';
import '../helpers/image_compression_helper.dart';

import '../helpers/markdown_helper.dart';

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
  const EditHistoriaScreen({super.key, required this.historia});

  @override
  State<EditHistoriaScreen> createState() => _EditHistoriaScreenState();
}

class _EditHistoriaScreenState extends State<EditHistoriaScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
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
    descriptionController = TextEditingController(
      text: widget.historia.descricao ?? '',
    );
    tagsController = TextEditingController(text: widget.historia.tag ?? '');
    selectedDate = widget.historia.data;
    selectedEmoticon = widget.historia.emoticon;
    _isArchived = widget.historia.arquivado == 'sim';

    // Salva valores iniciais para detectar mudanças
    _initialTitle = widget.historia.titulo;
    _initialDescription = widget.historia.descricao ?? '';
    _initialTags = widget.historia.tag ?? '';
    _initialDate = widget.historia.data;
    _initialEmoticon = widget.historia.emoticon;
    _initialIsArchived = widget.historia.arquivado == 'sim';

    // Adiciona listeners para detectar mudanças
    titleController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
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

  String _getLegacyEmoticonImage(String emoticon) {
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
    final hasChanges =
        titleController.text != _initialTitle ||
        descriptionController.text != _initialDescription ||
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
    setState(() {
      fotos = fotosDb.map((f) => Uint8List.fromList(f.foto)).toList();
      fotoIds = fotosDb.map((f) => f.id ?? 0).toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();

      // Compress image to avoid SQLite CursorWindow limit (2MB)
      final compressedBytes = await ImageCompressionHelper.compressImage(bytes);

      if (!mounted) return;
      setState(() {
        fotos.add(compressedBytes);
        fotoIds.add(0); // 0 indica nova foto
        _checkForChanges();
      });
    }
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
    setState(() {
      audios = audiosDb
          .map(
            (a) => {
              'audio': Uint8List.fromList(a.audio),
              'duration': a.duracao,
            },
          )
          .toList();
      audioIds = audiosDb.map((a) => a.id ?? 0).toList();
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

  Future<void> _save() async {
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': descriptionController.text.trim().isEmpty
            ? null
            : _capitalizeText(descriptionController.text.trim()),
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

    // Verifica se a data foi alterada e está futura
    if (selectedDate != _initialDate) {
      // Reagendar notificação se a data mudou
      await NotificationHelper().rescheduleEntryNotification(
        widget.historia.id!,
        _initialDate,
        selectedDate,
        titleController.text.trim(),
        descriptionController.text.trim(),
      );
    }

    // Salva novas fotos
    for (int i = 0; i < fotos.length; i++) {
      if (fotoIds[i] == 0) {
        await HistoriaFotoHelper().insertFoto(
          HistoriaFoto(historiaId: widget.historia.id ?? 0, foto: fotos[i]),
        );
      }
    }

    // Salva novos áudios
    for (int i = 0; i < audios.length; i++) {
      if (audioIds[i] == 0) {
        await HistoriaAudioHelper().insertAudio(
          HistoriaAudio(
            historiaId: widget.historia.id ?? 0,
            audio: audios[i]['audio'],
            duracao: audios[i]['duration'],
          ),
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
  void dispose() {
    titleController.removeListener(_checkForChanges);
    descriptionController.removeListener(_checkForChanges);
    tagsController.removeListener(_checkForChanges);
    titleController.dispose();
    descriptionController.dispose();
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
                            avatar: legacyEmoticons.contains(selectedEmoticon)
                                ? Image.asset(
                                    'assets/image/${_getLegacyEmoticonImage(selectedEmoticon!)}',
                                    width: 24,
                                    height: 24,
                                  )
                                : Text(selectedEmoticon!),
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
                    TextField(
                      key: const Key('description_field'),
                      controller: descriptionController,
                      maxLines: 5,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Escreva sua história...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        alignLabelWithHint: true,
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
                      icon: const Icon(Icons.format_shapes),
                      onPressed: () {
                        // Trigger markdown modal
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.format_bold),
                                  title: const Text('Negrito'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    MarkdownHelper.wrapSelection(
                                      descriptionController,
                                      '**',
                                      '**',
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.format_italic),
                                  title: const Text('Itálico'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    MarkdownHelper.wrapSelection(
                                      descriptionController,
                                      '*',
                                      '*',
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.strikethrough_s),
                                  title: const Text('Tachado'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    MarkdownHelper.wrapSelection(
                                      descriptionController,
                                      '~~',
                                      '~~',
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.title),
                                  title: const Text('Título'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    MarkdownHelper.formatHeading(
                                      descriptionController,
                                      1,
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.format_list_bulleted,
                                  ),
                                  title: const Text('Lista'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    MarkdownHelper.toggleList(
                                      descriptionController,
                                      ordered: false,
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.code),
                                  title: const Text('Código'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    MarkdownHelper.wrapSelection(
                                      descriptionController,
                                      '`',
                                      '`',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      tooltip: 'Markdown',
                    ),
                  ),
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
