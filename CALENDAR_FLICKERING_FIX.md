# Correção do Problema de Piscar no Calendário

## Problema Identificado

Quando o usuário selecionava um dia no calendário, a tela ficava piscando continuamente como se estivesse recuperando dados sem parar. O único recurso disponível era voltar para a home screen.

## Causa Raiz

O problema estava na implementação do `Consumer<RefreshProvider>` dentro do método `build()` da tela de calendário (`calendar_view_screen.dart`).

### Código Problemático (antes):

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<RefreshProvider>(
      builder: (context, refreshProvider, child) {
        // Recarregar quando o provider notificar
        if (refreshProvider.refreshCounter > 0) {
          Future.microtask(() => _loadHistorias());
        }

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          // ... resto do código
        );
      },
    ),
  );
}
```

### Por que causava o problema?

1. O `Consumer` estava envolvendo todo o body do Scaffold
2. Cada vez que o `refreshCounter` mudava, o builder era reconstruído
3. Dentro do builder, `_loadHistorias()` era chamado via `Future.microtask()`
4. `_loadHistorias()` chamava `setState()`, causando uma nova reconstrução
5. Isso criava um **loop infinito de reconstruções**, causando o efeito de "piscar"

## Solução Implementada

### 1. Removido o Consumer do build()

O `Consumer` foi completamente removido do método `build()`. Agora o body é renderizado diretamente:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            // ... resto do código
          ),
  );
}
```

### 2. Adicionado listener adequado no initState

Foi implementado um listener apropriado no `initState()` que escuta mudanças no `RefreshProvider` sem causar loops:

```dart
@override
void initState() {
  super.initState();
  _selectedDay = _focusedDay;
  _selectedHistorias = ValueNotifier([]);
  _loadHistorias();

  // Adicionar listener para atualizar quando houver mudanças
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.addListener(_onRefresh);
  });
}

void _onRefresh() {
  if (mounted) {
    _loadHistorias();
  }
}
```

### 3. Limpeza adequada no dispose

O listener é removido apropriadamente quando o widget é destruído:

```dart
@override
void dispose() {
  final refreshProvider = Provider.of<RefreshProvider>(
    context,
    listen: false,
  );
  refreshProvider.removeListener(_onRefresh);
  _selectedHistorias.dispose();
  super.dispose();
}
```

## Benefícios da Solução

1. **Eliminação do loop infinito**: O listener agora é registrado uma única vez e não é recriado a cada rebuild
2. **Melhor performance**: Não há mais reconstruções desnecessárias da UI
3. **Código mais limpo**: Separação clara entre lógica de atualização e renderização
4. **Gerenciamento adequado de recursos**: O listener é removido quando o widget é destruído, evitando memory leaks

## Comportamento Esperado Após a Correção

- Ao selecionar um dia no calendário, a tela deve atualizar normalmente sem piscar
- As histórias do dia selecionado devem aparecer na lista abaixo do calendário
- O usuário pode navegar entre os dias sem problemas
- A tela responde normalmente aos toques e interações

## Data da Correção

03 de outubro de 2025
