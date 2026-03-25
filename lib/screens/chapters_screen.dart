import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/capitulo_helper.dart';
import '../models/capitulo.dart';
import '../models/capitulo_sugestao.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/capitulo_sugestao_service.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final CapituloHelper _capituloHelper = CapituloHelper();
  final CapituloSugestaoService _sugestaoService = CapituloSugestaoService();

  bool _isLoading = true;
  List<CapituloResumo> _capitulos = const [];
  List<CapituloSugestao> _sugestoes = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final premium = Provider.of<PremiumProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final capitulos = await _capituloHelper.getCapitulosResumoByUser(userId);
    final sugestoes = premium.isPremium
        ? await _sugestaoService.sugerirCapitulos(userId)
        : const <CapituloSugestao>[];

    if (!mounted) return;
    setState(() {
      _capitulos = capitulos;
      _sugestoes = sugestoes;
      _isLoading = false;
    });
  }

  Future<void> _aceitarSugestao(CapituloSugestao sugestao) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final capitulo = Capitulo(
      userId: userId,
      titulo: sugestao.tituloSugerido,
      descricao: null,
      dataInicio: sugestao.dataInicio,
      dataFim: sugestao.dataFim,
      scoreConfianca: sugestao.scoreConfianca,
      criadoAutomaticamente: true,
    );

    await _capituloHelper.insertCapituloWithEntradas(
      capitulo,
      sugestao.entradaIds,
    );
    if (!mounted) return;

    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterCreated)),
    );

    await _loadData();
  }

  Future<void> _ignorarSugestao(CapituloSugestao sugestao) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    await _capituloHelper.ignoreSuggestion(
      userId: userId,
      fingerprint: sugestao.fingerprint,
    );

    if (!mounted) return;
    await _loadData();
  }

  Future<void> _criarCapituloManual() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final entradas = await _capituloHelper.listEntradasElegiveis(userId);
    if (!mounted) return;

    final selected = <int>{};
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = AppLocalizations.of(context)!;

            return AlertDialog(
              title: Text(l10n.chapterCreateManual),
              content: SizedBox(
                width: 580,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.chapterTitle,
                          hintText: l10n.chapterTitleHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.chapterDescription,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.chapterSelectEntries,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: entradas.length,
                          itemBuilder: (context, index) {
                            final entry = entradas[index];
                            final id = entry.id;
                            if (id == null) return const SizedBox.shrink();
                            final checked = selected.contains(id);

                            return CheckboxListTile(
                              value: checked,
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selected.add(id);
                                  } else {
                                    selected.remove(id);
                                  }
                                });
                              },
                              title: Text(entry.titulo),
                              subtitle: Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                  l10n.localeName,
                                ).format(entry.data),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.chapterMinimumEntries,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
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
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        selected.length < 4) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true) {
      titleController.dispose();
      descriptionController.dispose();
      return;
    }

    final selectedEntries =
        entradas
            .where((entry) => entry.id != null && selected.contains(entry.id))
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));

    if (selectedEntries.length < 4) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.chapterMinimumEntries),
        ),
      );
      titleController.dispose();
      descriptionController.dispose();
      return;
    }

    final capitulo = Capitulo(
      userId: userId,
      titulo: titleController.text.trim(),
      descricao: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      dataInicio: selectedEntries.first.data,
      dataFim: selectedEntries.last.data,
      criadoAutomaticamente: false,
    );

    await _capituloHelper.insertCapituloWithEntradas(
      capitulo,
      selectedEntries.map((entry) => entry.id!).toList(growable: false),
    );

    titleController.dispose();
    descriptionController.dispose();

    if (!mounted) return;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterCreated)),
    );

    await _loadData();
  }

  Future<void> _abrirEdicaoCapitulo(CapituloResumo resumo) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final entradasAtuais = await _capituloHelper.getEntradasByCapitulo(
      resumo.capitulo.id!,
    );
    final todasEntradas = await _capituloHelper.listEntradasElegiveis(userId);
    if (!mounted) return;

    final draftEntradaIds = <int>{
      for (final e in entradasAtuais)
        if (e.id != null) e.id!,
    };

    final resultado = await showDialog<_EditCapituloResult?>(
      context: context,
      builder: (dialogContext) {
        return _EditCapituloDialog(
          capitulo: resumo.capitulo,
          todasEntradas: todasEntradas,
          draftEntradaIds: draftEntradaIds,
        );
      },
    );

    if (resultado == null) return;
    if (!mounted) return;

    // Validar e preparar histórias selecionadas
    final selectedEntries =
        todasEntradas
            .where(
              (entry) => entry.id != null && draftEntradaIds.contains(entry.id),
            )
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));

    if (selectedEntries.length < 4) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.chapterMinimumEntries),
        ),
      );
      return;
    }

    final capituloAtualizado = Capitulo(
      id: resumo.capitulo.id,
      userId: userId,
      titulo: resultado.titulo,
      descricao: resultado.descricao,
      dataInicio: selectedEntries.first.data,
      dataFim: selectedEntries.last.data,
      criadoAutomaticamente: resumo.capitulo.criadoAutomaticamente,
    );

    await _capituloHelper.updateCapituloWithEntradas(
      capituloAtualizado,
      selectedEntries.map((entry) => entry.id!).toList(growable: false),
    );

    if (!mounted) return;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterUpdated)),
    );

    await _loadData();
  }

  Future<void> _abrirDetalhesCapitulo(CapituloResumo resumo) async {
    final l10n = AppLocalizations.of(context)!;
    final entradas = await _capituloHelper.getEntradasByCapitulo(
      resumo.capitulo.id!,
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(resumo.capitulo.titulo),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chapterPeriod(
                    DateFormat(
                      'dd/MM/yyyy',
                      l10n.localeName,
                    ).format(resumo.capitulo.dataInicio),
                    DateFormat(
                      'dd/MM/yyyy',
                      l10n.localeName,
                    ).format(resumo.capitulo.dataFim),
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.chapterEntriesCount(resumo.totalEntradas)),
                const SizedBox(height: 6),
                Text(
                  l10n.chapterAverageMood(resumo.humorMedio.toStringAsFixed(1)),
                ),
                if (resumo.topTags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.chapterTopTags(
                      resumo.topTags.map((tag) => '#$tag').join(' '),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: entradas.length,
                    itemBuilder: (context, index) {
                      final entry = entradas[index];
                      return ListTile(
                        dense: true,
                        title: Text(entry.titulo),
                        subtitle: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                            l10n.localeName,
                          ).format(entry.data),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _abrirEdicaoCapitulo(resumo);
              },
              child: Text(l10n.edit),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final premium = context.watch<PremiumProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chaptersTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!premium.isPremium)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l10n.chaptersPremiumRequired)),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    if (_sugestoes.isNotEmpty) ...[
                      Text(
                        l10n.chapterSuggestions,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ..._sugestoes.map(
                        (sugestao) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sugestao.tituloSugerido,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.chapterPeriod(
                                    DateFormat(
                                      'dd/MM',
                                      l10n.localeName,
                                    ).format(sugestao.dataInicio),
                                    DateFormat(
                                      'dd/MM',
                                      l10n.localeName,
                                    ).format(sugestao.dataFim),
                                  ),
                                ),
                                Text(
                                  l10n.chapterEntriesCount(
                                    sugestao.entradas.length,
                                  ),
                                ),
                                if (sugestao.topTags.isNotEmpty)
                                  Text(
                                    l10n.chapterTopTags(
                                      sugestao.topTags
                                          .map((tag) => '#$tag')
                                          .join(' '),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    FilledButton(
                                      onPressed: () =>
                                          _aceitarSugestao(sugestao),
                                      child: Text(
                                        l10n.chapterCreateFromSuggestion,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () =>
                                          _ignorarSugestao(sugestao),
                                      child: Text(l10n.chapterIgnoreLabel),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.chaptersTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _criarCapituloManual,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.chapterCreateManual),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_capitulos.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.chapterNoItems,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ..._capitulos.map(
                      (resumo) => Card(
                        child: ListTile(
                          title: Text(resumo.capitulo.titulo),
                          subtitle: Text(
                            l10n.chapterEntriesAndMood(
                              resumo.totalEntradas,
                              resumo.humorMedio.toStringAsFixed(1),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _abrirDetalhesCapitulo(resumo),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// Classe auxiliar para retornar dados editados do dialog
class _EditCapituloResult {
  final String titulo;
  final String? descricao;

  _EditCapituloResult({required this.titulo, required this.descricao});
}

// Dialog interno para edição de capítulo
class _EditCapituloDialog extends StatefulWidget {
  final Capitulo capitulo;
  final List<Historia> todasEntradas;
  final Set<int> draftEntradaIds;

  const _EditCapituloDialog({
    required this.capitulo,
    required this.todasEntradas,
    required this.draftEntradaIds,
  });

  @override
  State<_EditCapituloDialog> createState() => _EditCapituloDialogState();
}

class _EditCapituloDialogState extends State<_EditCapituloDialog> {
  late TextEditingController titleController;
  late TextEditingController descController;
  var _buscaEntradas = '';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.capitulo.titulo);
    descController = TextEditingController(
      text: widget.capitulo.descricao ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        final buscaNormalizada = _buscaEntradas.trim().toLowerCase();
        final entradasFiltradas = widget.todasEntradas
            .where((entrada) {
              if (buscaNormalizada.isEmpty) return true;

              final tituloNormalizado = entrada.titulo.toLowerCase();
              final dataFormatada = DateFormat(
                'dd/MM/yyyy',
                l10n.localeName,
              ).format(entrada.data).toLowerCase();

              return tituloNormalizado.contains(buscaNormalizada) ||
                  dataFormatada.contains(buscaNormalizada);
            })
            .toList(growable: false);

        return AlertDialog(
          title: Text(l10n.chapterEditTitle),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chapterTitle,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: l10n.chapterTitleHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chapterDescription,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.chapterDescriptionHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chapterSelectEntries,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.search,
                      hintText: l10n.searchHintText,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        _buscaEntradas = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: entradasFiltradas.length,
                      itemBuilder: (context, index) {
                        final entrada = entradasFiltradas[index];
                        final entradaId = entrada.id;
                        if (entradaId == null) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = widget.draftEntradaIds.contains(
                          entradaId,
                        );
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                widget.draftEntradaIds.add(entradaId);
                              } else {
                                widget.draftEntradaIds.remove(entradaId);
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    l10n.chapterMinimumEntries,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    widget.draftEntradaIds.length < 4) {
                  return;
                }
                Navigator.of(context).pop(
                  _EditCapituloResult(
                    titulo: titleController.text.trim(),
                    descricao: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
