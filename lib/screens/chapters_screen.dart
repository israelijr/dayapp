import 'package:dayapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/capitulo_helper.dart';
import '../helpers/chapter_filter_helper.dart';
import '../models/capitulo.dart';
import '../models/capitulo_sugestao.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../screens/edit_historia_screen.dart';
import '../services/capitulo_sugestao_service.dart';
import '../widgets/compact_historia_card.dart';

// ---------------------------------------------------------------------------
// Helpers visuais compartilhados entre as telas de capítulos
// ---------------------------------------------------------------------------

Widget _buildMetaChip({
  required BuildContext context,
  required IconData icon,
  required String label,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMoodBar(BuildContext context, double mood) {
  final colorScheme = Theme.of(context).colorScheme;
  final fraction = ((mood - 1) / 4).clamp(0.0, 1.0);

  final Color barColor;
  if (fraction < 0.33) {
    barColor = colorScheme.error;
  } else if (fraction < 0.66) {
    barColor = colorScheme.tertiary;
  } else {
    barColor = colorScheme.primary;
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.favorite_border,
        size: 14,
        color: colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      SizedBox(
        width: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ),
    ],
  );
}

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
  String _chapterSearchQuery = '';
  ChapterOriginFilter _chapterOriginFilter = ChapterOriginFilter.all;
  ChapterSortOption _chapterSortOption = ChapterSortOption.newestPeriod;

  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final resultado = await showDialog<_CreateCapituloResult?>(
      context: context,
      builder: (dialogContext) {
        return _CreateCapituloDialog(entradas: entradas);
      },
    );

    if (resultado == null) return;

    final selectedEntries =
        entradas
            .where(
              (entry) =>
                  entry.id != null && resultado.entradaIds.contains(entry.id),
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

    final capitulo = Capitulo(
      userId: userId,
      titulo: resultado.titulo,
      descricao: resultado.descricao,
      dataInicio: selectedEntries.first.data,
      dataFim: selectedEntries.last.data,
      criadoAutomaticamente: false,
    );

    await _capituloHelper.insertCapituloWithEntradas(
      capitulo,
      selectedEntries.map((entry) => entry.id!).toList(growable: false),
    );

    if (!mounted) return;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterCreated)),
    );

    await _loadData();
  }

  Future<void> _abrirDetalhesCapitulo(CapituloResumo resumo) async {
    final alterado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _ChapterDetailsScreen(
          resumoInicial: resumo,
          capituloHelper: _capituloHelper,
        ),
      ),
    );

    if (alterado == true) {
      await _loadData();
    }
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$tag',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSuggestionWordChip(BuildContext context, String word) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        word,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, CapituloSugestao sugestao) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final periodo = l10n.chapterPeriod(
      DateFormat('dd/MM', l10n.localeName).format(sugestao.dataInicio),
      DateFormat('dd/MM', l10n.localeName).format(sugestao.dataFim),
    );
    final confidenceLabel = '${(sugestao.scoreConfianca * 100).round()}%';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sugestao.tituloSugerido,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        periodo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetaChip(
                  context: context,
                  icon: Icons.menu_book_outlined,
                  label: l10n.chapterEntriesCount(sugestao.entradas.length),
                ),
                _buildMetaChip(
                  context: context,
                  icon: Icons.verified_outlined,
                  label: confidenceLabel,
                ),
                _buildMetaChip(
                  context: context,
                  icon: Icons.bolt_outlined,
                  label: l10n.chapterCreateFromSuggestion,
                ),
              ],
            ),
            if (sugestao.topTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sugestao.topTags
                    .map((tag) => _buildTagChip(context, tag))
                    .toList(growable: false),
              ),
            ],
            if (sugestao.topPalavras.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sugestao.topPalavras
                    .take(4)
                    .map((word) => _buildSuggestionWordChip(context, word))
                    .toList(growable: false),
              ),
            ],
            if (sugestao.entradas.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...sugestao.entradas
                        .take(3)
                        .map(
                          (entrada) => CompactHistoriaCard(
                            historia: entrada,
                            localeName: l10n.localeName,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            showMood: false,
                          ),
                        ),
                    if (sugestao.entradas.length > 3)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Text(
                          l10n.chapterSuggestionMoreStories(
                            sugestao.entradas.length - 3,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _aceitarSugestao(sugestao),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.chapterCreateFromSuggestion),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _ignorarSugestao(sugestao),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.chapterIgnoreLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapituloCard(BuildContext context, CapituloResumo resumo) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final capitulo = resumo.capitulo;
    final descricao = capitulo.descricao?.trim();
    final periodo = l10n.chapterPeriod(
      DateFormat('dd/MM/yyyy', l10n.localeName).format(capitulo.dataInicio),
      DateFormat('dd/MM/yyyy', l10n.localeName).format(capitulo.dataFim),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirDetalhesCapitulo(resumo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: capitulo.criadoAutomaticamente
                          ? colorScheme.tertiaryContainer
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      capitulo.criadoAutomaticamente
                          ? Icons.auto_awesome
                          : Icons.bookmark_outline,
                      color: capitulo.criadoAutomaticamente
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capitulo.titulo,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          periodo,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (descricao != null && descricao.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetaChip(
                    context: context,
                    icon: Icons.menu_book_outlined,
                    label: l10n.chapterEntriesCount(resumo.totalEntradas),
                  ),
                  const SizedBox(width: 8),
                  _buildMoodBar(context, resumo.humorMedio),
                ],
              ),
              if (resumo.topTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resumo.topTags
                      .map((tag) => _buildTagChip(context, tag))
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesChapterFilter(CapituloResumo resumo) {
    return matchesChapterFilter(
      resumo,
      _chapterSearchQuery,
      _chapterOriginFilter,
    );
  }

  // Menu compacto de ordenação e filtro por origem no AppBar
  Widget _buildSortMenu(BuildContext context, AppLocalizations l10n) {
    String sortLabel(ChapterSortOption opt) => switch (opt) {
      ChapterSortOption.newestPeriod => l10n.chapterSortNewest,
      ChapterSortOption.oldestPeriod => l10n.chapterSortOldest,
      ChapterSortOption.title => l10n.chapterSortTitle,
      ChapterSortOption.stories => l10n.chapterSortStories,
    };

    String filterLabel(ChapterOriginFilter f) => switch (f) {
      ChapterOriginFilter.all => l10n.chapterFilterAll,
      ChapterOriginFilter.automatic => l10n.chapterFilterAutomatic,
      ChapterOriginFilter.manual => l10n.chapterFilterManual,
    };

    final colorScheme = Theme.of(context).colorScheme;
    final hasActiveFilter = _chapterOriginFilter != ChapterOriginFilter.all;

    return PopupMenuButton<Object>(
      tooltip: l10n.chapterSortLabel,
      icon: Badge(
        isLabelVisible: hasActiveFilter,
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.sort),
      ),
      onSelected: (value) {
        if (value is ChapterSortOption) {
          setState(() => _chapterSortOption = value);
        } else if (value is ChapterOriginFilter) {
          setState(() => _chapterOriginFilter = value);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            l10n.chapterSortLabel,
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...ChapterSortOption.values.map(
          (opt) => CheckedPopupMenuItem<Object>(
            value: opt,
            checked: _chapterSortOption == opt,
            child: Text(sortLabel(opt)),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Text(
            l10n.chapterFilterAll,
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...ChapterOriginFilter.values.map(
          (f) => CheckedPopupMenuItem<Object>(
            value: f,
            checked: _chapterOriginFilter == f,
            child: Text(filterLabel(f)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final premium = context.watch<PremiumProvider>();
    final capitulosFiltrados = sortCapitulos(
      _capitulos.where(_matchesChapterFilter).toList(growable: false),
      _chapterSortOption,
    );

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHintText,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _chapterSearchQuery = v),
              )
            : Text(l10n.chaptersTitle),
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.cancel,
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _chapterSearchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.search,
              onPressed: () => setState(() => _showSearch = true),
            ),
          _buildSortMenu(context, l10n),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.chapterCreateManual,
            onPressed: _criarCapituloManual,
          ),
        ],
      ),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._sugestoes.map(
                        (sugestao) => _buildSuggestionCard(context, sugestao),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
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
                  else if (capitulosFiltrados.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.chapterNoSearchResults,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...capitulosFiltrados.map(
                      (resumo) => _buildCapituloCard(context, resumo),
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

class _CreateCapituloResult {
  final String titulo;
  final String? descricao;
  final Set<int> entradaIds;

  _CreateCapituloResult({
    required this.titulo,
    required this.descricao,
    required this.entradaIds,
  });
}

class _CreateCapituloDialog extends StatefulWidget {
  final List<Historia> entradas;

  const _CreateCapituloDialog({required this.entradas});

  @override
  State<_CreateCapituloDialog> createState() => _CreateCapituloDialogState();
}

class _CreateCapituloDialogState extends State<_CreateCapituloDialog> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final Set<int> selected = <int>{};

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StatefulBuilder(
      builder: (context, setDialogState) {
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
                      itemCount: widget.entradas.length,
                      itemBuilder: (context, index) {
                        final entry = widget.entradas[index];
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  _showChapterValidationMessage(
                    context,
                    l10n.chapterTitleRequired,
                  );
                  return;
                }
                if (selected.length < 4) {
                  _showChapterValidationMessage(
                    context,
                    l10n.chapterMinimumEntries,
                  );
                  return;
                }
                Navigator.of(context).pop(
                  _CreateCapituloResult(
                    titulo: titleController.text.trim(),
                    descricao: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    entradaIds: {...selected},
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
                if (titleController.text.trim().isEmpty) {
                  _showChapterValidationMessage(
                    context,
                    l10n.chapterTitleRequired,
                  );
                  return;
                }
                if (widget.draftEntradaIds.length < 4) {
                  _showChapterValidationMessage(
                    context,
                    l10n.chapterMinimumEntries,
                  );
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

void _showChapterValidationMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _ChapterDetailsScreen extends StatefulWidget {
  final CapituloResumo resumoInicial;
  final CapituloHelper capituloHelper;

  const _ChapterDetailsScreen({
    required this.resumoInicial,
    required this.capituloHelper,
  });

  @override
  State<_ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<_ChapterDetailsScreen> {
  late CapituloResumo _resumo;
  List<Historia> _entradas = const [];
  bool _isLoading = true;
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _resumo = widget.resumoInicial;
    _loadChapterData();
  }

  Future<void> _loadChapterData() async {
    setState(() {
      _isLoading = true;
    });

    final entradas = await widget.capituloHelper.getEntradasByCapitulo(
      _resumo.capitulo.id!,
    );
    final resumos = await widget.capituloHelper.getCapitulosResumoByUser(
      _resumo.capitulo.userId,
    );
    final resumoAtualizado = resumos
        .where((item) => item.capitulo.id == _resumo.capitulo.id)
        .cast<CapituloResumo?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (!mounted) return;
    setState(() {
      if (resumoAtualizado != null) {
        _resumo = resumoAtualizado;
      }
      _entradas = entradas;
      _isLoading = false;
    });
  }

  Future<void> _editarCapitulo() async {
    final userId = _resumo.capitulo.userId;
    if (userId.isEmpty) return;

    final todasEntradas = await widget.capituloHelper.listEntradasElegiveis(
      userId,
    );
    if (!mounted) return;

    final draftEntradaIds = <int>{
      for (final e in _entradas)
        if (e.id != null) e.id!,
    };

    final resultado = await showDialog<_EditCapituloResult?>(
      context: context,
      builder: (dialogContext) {
        return _EditCapituloDialog(
          capitulo: _resumo.capitulo,
          todasEntradas: todasEntradas,
          draftEntradaIds: draftEntradaIds,
        );
      },
    );

    if (resultado == null) return;

    final selectedEntries =
        todasEntradas
            .where(
              (entry) => entry.id != null && draftEntradaIds.contains(entry.id),
            )
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));

    if (selectedEntries.length < 4) {
      if (!mounted) return;
      _showChapterValidationMessage(
        context,
        AppLocalizations.of(context)!.chapterMinimumEntries,
      );
      return;
    }

    final capituloAtualizado = Capitulo(
      id: _resumo.capitulo.id,
      userId: userId,
      titulo: resultado.titulo,
      descricao: resultado.descricao,
      dataInicio: selectedEntries.first.data,
      dataFim: selectedEntries.last.data,
      criadoAutomaticamente: _resumo.capitulo.criadoAutomaticamente,
    );

    await widget.capituloHelper.updateCapituloWithEntradas(
      capituloAtualizado,
      selectedEntries.map((entry) => entry.id!).toList(growable: false),
    );

    if (!mounted) return;
    _didChange = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterUpdated)),
    );
    await _loadChapterData();
  }

  Future<void> _excluirCapitulo() async {
    final capituloId = _resumo.capitulo.id;
    if (capituloId == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.chapterDeleteConfirmTitle),
        content: Text(
          l10n.chapterDeleteConfirmMessage(_resumo.capitulo.titulo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await widget.capituloHelper.deleteCapitulo(capituloId);

    if (!mounted) return;
    _didChange = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterDeleted)),
    );
    Navigator.of(context).pop(true);
  }

  void _voltar() {
    Navigator.of(context).pop(_didChange);
  }

  Future<void> _abrirHistoria(Historia historia) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditHistoriaScreen(historia: historia)),
    );

    if (!mounted) return;
    // Recarrega o capítulo pois o título/humor da história pode ter mudado
    await _loadChapterData();
  }

  Widget _buildHeaderTag(BuildContext context, String tag) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$tag',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final capitulo = _resumo.capitulo;
    final periodo = l10n.chapterPeriod(
      DateFormat('dd/MM/yyyy', l10n.localeName).format(capitulo.dataInicio),
      DateFormat('dd/MM/yyyy', l10n.localeName).format(capitulo.dataFim),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _voltar();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _voltar,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(capitulo.titulo),
          actions: [
            IconButton(
              tooltip: l10n.edit,
              onPressed: _editarCapitulo,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: l10n.deleteLabel,
              onPressed: _excluirCapitulo,
              color: colorScheme.error,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: capitulo.criadoAutomaticamente
                                      ? colorScheme.tertiaryContainer
                                      : colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  capitulo.criadoAutomaticamente
                                      ? Icons.auto_awesome
                                      : Icons.bookmark_outline,
                                  color: capitulo.criadoAutomaticamente
                                      ? colorScheme.onTertiaryContainer
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      capitulo.titulo,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      periodo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildMetaChip(
                                context: context,
                                icon: Icons.menu_book_outlined,
                                label: l10n.chapterEntriesCount(
                                  _resumo.totalEntradas,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildMoodBar(context, _resumo.humorMedio),
                            ],
                          ),
                          if (capitulo.descricao != null &&
                              capitulo.descricao!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(capitulo.descricao!.trim()),
                          ],
                          if (_resumo.topTags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _resumo.topTags
                                  .map((tag) => _buildHeaderTag(context, tag))
                                  .toList(growable: false),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chapterEntriesCount(_entradas.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_entradas.isEmpty)
                    Text(
                      l10n.noStoriesHere,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    )
                  else
                    ..._entradas.map(
                      (entrada) => CompactHistoriaCard(
                        historia: entrada,
                        localeName: l10n.localeName,
                        onTap: () => _abrirHistoria(entrada),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
