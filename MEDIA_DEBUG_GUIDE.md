# Debug: Problemas com Mídia no Android

## Problemas Reportados

### 1. Tela de Edição - Android
**Problema**: Arquivo de vídeo não é salvo (áudio funciona)

### 2. Tela Home
**Problema**: Não aparecem emoticon, áudios e vídeos

## Investigação e Correções

### Logs Adicionados

#### edit_historia_screen.dart

**Método `_pickVideo()`:**
```dart
- Log de início da seleção
- Log do arquivo selecionado
- Log do tamanho em bytes
- Log da quantidade total de vídeos
- Log de erro detalhado
```

**Método `_save()` - Salvamento de vídeos:**
```dart
- Log antes de salvar cada vídeo
- Log do tamanho e duração
- Log do ID retornado após salvar
- Try-catch com log de erro
```

#### home_content.dart e group_stories_screen.dart

**Widget `HistoriaMediaRow`:**
```dart
- Log de loading state
- Log de erro (hasError)
- Log da quantidade de mídia carregada
- Try-catch no _loadMediaData
```

### Debug Prints Implementados

```
[EDIT] Iniciando seleção de vídeo...
[EDIT] Arquivo de vídeo selecionado: /path/to/video.mp4
[EDIT] Vídeo carregado: 12345678 bytes
[EDIT] Vídeo adicionado à lista. Total de vídeos: 1
[EDIT] Salvando novo vídeo 0 - Tamanho: 12345678 bytes, Duração: 0
[EDIT] Vídeo 0 salvo com ID: 123

[HOME] _loadMediaData - Historia 1: 2 áudios, 1 vídeos
[HOME] HistoriaMediaRow - ID: 1, Emoticon: Feliz, Audios: 2, Videos: 1

[GRUPO] _loadMediaData [Grupo] - Historia 2: 1 áudios, 0 vídeos
[GRUPO] HistoriaMediaRow [Grupo] - ID: 2, Emoticon: null, Audios: 1, Videos: 0
```

## Como Testar

### 1. Problema do Vídeo no Android

Execute a aplicação com debug console visível:

```bash
flutter run --debug
```

**Passos:**
1. Abra uma história existente para editar
2. Clique em "Adicionar Vídeo"
3. Selecione um arquivo de vídeo
4. Observe os logs no console:
   ```
   Iniciando seleção de vídeo...
   Arquivo de vídeo selecionado: ...
   Vídeo carregado: X bytes
   Vídeo adicionado à lista. Total de vídeos: Y
   ```
5. Clique em "Salvar"
6. Observe os logs:
   ```
   Salvando novo vídeo 0 - Tamanho: X bytes, Duração: 0
   Vídeo 0 salvo com ID: Z
   ```

**Diagnóstico:**
- ✅ Se todos os logs aparecem → Vídeo está sendo salvo corretamente
- ❌ Se logs param em "Iniciando seleção" → Problema no FilePicker
- ❌ Se logs param em "Vídeo adicionado" → Problema no salvamento
- ❌ Se aparece "Erro ao salvar vídeo" → Verificar mensagem de erro

### 2. Problema da Home (Emoticon/Mídia não aparecem)

**Passos:**
1. Navegue para a Home
2. Observe os logs para cada história:
   ```
   _loadMediaData - Historia X: Y áudios, Z vídeos
   HistoriaMediaRow - ID: X, Emoticon: ..., Audios: Y, Videos: Z
   ```

**Diagnóstico:**
- ✅ Se logs mostram dados → Widget está carregando
- ❌ Se "Audios: 0, Videos: 0" mas você adicionou → Problema no banco
- ❌ Se "Erro ao carregar mídia" → Verificar mensagem de erro
- ❌ Se nenhum log aparece → Widget não está sendo renderizado

## Possíveis Causas e Soluções

### Vídeo não salva no Android

#### Causa 1: Permissões
**Solução**: Verificar permissões no AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### Causa 2: Arquivo muito grande
**Solução**: Verificar no log o tamanho do arquivo
- Se > 50MB, pode haver timeout no banco
- Considerar compressão ou limite de tamanho

#### Causa 3: Erro na conversão de bytes
**Solução**: Verificar se `bytes` é Uint8List válido
```dart
debugPrint('Tipo: ${bytes.runtimeType}');
```

