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
import '../helpers/notification_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/tag.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/capitulo_save_service.dart';
import '../services/emoji_service.dart';
import '../services/pdf_export_service.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
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

class CreateHistoriaScreen extends StatefulWidget {
  const CreateHistoriaScreen({super.key});

  @override
  State<CreateHistoriaScreen> createState() => _CreateHistoriaScreenState();
}

class _CreateHistoriaScreenState extends State<CreateHistoriaScreen> {
  final CapituloHelper _capituloHelper = CapituloHelper();
  final titleController = TextEditingController();
  late final QuillController richTextController;
  final List<Uint8List> fotos = [];
  final List<Map<String, dynamic>> audios =
      []; // {audio: Uint8List, duration: int}
  final List<Map<String, dynamic>> videos =
      []; // {video: Uint8List, thumbnail: Uint8List?, duration: int}
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  String? selectedEmoticon;
  String? selectedEmojiTranslation;
  int _selectedMood = 3; // padrão: Neutro
  int _selectedEnergy = 2; // padrão: Normal

  // Lista de tags selecionadas
  List<Tag> _selectedTags = [];

  // Configuração opcional de vínculo com capítulos durante o salvamento.
  CapituloVinculoModo _capituloVinculoModo = CapituloVinculoModo.none;
  int? _capituloSelecionadoId;
  String _novoCapituloTitulo = '';
  Set<int> _novoCapituloEntradasRelacionadas = <int>{};

