import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/emoji_service.dart';
import '../widgets/emoji_selection_modal.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'edit_historia_screen.dart';

/// Enum para os tipos de pesquisa disponíveis
enum SearchType {
  text, // Pesquisa por texto no título ou descrição
  tag, // Pesquisa por tag
  emoticon, // Pesquisa por emoticon
}

/// Tela de pesquisa de histórias
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final EmojiService _emojiService = EmojiService();
  SearchType _currentSearchType = SearchType.text;
  String? _selectedEmoticon; // Emoji caractere selecionado (ex: 😄)
  String? _selectedEmojiTranslation; // Tradução do emoji (ex: Sorrir)
  List<Historia> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _isLoadingEmojis = true;

  @override
  void initState() {
    super.initState();
    _loadEmojis();
  }

  Future<void> _loadEmojis() async {
    await _emojiService.loadEmojis();
    if (mounted) {
      setState(() {
        _isLoadingEmojis = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Executa a pesquisa com base no tipo selecionado
  Future<void> _performSearch() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';

    if (userId.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final db = await DatabaseHelper().database;
      List<Map<String, dynamic>> results;

      switch (_currentSearchType) {
        case SearchType.text:
          final query = _searchController.text.trim();
          if (query.isEmpty) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          // Pesquisa no título ou descrição
          results = await db.query(
            'historia',
            where:
                'user_id = ? AND excluido IS NULL AND (titulo LIKE ? OR descricao LIKE ?)',
            whereArgs: [userId, '%$query%', '%$query%'],
            orderBy: 'data DESC',
          );
          break;

        case SearchType.tag:
          final tag = _searchController.text.trim();
          if (tag.isEmpty) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          // Pesquisa por tag
          results = await db.query(
            'historia',
            where: 'user_id = ? AND excluido IS NULL AND tag LIKE ?',
            whereArgs: [userId, '%$tag%'],
            orderBy: 'data DESC',
          );
          break;

        case SearchType.emoticon:
          if (_selectedEmoticon == null) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          // Pesquisa por emoticon
          results = await db.query(
            'historia',
            where: 'user_id = ? AND excluido IS NULL AND emoticon = ?',
            whereArgs: [userId, _selectedEmoticon],
            orderBy: 'data DESC',
          );
          break;
      }

      setState(() {
        _searchResults = results.map((map) => Historia.fromMap(map)).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro na pesquisa: $e')));
      }
    }
  }

  /// Agrupa as histórias por data
  Map<String, List<Historia>> _groupByDate(List<Historia> historias) {
    final Map<String, List<Historia>> grouped = {};

    for (final historia in historias) {
      final dateKey = DateFormat('dd/MM/yyyy', 'pt_BR').format(historia.data);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(historia);
    }

    return grouped;
  }

  /// Limpa a pesquisa
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedEmoticon = null;
      _searchResults = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar'),
        actions: [
          if (_hasSearched)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar pesquisa',
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Column(
        children: [
          // Área de filtros
          _buildSearchFilters(),
          const Divider(height: 1),
          // Área de resultados
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  /// Constrói a área de filtros de pesquisa
  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips para seleção do tipo de pesquisa
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.text_fields, size: 18),
                    SizedBox(width: 4),
                    Text('Texto'),
                  ],
                ),
                selected: _currentSearchType == SearchType.text,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSearchType = SearchType.text;
                      _selectedEmoticon = null;
                    });
                  }
                },
              ),
              ChoiceChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label, size: 18),
                    SizedBox(width: 4),
                    Text('Tag'),
                  ],
                ),
                selected: _currentSearchType == SearchType.tag,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSearchType = SearchType.tag;
                      _selectedEmoticon = null;
                    });
                  }
                },
              ),
              ChoiceChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mood, size: 18),
                    SizedBox(width: 4),
                    Text('Emoticon'),
                  ],
                ),
                selected: _currentSearchType == SearchType.emoticon,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSearchType = SearchType.emoticon;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo de pesquisa ou seleção de emoticon
          if (_currentSearchType == SearchType.emoticon)
            _buildEmoticonSelector()
          else
            _buildTextSearchField(),
        ],
      ),
    );
  }

  /// Campo de pesquisa por texto
  Widget _buildTextSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _currentSearchType == SearchType.tag
                  ? 'Digite a tag...'
                  : 'Pesquisar no título ou descrição...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _performSearch(),
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _searchController.text.trim().isNotEmpty
              ? _performSearch
              : null,
          child: const Text('Buscar'),
        ),
      ],
    );
  }

  /// Abre o modal de seleção de emoji
  Future<void> _openEmojiSelector() async {
    final result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmojiSelectionModal(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedEmoticon = result.char;
        _selectedEmojiTranslation = result.translation;
      });
      await _performSearch();
    }
  }

  /// Seletor de emoticons
  Widget _buildEmoticonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Toque para selecionar um emoji:',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            if (_selectedEmoticon != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedEmoticon = null;
                    _selectedEmojiTranslation = null;
                    _searchResults = [];
                    _hasSearched = false;
                  });
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Limpar'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Botão para abrir seletor de emoji
        InkWell(
          onTap: _isLoadingEmojis ? null : _openEmojiSelector,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedEmoticon != null
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).cardColor,
              border: Border.all(
                color: _selectedEmoticon != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: _selectedEmoticon != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingEmojis)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_selectedEmoticon != null) ...[
                  Text(
                    _selectedEmoticon!,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedEmojiTranslation ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Toque para alterar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Icon(
                    Icons.add_reaction_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Selecionar emoji',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói a área de resultados
  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Calcula o tamanho máximo da imagem baseado no espaço disponível
          final maxSize = constraints.maxHeight * 0.85;
          final imageSize = maxSize.clamp(150.0, 400.0);

          return Center(
            child: Image.asset(
              'assets/image/pesquisa_historias.png',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    }

    if (_searchResults.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Calcula o tamanho máximo da imagem baseado no espaço disponível
          final maxSize = constraints.maxHeight * 0.85;
          final imageSize = maxSize.clamp(150.0, 400.0);

          return Center(
            child: Image.asset(
              'assets/image/nao_achou.png',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    }

    // Agrupa resultados por data
    final groupedResults = _groupByDate(_searchResults);
    final sortedDates = groupedResults.keys.toList()
      ..sort((a, b) {
        // Ordena por data decrescente
        final dateA = DateFormat('dd/MM/yyyy', 'pt_BR').parse(a);
        final dateB = DateFormat('dd/MM/yyyy', 'pt_BR').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final historias = groupedResults[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da data
            _buildDateHeader(dateKey, historias.length),
            // Cards das histórias
            ...historias.map((historia) => _buildHistoriaCard(historia)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Cabeçalho da data (agrupador)
  Widget _buildDateHeader(String dateKey, int count) {
    // Formata a data de forma amigável
    final date = DateFormat('dd/MM/yyyy', 'pt_BR').parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final parsedDate = DateTime(date.year, date.month, date.day);

    String displayDate;
    if (parsedDate == today) {
      displayDate = 'Hoje';
    } else if (parsedDate == yesterday) {
      displayDate = 'Ontem';
    } else {
      displayDate = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
      // Capitaliza primeira letra
      displayDate = displayDate[0].toUpperCase() + displayDate.substring(1);
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayDate,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card de uma história
  Widget _buildHistoriaCard(Historia historia) {
    return FutureBuilder<List<FotoComBytes>>(
      future: HistoriaFotoHelper().getFotosComBytesByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final hasImages = snapshot.hasData && snapshot.data!.isNotEmpty;

        return GestureDetector(
          onTap: () {
            final refreshProvider = Provider.of<RefreshProvider>(
              context,
              listen: false,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditHistoriaScreen(historia: historia),
              ),
            ).then((updated) {
              if (updated == true) {
                // Atualiza os resultados após edição
                _performSearch();
                if (mounted) {
                  refreshProvider.refresh();
                }
              }
            });
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem da história (se houver)
                  if (hasImages && snapshot.data!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        snapshot.data!.first.bytes,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Título e emoticon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          historia.titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (historia.emoticon != null &&
                          historia.emoticon!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildEmoticonWidget(historia.emoticon!),
                      ],
                    ],
                  ),

                  // Tag (se houver)
                  if (historia.tag != null && historia.tag!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        historia.tag!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],

                  // Descrição (resumo)
                  if (historia.descricao != null &&
                      historia.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: RichTextViewerWidget(
                        jsonContent: historia.descricao,
                      ),
                    ),
                  ],

                  // Hora
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm', 'pt_BR').format(historia.data),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget do emoticon - exibe o emoji Unicode diretamente
  Widget _buildEmoticonWidget(String emoticon) {
    // O emoticon é armazenado como caractere Unicode (ex: 😄)
    return Text(emoticon, style: const TextStyle(fontSize: 28));
  }
}
