import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/capitulo_helper.dart';
import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../db/tag_helper.dart';
import '../helpers/audio_file_helper.dart';
import '../helpers/notification_helper.dart';
import '../helpers/photo_file_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/historia.dart';
import '../models/tag.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/premium_provider.dart';
import '../services/capitulo_save_service.dart';
import '../services/emoji_service.dart';
import '../services/pdf_export_service.dart';
import '../theme/animation_durations.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';
import '../widgets/entry_toolbar.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/mood_energy_selectors.dart';
import '../widgets/rich_text_editor_widget.dart';
import '../widgets/tag_input_widget.dart';
import '../widgets/video_recorder_widget.dart';
import 'pdf_preview_screen.dart';
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
  final CapituloHelper _capituloHelper = CapituloHelper();
  late TextEditingController titleController;
  late QuillController richTextController;
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
  int _selectedMood = 3; // padrão: Neutro
  int _selectedEnergy = 2; // padrão: Normal

  // Lista de tags selecionadas (carregadas do banco em initState)
  List<Tag> _selectedTags = [];
  List<Tag> _initialTags = [];

  // Configuração opcional de vínculo com capítulos durante o salvamento.
  CapituloVinculoModo _capituloVinculoModo = CapituloVinculoModo.none;
  int? _capituloSelecionadoId;
  String _novoCapituloTitulo = '';
  Set<int> _novoCapituloEntradasRelacionadas = <int>{};

  // Controle de alterações não salvas
  bool _hasUnsavedChanges = false;
  // flag usada para indicar que initState já terminou e os controllers estão
  // disponíveis. Isto permite que métodos chamados em testes (sem árvore)
  // não tentem acessar objetos ainda não inicializados.
  bool _initialized = false;
  late String _initialTitle;
  late String _initialDescription;
  late DateTime _initialDate;
  late String? _initialEmoticon;
  late bool _initialIsArchived;
  late int _initialMood;
  late int _initialEnergy;

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
    selectedDate = widget.historia.data;
    selectedEmoticon = widget.historia.emoticon;
    _isArchived = widget.historia.arquivado == 'sim';
    _selectedMood = widget.historia.humor;
    _selectedEnergy = widget.historia.energia;

    // Salva valores iniciais para detectar mudanças
    _initialTitle = widget.historia.titulo;
    _initialDescription = richTextController.document.toPlainText();
    _initialDate = widget.historia.data;
    _initialEmoticon = widget.historia.emoticon;
    _initialIsArchived = widget.historia.arquivado == 'sim';
    _initialMood = widget.historia.humor;
    _initialEnergy = widget.historia.energia;

    // Adiciona listeners para detectar mudanças
    titleController.addListener(_checkForChanges);
    richTextController.addListener(_checkForChanges);

    _loadFotos();
    _loadAudios();
    _loadVideos();
    _loadEmojiTranslation();
    _loadTags();

    _initialized = true; // marca estado como pronto para verificação
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

  /// Carrega as tags associadas a esta história do banco de dados
  Future<void> _loadTags() async {
    final id = widget.historia.id;
    if (id == null) return;
    try {
      final tags = await TagHelper().getTagsByHistoria(id);
      if (mounted) {
        setState(() {
          _selectedTags = tags;
          _initialTags = List.from(tags);
        });
      }
    } catch (e) {
      // Falha ao carregar tags não é crítica; exibe vazio
      debugPrint('Erro ao carregar tags: $e');
    }
  }

  void _checkForChanges() {
    if (!_initialized) {
      return; // não faz nada antes dos controllers estarem prontos
    }

    final currentDescription = richTextController.document.toPlainText();
    final tagsChanged =
        _selectedTags.length != _initialTags.length ||
        _selectedTags.any((t) => !_initialTags.any((i) => i.slug == t.slug));
    final hasChanges =
        titleController.text != _initialTitle ||
        currentDescription != _initialDescription ||
        tagsChanged ||
        selectedDate != _initialDate ||
        selectedEmoticon != _initialEmoticon ||
        _isArchived != _initialIsArchived ||
        _selectedMood != _initialMood ||
        _selectedEnergy != _initialEnergy ||
        _capituloVinculoModo != CapituloVinculoModo.none;

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
        allowMultiple: true,
        onMultipleAudiosSelected: (audiosList) {
          setState(() {
            for (final audioData in audiosList) {
              audios.add(audioData);
              audioIds.add(0); // 0 indica novo áudio
            }
            _checkForChanges();
          });
        },
      ),
    );
  }

  // método público para permitir testes e reuso, similar a removeFoto
  Future<void> removeAudio(int index) async {
    if (index < audioIds.length) {
      final id = audioIds[index];
      if (id != 0) {
        await HistoriaAudioHelper().deleteAudio(id);
      }
    }

    void doRemove() {
      audios.removeAt(index);
      if (index < audioIds.length) {
        audioIds.removeAt(index);
      }
      _checkForChanges();
    }

    if (mounted) {
      setState(doRemove);
    } else {
      doRemove();
    }
  }

  void _removeAudio(int index) async {
    // manter privado para uso interno em widgets
    await removeAudio(index);
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      builder: (context) => VideoRecorderWidget(
        allowMultiple: true,
        onMultipleVideosSelected: (videosList) {
          setState(() {
            for (final videoData in videosList) {
              videos.add({
                'video': videoData['video'],
                'thumbnail': null,
                'duration': videoData['duration'],
              });
              videoIds.add(0); // 0 indica novo vídeo
            }
            _checkForChanges();
          });
        },
      ),
    );
  }

  // método público testável para vídeo, adotando mesma lógica de fotos
  Future<void> removeVideo(int index) async {
    if (index < videoIds.length) {
      final id = videoIds[index];
      if (id != 0) {
        final videoPath = videos[index]['videoPath'] as String;
        await HistoriaVideoHelper().deleteVideo(id, videoPath);
      }
    }

    void doRemove() {
      videos.removeAt(index);
      if (index < videoIds.length) {
        videoIds.removeAt(index);
      }
      _checkForChanges();
    }

    if (mounted) {
      setState(doRemove);
    } else {
      doRemove();
    }
  }

  void _removeVideo(int index) async {
    await removeVideo(index);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
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

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => ImagePickerWidget(
        allowMultiple: true,
        onMultipleImagesPicked: (imagesList) {
          setState(() {
            // Sempre atualizamos a lista de ids em paralelo com as fotos.
            // Um novo índice recebe 0 para indicar que ainda não existe no
            // banco de dados. Isso evita divergência entre os arrays e
            // previne um RangeError durante o _save().
            fotos.addAll(imagesList);
            fotoIds.addAll(List.filled(imagesList.length, 0));
            _checkForChanges();
          });
        },
      ),
    );
  }

  // torna público para permitir testes e reuso
  // garantimos que o método não lance se o State ainda não estiver montado,
  // pois testes que criam o State manualmente não o inserem na árvore.
  Future<void> removeFoto(int index) async {
    // Se a foto tiver um id existente, removemos imediatamente do banco e
    // do sistema de arquivos. Isto mantém o comportamento de áudio/vídeo e
    // evita que fotos "fantasmas" reapareçam após salvar.
    if (index < fotoIds.length) {
      final id = fotoIds[index];
      if (id != 0) {
        await HistoriaFotoHelper().deleteFoto(id);
      }
    }

    void doRemove() {
      fotos.removeAt(index);
      if (index < fotoIds.length) {
        fotoIds.removeAt(index);
      }
      _checkForChanges();
    }

    if (mounted) {
      setState(doRemove);
    } else {
      doRemove();
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

  Future<bool> _save({bool navigateAfterSave = true}) async {
    final l10n = AppLocalizations.of(context)!;
    final capituloValidationMessage = _validateCapituloConfig(l10n);
    if (capituloValidationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(capituloValidationMessage)));
      return false;
    }

    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': RichTextHelper.controllerToJson(richTextController),
        'tag':
            null, // campo legado mantido para compatibilidade; usar historia_tags
        'emoticon': selectedEmoticon,
        'data': selectedDate.toIso8601String(),
        'data_update': DateTime.now().toIso8601String(),
        'arquivado': _isArchived ? 'sim' : null,
        'backed_up': 0,
        'humor': _selectedMood,
        'energia': _selectedEnergy,
      },
      where: 'id = ?',
      whereArgs: [widget.historia.id],
    );

    // Salva/atualiza as tags no sistema de relações
    if (widget.historia.id != null) {
      await TagHelper().setTagsForHistoria(
        widget.historia.id!,
        _selectedTags,
        db,
      );
    }

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

    // Salva novas fotos. A verificação abaixo trata qualquer
    // inconsistência de comprimentos entre `fotos` e `fotoIds` – mesmo que a
    // lista de ids esteja menor ou ausente, presumimos que são novas.
    for (int i = 0; i < fotos.length; i++) {
      final id = i < fotoIds.length ? fotoIds[i] : 0;
      if (id == 0) {
        await HistoriaFotoHelper().insertFotoFromBytes(
          historiaId: widget.historia.id ?? 0,
          fotoBytes: fotos[i],
        );
      }
    }

    // Salva novos áudios – tornamos o loop robusto caso as listas estejam
    // fora de sincronia.
    for (int i = 0; i < audios.length; i++) {
      final id = i < audioIds.length ? audioIds[i] : 0;
      if (id == 0) {
        await HistoriaAudioHelper().insertAudioFromBytes(
          historiaId: widget.historia.id ?? 0,
          audioBytes: audios[i]['audio'],
          duracao: audios[i]['duration'],
        );
      }
    }

    // Salva novos vídeos com checagem de segurança semelhante.
    for (int i = 0; i < videos.length; i++) {
      final id = i < videoIds.length ? videoIds[i] : 0;
      if (id == 0) {
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

    await _aplicarVinculoDeCapituloAoSalvar();

    if (!mounted) return false;
    if (navigateAfterSave) Navigator.pop(context, true);
    return true;
  }

  String? _validateCapituloConfig(AppLocalizations l10n) {
    final capituloSaveService = CapituloSaveService();
    return capituloSaveService.validateCapituloConfig(
      modo: _capituloVinculoModo,
      l10n: l10n,
      capituloId: _capituloSelecionadoId,
      novoCapituloTitulo: _novoCapituloTitulo,
      novoCapituloEntradasCount: _novoCapituloEntradasRelacionadas.length,
    );
  }

  Future<void> _aplicarVinculoDeCapituloAoSalvar() async {
    final historiaId = widget.historia.id;
    if (historiaId == null ||
        _capituloVinculoModo == CapituloVinculoModo.none) {
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) return;

    final capituloSaveService = CapituloSaveService();
    await capituloSaveService.applyCapituloLinkage(
      modo: _capituloVinculoModo,
      historiaId: historiaId,
      userId: userId,
      capituloId: _capituloSelecionadoId,
      novoCapituloTitulo: _novoCapituloTitulo,
      novoCapituloEntradasRelacionadas: _novoCapituloEntradasRelacionadas
          .toList(),
      selectedDate: selectedDate,
    );
  }

  Future<void> _abrirConfiguracaoCapitulo() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final capitulos = await _capituloHelper.getCapitulosResumoByUser(userId);
    final entradas = await _capituloHelper.listEntradasElegiveisComTags(userId);
    if (!mounted) return;

    var draftModo = _capituloVinculoModo;
    int? draftCapituloId = _capituloSelecionadoId;
    var draftNovoTitulo = _novoCapituloTitulo;
    final draftRelacionadas = <int>{..._novoCapituloEntradasRelacionadas};
    var draftBuscaEntradas = '';

    final entradasDisponiveis = entradas
        .where((e) => e.historia.id != widget.historia.id)
        .toList(growable: false);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final buscaNormalizada = draftBuscaEntradas.trim().toLowerCase();
            final entradasFiltradas = entradasDisponiveis
                .where((e) {
                  if (buscaNormalizada.isEmpty) {
                    return true;
                  }

                  final tituloNormalizado = e.historia.titulo.toLowerCase();
                  final dataFormatada = DateFormat(
                    'dd/MM/yyyy',
                    l10n.localeName,
                  ).format(e.historia.data).toLowerCase();
                  // Inclui busca por tags (novo sistema) para consistência
                  // com a tela de pesquisa
                  final tagsNormalizadas = e.tagNomes.toLowerCase();

                  return tituloNormalizado.contains(buscaNormalizada) ||
                      dataFormatada.contains(buscaNormalizada) ||
                      tagsNormalizadas.contains(buscaNormalizada);
                })
                .toList(growable: false);

            return AlertDialog(
              title: Text(l10n.chapterLinkDialogTitle),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                                  (
                                    mode: CapituloVinculoModo.none,
                                    label: l10n.chapterLinkModeNone,
                                  ),
                                  (
                                    mode: CapituloVinculoModo.existing,
                                    label: l10n.chapterLinkModeExisting,
                                  ),
                                  (
                                    mode: CapituloVinculoModo.newChapter,
                                    label: l10n.chapterLinkModeNew,
                                  ),
                                ]
                                .map((item) {
                                  return ChoiceChip(
                                    label: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 180,
                                      ),
                                      child: Text(item.label, softWrap: true),
                                    ),
                                    selected: draftModo == item.mode,
                                    onSelected: (selected) {
                                      if (!selected) return;
                                      setDialogState(() {
                                        draftModo = item.mode;
                                      });
                                    },
                                  );
                                })
                                .toList(growable: false),
                      ),
                      const SizedBox(height: 14),
                      if (draftModo == CapituloVinculoModo.existing)
                        DropdownButtonFormField<int>(
                          initialValue: draftCapituloId,
                          decoration: InputDecoration(
                            labelText: l10n.chapterSelectExistingLabel,
                          ),
                          items: capitulos
                              .map(
                                (item) => DropdownMenuItem<int>(
                                  value: item.capitulo.id,
                                  child: Text(item.capitulo.titulo),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setDialogState(() {
                              draftCapituloId = value;
                            });
                          },
                        ),
                      if (draftModo == CapituloVinculoModo.newChapter) ...[
                        TextFormField(
                          initialValue: draftNovoTitulo,
                          decoration: InputDecoration(
                            labelText: l10n.chapterTitle,
                            hintText: l10n.chapterTitleHint,
                          ),
                          onChanged: (value) {
                            draftNovoTitulo = value;
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.chapterSelectEntries,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: l10n.search,
                            hintText: l10n.searchHintText,
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              draftBuscaEntradas = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 260),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: entradasFiltradas.length,
                            itemBuilder: (context, index) {
                              final entrada = entradasFiltradas[index].historia;
                              final entradaId = entrada.id;
                              if (entradaId == null) {
                                return const SizedBox.shrink();
                              }

                              final checked = draftRelacionadas.contains(
                                entradaId,
                              );
                              return CheckboxListTile(
                                value: checked,
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      draftRelacionadas.add(entradaId);
                                    } else {
                                      draftRelacionadas.remove(entradaId);
                                    }
                                  });
                                },
                                title: Text(entrada.titulo),
                                subtitle: Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                    l10n.localeName,
                                  ).format(entrada.data),
                                ),
                              );
                            },
                          ),
                        ),
                        if (entradasFiltradas.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.noStoriesHere,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          l10n.chapterMinimumRelatedWithCurrent,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) return;

    setState(() {
      _capituloVinculoModo = draftModo;
      _capituloSelecionadoId = draftCapituloId;
      _novoCapituloTitulo = draftNovoTitulo.trim();
      _novoCapituloEntradasRelacionadas = draftRelacionadas;
    });
    _checkForChanges();
  }

  String _resumoVinculoCapitulo(AppLocalizations l10n) {
    if (_capituloVinculoModo == CapituloVinculoModo.none) {
      return l10n.chapterLinkSummaryNone;
    }

    if (_capituloVinculoModo == CapituloVinculoModo.existing) {
      return l10n.chapterLinkSummaryExisting;
    }

    return l10n.chapterLinkSummaryNew(
      _novoCapituloEntradasRelacionadas.length + 1,
    );
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
        transitionDuration: AppDurations.routeTransition,
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
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      const typeGroup = XTypeGroup(extensions: ['txt']);
      final files = await openFiles(acceptedTypeGroups: [typeGroup]);

      // Reseta a flag após retornar do app externo (independente de sucesso ou cancelamento)
      pinProvider.isPickingExternalMedia = false;

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
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorLoadingFile(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _selectEmoji() async {
    final Emoji? result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
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

  Future<void> _exportToPdf() async {
    // ignore: use_build_context_synchronously
    final loc = AppLocalizations.of(context)!;
    // Validação mínima
    final plainText = richTextController.document.toPlainText().trim();
    if (titleController.text.trim().isEmpty || plainText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.exportPdfFieldsRequired)));
      return;
    }

    // Gera o PDF e mostra o preview com opções Cancel/Compartilhar/Salvar
    final titleText = titleController.text.trim().isEmpty
        ? loc.untitled
        : _capitalizeText(titleController.text.trim());
    final pdfBytes = await PdfExportService.generatePdfFromHistoria(
      title: titleText,
      content: plainText,
      date: selectedDate,
      images: fotos,
      tags: _selectedTags.isEmpty
          ? null
          : _selectedTags.map((t) => t.nome).join(', '),
      emoticon: selectedEmoticon,
      locale: loc.localeName,
    );

    final filename =
        'historia_${widget.historia.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          initialPdfBytes: pdfBytes,
          onGenerate: (highQuality) => PdfExportService.generatePdfFromHistoria(
            title: titleText,
            content: plainText,
            date: selectedDate,
            images: fotos,
            tags: _selectedTags.isEmpty
                ? null
                : _selectedTags.map((t) => t.nome).join(', '),
            emoticon: selectedEmoticon,
            highQuality: highQuality,
            locale: loc.localeName,
          ),
          filename: filename,
          title: AppLocalizations.of(
            context,
          )!.previewTitle(titleController.text.trim()),
          onSave: () async {
            final ok = await _save(navigateAfterSave: false);
            return ok;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.removeListener(_checkForChanges);
    richTextController.removeListener(_checkForChanges);
    titleController.dispose();
    richTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(loc.localeName).add_Hm();
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
            title: Text(loc.discardChangesTitle),
            content: Text(loc.discardChangesPrompt),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('discard'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(loc.discard),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('save'),
                child: Text(loc.save),
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
          title: Text(loc.editStory),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: loc.exportPdf,
              onPressed: () async {
                await _exportToPdf();
              },
            ),
            TextButton(
              onPressed: () async => await _save(),
              child: Text(
                loc.save,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                    // Header: Date (expandida) e botão de calendário
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
                          tooltip: loc.changeDateTooltip,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    CustomTextField(
                      controller: titleController,
                      label: loc.storyTitleLabel,
                      hintText: loc.storyTitleHint,
                      style: theme.textTheme.bodyLarge,
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    RichTextEditorWidget(
                      key: const Key('description_field'),
                      controller: richTextController,
                      hintText: loc.descriptionHint,
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
                    Builder(
                      builder: (context) {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        return TagInputWidget(
                          userId: auth.user?.id ?? '',
                          initialTags: _selectedTags,
                          onTagsChanged: (tags) {
                            setState(() {
                              _selectedTags = tags;
                              _checkForChanges();
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<PremiumProvider>(
                      builder: (context, premium, _) {
                        if (!premium.canUseChapters) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.workspace_premium),
                              title: Text(loc.chaptersTitle),
                              subtitle: Text(loc.chaptersPremiumRequired),
                            ),
                          );
                        }

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.auto_stories_outlined),
                            title: Text(loc.chapterLinkSectionTitle),
                            subtitle: Text(_resumoVinculoCapitulo(loc)),
                            trailing: TextButton(
                              onPressed: _abrirConfiguracaoCapitulo,
                              child: Text(loc.chapterLinkConfigure),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Archive Switch
                    SwitchListTile(
                      title: Text(loc.archivedStateLabel),
                      subtitle: Text(loc.archiveSubtitle),
                      value: _isArchived,
                      onChanged: (value) {
                        setState(() {
                          _isArchived = value;
                          _checkForChanges();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Humor (como você se sentiu)
                    const SizedBox(height: 16),
                    Text(loc.moodQuestion, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    MoodSelector(
                      value: _selectedMood,
                      onChanged: (v) => setState(() {
                        _selectedMood = v;
                        _checkForChanges();
                      }),
                    ),

                    // Energia
                    const SizedBox(height: 16),
                    Text(loc.energyQuestion, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    EnergySelector(
                      value: _selectedEnergy,
                      onChanged: (v) => setState(() {
                        _selectedEnergy = v;
                        _checkForChanges();
                      }),
                    ),

                    // Emoticon (agora abaixo do Archive Switch) - ocupa largura disponível
                    if (selectedEmoticon != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Chip(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                avatar: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _convertLegacyEmoticon(
                                          selectedEmoticon!,
                                        ),
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                ),
                                label: const SizedBox.shrink(),
                                onDeleted: () {
                                  setState(() {
                                    selectedEmoticon = null;
                                    selectedEmojiTranslation = null;
                                    _checkForChanges();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

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
                                    onPressed: () async => await removeFoto(i),
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
                      tooltip: loc.importTxtTooltip,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: const Icon(Icons.open_in_full),
                      onPressed: _expandDescriptionEditor,
                      tooltip: loc.expandTooltip,
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