  // Controle de alterações não salvas
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller do Rich Text
    richTextController = QuillController.basic();
    // Adiciona listeners para detectar mudanças
    titleController.addListener(_checkForChanges);
    richTextController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    // Na tela de criação, qualquer coisa digitada é considerada mudança
    final plainText = richTextController.document.toPlainText().trim();
    final hasChanges =
        titleController.text.isNotEmpty ||
        plainText.isNotEmpty ||
        _selectedTags.isNotEmpty ||
        fotos.isNotEmpty ||
        audios.isNotEmpty ||
        videos.isNotEmpty ||
        selectedEmoticon != null ||
        _selectedMood != 3 ||
        _selectedEnergy != 2 ||
        _capituloVinculoModo != CapituloVinculoModo.none;

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_checkForChanges);
    richTextController.removeListener(_checkForChanges);
    titleController.dispose();
    richTextController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => ImagePickerWidget(
        allowMultiple: true,
        onMultipleImagesPicked: (imagesList) {
          setState(() {
            fotos.addAll(imagesList);
            _checkForChanges();
          });
        },
      ),
    );
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
        allowMultiple: true,
        onMultipleAudiosSelected: (audiosList) {
          setState(() {
            audios.addAll(audiosList);
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
        allowMultiple: true,
        onMultipleVideosSelected: (videosList) {
          setState(() {
            for (final videoData in videosList) {
              videos.add({
                'video': videoData['video'],
                'thumbnail': null,
                'duration': videoData['duration'],
              });
            }
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
        });
      }
    }
  }

  Future<void> _showNotificationDialog(int historiaId) async {
    final plainText = richTextController.document.toPlainText();
    await NotificationHelper().showNotificationDialog(
      context,
      historiaId,
      selectedDate,
      titleController.text,
      plainText,
    );
  }

  Future<int?> _saveHistoria({bool navigateAfterSave = true}) async {
    final l10n = AppLocalizations.of(context)!;
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.titleRequired)));
      return null;
    }

    final capituloValidationMessage = _validateCapituloConfig(l10n);
    if (capituloValidationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(capituloValidationMessage)));
      return null;
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

      // Converte o conteúdo do Rich Text para JSON
      final richTextJson = RichTextHelper.controllerToJson(richTextController);
      final plainText = richTextController.document.toPlainText().trim();

      // Salva a história (garante arquivado=null e grupo=null para aparecer na Home)
      final historiaId = await db.insert('historia', {
        'user_id': auth.user?.id ?? '',
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': plainText.isEmpty ? null : richTextJson,
        'tag':
            null, // campo legado mantido para compatibilidade; usar historia_tags
        'grupo': null,
        'arquivado': null,
        'emoticon': selectedEmoticon,
        'data': selectedDate.toIso8601String(),
        'data_criacao': DateTime.now().toIso8601String(),
        'data_update': DateTime.now().toIso8601String(),
        'humor': _selectedMood,
        'energia': _selectedEnergy,
      });

      // Salva as tags no novo sistema de relações
      if (_selectedTags.isNotEmpty) {
        await TagHelper().setTagsForHistoria(historiaId, _selectedTags, db);
      }

      // Salva as fotos (se houver)
      for (final foto in fotos) {
        await HistoriaFotoHelper().insertFotoFromBytes(
          historiaId: historiaId,
          fotoBytes: foto,
        );
      }

      // Salva os áudios (se houver)
      for (final audioData in audios) {
        await HistoriaAudioHelper().insertAudioFromBytes(
          historiaId: historiaId,
          audioBytes: audioData['audio'],
          duracao: audioData['duration'],
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

      await _aplicarVinculoDeCapituloAoSalvar(
        historiaId: historiaId,
        userId: auth.user?.id ?? '',
      );

      // Se a data permitir notificação (pelo menos 2 horas à frente), perguntar sobre notificação
      if (NotificationHelper().shouldScheduleNotification(selectedDate)) {
        await _showNotificationDialog(historiaId);
      }

      // Atualiza a tela inicial
      if (!mounted) return historiaId;
      refreshProvider.refresh();

      // Navega para a tela inicial se solicitado
      if (navigateAfterSave) {
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }

      return historiaId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSavingStory(e.toString()),
            ),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportToPdf() async {
    // Valida título e descrição
    final plainText = richTextController.document.toPlainText().trim();
    if (titleController.text.trim().isEmpty || plainText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.exportPdfFieldsRequired),
        ),
      );
      return;
    }

    // Pergunta ao usuário se quer salvar direto ou só preview
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.exportHistory),
          content: Text(loc.exportHistoryPrompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'preview'),
              child: Text(loc.preview),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: Text(loc.saveAndExport),
            ),
          ],
        );
      },
    );
    if (choice == null || choice == 'cancel') return;

    setState(() {
      _isLoading = true;
    });
    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return; // garantimos contexto
      final loc = AppLocalizations.of(context)!;
      final titleText = titleController.text.trim().isEmpty
          ? loc.untitled
          : _capitalizeText(titleController.text.trim());

      // Se escolheu salvar e exportar, salva primeiro sem navegar
      if (choice == 'save') {
        final savedId = await _saveHistoria(navigateAfterSave: false);
        if (savedId == null) return; // erro ao salvar
      }

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

      final filename = 'historia_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Mostrar preview antes de qualquer ação (cancelar/compartilhar/salvar)
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            initialPdfBytes: pdfBytes,
            onGenerate: (highQuality) =>
                PdfExportService.generatePdfFromHistoria(
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
            title: AppLocalizations.of(context)!.previewTitle(titleText),
            onSave: () async {
              // Salva sem navegar para a Home
              final savedId = await _saveHistoria(navigateAfterSave: false);
              return savedId != null;
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.exportPdfError(e.toString()),
            ),
          ),
        );
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
              // child includes the AppBar so it will animate in parallel
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
        // Atualiza o Rich Text Controller com o conteúdo do arquivo
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

  Future<void> _aplicarVinculoDeCapituloAoSalvar({
    required int historiaId,
    required String userId,
  }) async {
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

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final buscaNormalizada = draftBuscaEntradas.trim().toLowerCase();
            final entradasFiltradas = entradas
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(loc.localeName).add_Hm();
    final theme = Theme.of(context);

    // Determina a cor de destaque para textos conforme o tema ativo
    final Color labelColor = AppColors.labelColor(context);

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
            title: Text(loc.discardStoryTitle),
            content: Text(loc.unsavedStoryPrompt),
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
          await _saveHistoria();
        } else if (dialogResult == 'discard') {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.newStory,
            style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: loc.exportPdf,
              onPressed: _isLoading ? null : _exportToPdf,
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
                child: Text(
                  loc.save,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
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
                            color: labelColor,
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
                        if (selectedEmoticon != null)
                          Chip(
                            label: Text(
                              selectedEmoticon!,
                              style: const TextStyle(fontSize: 20),
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
                    CustomTextField(
                      controller: titleController,
                      label: loc.storyTitleLabel,
                      hintText: loc.storyTitleHint,
                      style: theme.textTheme.headlineSmall,
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rich Text Description
                    Text(
                      loc.descriptionLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              titleTextStyle: theme.textTheme.bodyLarge
                                  ?.copyWith(
                                    color: labelColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                              subtitleTextStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: labelColor),
                            ),
                          );
                        }

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.auto_stories_outlined),
                            title: Text(loc.chapterLinkSectionTitle),
                            subtitle: Text(_resumoVinculoCapitulo(loc)),
                            titleTextStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: labelColor,
                              fontWeight: FontWeight.w500,
                            ),
                            subtitleTextStyle: theme.textTheme.bodyMedium
                                ?.copyWith(color: labelColor),
                            trailing: TextButton(
                              onPressed: _abrirConfiguracaoCapitulo,
                              child: Text(loc.chapterLinkConfigure),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Humor (como você se sentiu)
                    Text(
                      loc.moodQuestion,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: labelColor,
                      ),
                    ),
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
                    Text(
                      loc.energyQuestion,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EnergySelector(
                      value: _selectedEnergy,
                      onChanged: (v) => setState(() {
                        _selectedEnergy = v;
                        _checkForChanges();
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Media Previews
                    if (fotos.isNotEmpty) ...[
                      Text(
                        loc.photosSection,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: labelColor,
                        ),
                      ),
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
                      Text(
                        loc.audiosSection,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: labelColor,
                        ),
                      ),
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
                      Text(
                        loc.videosSection,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: labelColor,
                        ),
                      ),
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
