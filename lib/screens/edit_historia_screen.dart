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
// ...existing code...

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
    _loadFotos();
    _loadAudios();
    _loadVideos();
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
      if (!mounted) return;
      setState(() {
        fotos.add(bytes);
        fotoIds.add(0); // 0 indica nova foto
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
      debugPrint('_loadVideos: ${videosDb.length} vídeos carregados');
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
      debugPrint('_loadVideos: erro ao carregar vídeos: $e');
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
          debugPrint('Vídeo recebido: ${video.length} bytes');
          setState(() {
            videos.add({
              'video': video,
              'thumbnail': null,
              'duration': duration,
            });
            videoIds.add(0); // 0 indica novo vídeo
          });
          debugPrint(
            'Vídeo adicionado à lista. Total de vídeos: ${videos.length}',
          );
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
      },
      where: 'id = ?',
      whereArgs: [widget.historia.id],
    );
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
        debugPrint(
          'Salvando novo vídeo $i - Tamanho: ${videos[i]['video'].length} bytes, Duração: ${videos[i]['duration']}',
        );
        try {
          final videoId = await HistoriaVideoHelper().insertVideoFromBytes(
            historiaId: widget.historia.id ?? 0,
            videoBytes: videos[i]['video'],
            duracao: videos[i]['duration'],
          );
          debugPrint('Vídeo $i salvo com ID: $videoId');
        } catch (e) {
          debugPrint('Erro ao salvar vídeo $i: $e');
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar História'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i < fotos.length) {
                      final double w = 100 - (i % 2) * 30;
                      final double h = 100 - ((i + 1) % 2) * 20;
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              fotos[i],
                              width: w,
                              height: h,
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
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]
                                      : Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
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

              // Seção de Áudios
              if (audios.isNotEmpty) ...[
                const Text(
                  'Áudios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: audios.asMap().entries.map((entry) {
                    final index = entry.key;
                    final audioData = entry.value;
                    return CompactAudioIcon(
                      audioData: audioData['audio'],
                      duration: audioData['duration'],
                      onDelete: () => _removeAudio(index),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Botão para adicionar áudio
              OutlinedButton.icon(
                onPressed: _recordAudio,
                icon: const Icon(Icons.audiotrack),
                label: const Text('Áudio'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),

              // Seção de Vídeos
              if (videos.isNotEmpty) ...[
                const Text(
                  'Vídeos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: videos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final videoData = entry.value;
                    return CompactVideoIcon(
                      videoData: videoData['video'], // Para vídeos novos
                      videoPath:
                          videoData['videoPath'], // Para vídeos existentes
                      thumbnail: videoData['thumbnail'],
                      duration: videoData['duration'],
                      onDelete: () => _removeVideo(index),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Botão para adicionar vídeo
              OutlinedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam),
                label: const Text('Vídeo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
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
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                inputFormatters: [SentenceCapitalizationTextInputFormatter()],
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
                  SizedBox(
                    height: 150,
                    child: TextField(
                      key: const Key('description_field'),
                      controller: descriptionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'Digite a descrição...',
                        alignLabelWithHint: true,
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
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecione um Emoticon:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
