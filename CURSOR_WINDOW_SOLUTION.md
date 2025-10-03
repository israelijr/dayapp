# 🎯 SOLUÇÃO: Row too big to fit into CursorWindow

## ❌ Problema Identificado

```
E/SQLiteQuery: exception: Row too big to fit into CursorWindow 
requiredPos=0, totalRows=2
DatabaseException(Row too big to fit into CursorWindow)
```

### Causa Raiz
- **Vídeo salvo**: 6.3MB (6,327,480 bytes)
- **Limite Android**: ~2MB por linha no CursorWindow
- **Resultado**: Impossível ler vídeos do banco de dados

### Por que funciona salvar mas não carregar?
- ✅ **INSERT funciona**: Grava BLOB no disco do SQLite
- ❌ **SELECT falha**: CursorWindow não consegue carregar linha inteira na memória

## ✅ Solução Implementada

### Arquitetura Nova

**Antes:**
```
SQLite → [BLOB de 6MB] → Memória → App ❌
```

**Depois:**
```
SQLite → [Caminho: "/videos/video_17.mp4"] → Disco → Carrega sob demanda → App ✅
```

### Mudanças

1. **Vídeos salvos no sistema de arquivos**
   - Pasta: `{AppDocuments}/videos/`
   - Nome: `video_{historiaId}_{timestamp}.mp4`

2. **Banco armazena apenas caminho**
   ```sql
   video_path TEXT NOT NULL  -- ao invés de video BLOB
   ```

3. **Carregamento sob demanda**
   - Vídeo só é lido quando usuário clica

## 📁 Arquivos Criados

### 1. `lib/helpers/video_file_helper.dart`
Gerencia vídeos no sistema de arquivos:
- `saveVideo()` - Salva e retorna caminho
- `readVideo()` - Lê quando necessário
- `deleteVideo()` - Remove do disco
- `cleanOrphanVideos()` - Limpeza

### 2. `lib/models/historia_video_v2.dart`
Novo modelo com caminhos:
```dart
class HistoriaVideo {
  final String videoPath;       // ← Caminho ao invés de bytes
  final String? thumbnailPath;  // ← Caminho ao invés de bytes
  final int? duracao;
}
```

## 🔄 Migração Necessária

### Atualizar DatabaseHelper para v7

**Passos:**
1. Criar tabela nova com `video_path`
2. Migrar vídeos existentes (< 2MB) para arquivos
3. Dropar tabela antiga
4. Renomear tabela nova

### Atualizar HistoriaVideoHelper

- Salvar vídeo → disco → path no banco
- Carregar vídeo → ler path do banco → ler disco

### Atualizar Telas

**edit_historia_screen.dart:**
```dart
// Ao adicionar vídeo
final videoPath = await VideoFileHelper.saveVideo(bytes, historiaId);
await HistoriaVideoHelper().insertVideo(
  HistoriaVideo(videoPath: videoPath, ...)
);
```

**Widgets de visualização:**
```dart
// CompactVideoIcon recebe path
CompactVideoIcon(videoPath: video.videoPath)

// Carrega apenas ao clicar
onTap: () async {
  final bytes = await VideoFileHelper.readVideo(videoPath);
  // Mostra player
}
```

## 🎯 Benefícios

| Aspecto | Antes (BLOB) | Depois (Arquivo) |
|---------|--------------|------------------|
| Tamanho máximo vídeo | ~2MB | ∞ Ilimitado |
| Velocidade de query | 🐌 Lenta | ⚡ Rápida |
| Uso de memória | 🔴 Alta | 🟢 Baixa |
| Erro CursorWindow | ❌ Sim | ✅ Não |
| Múltiplos vídeos | ❌ Problema | ✅ OK |

## 📋 Checklist de Implementação

- [x] 1. Criar VideoFileHelper
- [x] 2. Criar HistoriaVideo v2
- [x] 3. Documentação da migração
- [ ] 4. Atualizar DatabaseHelper (v6 → v7)
- [ ] 5. Atualizar HistoriaVideoHelper
- [ ] 6. Atualizar edit_historia_screen
- [ ] 7. Atualizar create_historia_screen  
- [ ] 8. Atualizar CompactVideoIcon
- [ ] 9. Atualizar VideoPlayerWidget
- [ ] 10. Atualizar home_content (carregar por path)
- [ ] 11. Atualizar group_stories_screen (carregar por path)
- [ ] 12. Testar migração de dados existentes
- [ ] 13. Testar no Android
- [ ] 14. Testar no Windows

## 🚀 Resultado Esperado

**Ao implementar:**
```
I/flutter: Vídeo salvo no caminho: /data/.../videos/video_17_123.mp4
I/flutter: Path salvo no banco com ID: 4
I/flutter: _loadMediaData - Historia 17: 0 áudios, 2 vídeos ✅
I/flutter: HistoriaMediaRow - ID: 17, Videos: 2 ✅
```

**Sem mais erros:**
```
❌ Row too big to fit into CursorWindow  ← Resolvido!
```

## 📌 Importante

### Áudios
- ✅ Continuam funcionando (são pequenos, < 2MB)
- ✅ Podem continuar como BLOB no banco
- ⚠️ Se problemas futuros, aplicar mesma solução

### Backward Compatibility
- Migração automática na atualização do app
- Vídeos antigos (se < 2MB) são convertidos
- Vídeos grandes antigos são perdidos (já não carregavam)

### Limpeza
- Implementar rotina periódica de limpeza de órfãos
- Ao deletar história, deletar arquivos associados

---

**Status Atual**: ✅ Solução desenhada e componentes criados
**Próximo Passo**: Implementar migração no DatabaseHelper
**Prioridade**: 🔴 Alta - Bloqueio crítico no Android