#### Causa 4: Transação do banco falhou
**Solução**: Adicionar await e verificar retorno
```dart
final videoId = await HistoriaVideoHelper().insertVideo(...);
if (videoId == null || videoId == 0) {
  debugPrint('Falha ao inserir no banco!');
}
```

### Emoticon/Mídia não aparecem na Home

#### Causa 1: FutureBuilder não completa
**Solução**: Logs mostrarão se `_loadMediaData` está travando
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  // Esperando dados...
}
```

#### Causa 2: Dados estão no banco mas não carregam
**Solução**: Verificar helpers
```dart
// Teste direto:
final audios = await HistoriaAudioHelper().getAudiosByHistoria(1);
debugPrint('Audios direto: ${audios.length}');
```

#### Causa 3: Widget retorna SizedBox.shrink()
**Solução**: Verificar condição
```dart
if ((emoticon == null || emoticon!.isEmpty) && 
    audios.isEmpty && 
    videos.isEmpty) {
  return const SizedBox.shrink(); // Widget oculto
}
```

#### Causa 4: historiaId incorreto
**Solução**: Verificar se `historia.id` não é null
```dart
debugPrint('Historia ID: ${historia.id}');
```

## Testes Específicos

### Teste 1: Verificar dados no banco (SQLite)

Use uma ferramenta como DB Browser for SQLite para verificar:

**Tabela `historia_videos`:**
```sql
SELECT id, historiaId, length(video) as tamanho, duracao 
FROM historia_videos;
```

**Tabela `historia_audios`:**
```sql
SELECT id, historiaId, length(audio) as tamanho, duracao 
FROM historia_audios;
```

**Tabela `historia`:**
```sql
SELECT id, titulo, emoticon 
FROM historia;
```

### Teste 2: Verificar helpers diretamente

Adicione um botão de teste:
```dart
ElevatedButton(
  onPressed: () async {
    final audios = await HistoriaAudioHelper().getAudiosByHistoria(1);
    final videos = await HistoriaVideoHelper().getVideosByHistoria(1);
    debugPrint('Teste direto - Audios: ${audios.length}, Videos: ${videos.length}');
  },
  child: Text('Teste Helpers'),
)
```

### Teste 3: Verificar emoticon

```dart
debugPrint('Historia: ${historia.titulo}');
debugPrint('Emoticon: ${historia.emoticon}');
debugPrint('Emoticon != null: ${historia.emoticon != null}');
debugPrint('Emoticon não vazio: ${historia.emoticon?.isNotEmpty}');
```

## Checklist de Debug

- [ ] Logs aparecem no console?
- [ ] `_pickVideo` é chamado?
- [ ] Arquivo é selecionado (path != null)?
- [ ] Bytes são carregados (length > 0)?
- [ ] Vídeo é adicionado à lista?
- [ ] `_save` é chamado?
- [ ] Loop de salvamento executa?
- [ ] `insertVideo` é chamado?
- [ ] ID é retornado?
- [ ] Erro aparece em algum ponto?
- [ ] `_loadMediaData` é chamado na Home?
- [ ] Dados são retornados pelos helpers?
- [ ] Widget HistoriaMediaRow é renderizado?
- [ ] Condições de ocultar não estão ativas?

## Próximos Passos

Após executar a aplicação com os logs:

1. **Copie todos os logs relevantes**
2. **Identifique onde o fluxo para**
3. **Verifique mensagens de erro**
4. **Compare com o fluxo esperado**
5. **Teste com arquivo pequeno (< 5MB)**
6. **Verifique banco de dados diretamente**

## Logs Esperados (Sucesso)

### Edição + Salvamento de Vídeo
```
I/flutter: Iniciando seleção de vídeo...
I/flutter: Arquivo de vídeo selecionado: /storage/.../video.mp4
I/flutter: Vídeo carregado: 12345678 bytes
I/flutter: Vídeo adicionado à lista. Total de vídeos: 1
I/flutter: Salvando novo vídeo 0 - Tamanho: 12345678 bytes, Duração: 0
I/flutter: Vídeo 0 salvo com ID: 15
```

### Carregamento na Home
```
I/flutter: _loadMediaData - Historia 5: 2 áudios, 1 vídeos
I/flutter: HistoriaMediaRow - ID: 5, Emoticon: Feliz, Audios: 2, Videos: 1
```

---

**Status**: Logs de debug implementados ✅
**Próximo**: Executar e analisar logs
**Objetivo**: Identificar onde o fluxo falha
