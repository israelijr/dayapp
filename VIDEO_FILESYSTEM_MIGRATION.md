# Migração: Vídeos para Sistema de Arquivos

## Problema
```
Row too big to fit into CursorWindow requiredPos=0, totalRows=2
```

O Android SQLite tem limite de ~2MB por linha no CursorWindow. Vídeos de 6MB+ causam este erro.

## Solução

### 1. Nova Estrutura

**Antes (BLOB no banco):**
```sql
CREATE TABLE historia_videos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  historia_id INTEGER NOT NULL,
  video BLOB NOT NULL,          -- ❌ Problema: muito grande
  thumbnail BLOB,
  legenda TEXT,
  duracao INTEGER
);
```

**Depois (Caminho no banco):**
```sql
CREATE TABLE historia_videos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  historia_id INTEGER NOT NULL,
  video_path TEXT NOT NULL,     -- ✅ Apenas caminho
  thumbnail_path TEXT,           -- ✅ Caminho da thumb
  legenda TEXT,
  duracao INTEGER
);
```

### 2. Arquivos Criados

- `lib/helpers/video_file_helper.dart` - Gerencia arquivos no sistema
- `lib/models/historia_video_v2.dart` - Novo modelo com caminhos

### 3. Implementação

#### VideoFileHelper

**Funções:**
- `saveVideo(videoData, historiaId)` - Salva vídeo e retorna caminho
- `readVideo(filePath)` - Lê vídeo do disco
- `deleteVideo(filePath)` - Remove vídeo
- `listVideosForHistoria(historiaId)` - Lista vídeos de uma história
- `cleanOrphanVideos(validPaths)` - Limpa vídeos sem referência

**Estrutura de arquivos:**
```
/data/user/0/com.example.dayapp/
  app_flutter/
    videos/
      video_17_1759451676112.mp4
      video_17_1759451823456.mp4
      video_16_1759452001234.mp4
```

**Nomenclatura:**
```
video_{historiaId}_{timestamp}.mp4
```

### 4. Migração do Banco

Atualize `DatabaseHelper` para versão 7:

```dart
static const int _databaseVersion = 7;

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 7) {
    // Criar nova tabela
    await db.execute('''
      CREATE TABLE IF NOT EXISTS historia_videos_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        historia_id INTEGER NOT NULL,
        video_path TEXT NOT NULL,
        thumbnail_path TEXT,
        legenda TEXT,
        duracao INTEGER,
        FOREIGN KEY (historia_id) REFERENCES historia (id) ON DELETE CASCADE
      )
    ''');

    // Migrar dados existentes (se houver vídeos pequenos)
    try {
      final videos = await db.query('historia_videos');
      for (final video in videos) {
        try {
          final videoData = video['video'] as Uint8List?;
          if (videoData != null && videoData.length < 2000000) { // < 2MB
            // Salvar no sistema de arquivos
            final historiaId = video['historia_id'] as int;
            final videoPath = await VideoFileHelper.saveVideo(
              videoData,
              historiaId,
            );
            
            // Inserir na nova tabela
            await db.insert('historia_videos_new', {
              'historia_id': historiaId,
              'video_path': videoPath,
              'thumbnail_path': null,
              'legenda': video['legenda'],
              'duracao': video['duracao'],
            });
          }
        } catch (e) {
          debugPrint('Erro ao migrar vídeo: $e');
        }
      }
    } catch (e) {
      debugPrint('Tabela antiga não existe ou erro na migração: $e');
    }

    // Dropar tabela antiga e renomear nova
    await db.execute('DROP TABLE IF EXISTS historia_videos');
    await db.execute('ALTER TABLE historia_videos_new RENAME TO historia_videos');
  }
}
```

### 5. Atualizar HistoriaVideoHelper

```dart
class HistoriaVideoHelper {
  Future<int> insertVideo(HistoriaVideo video) async {
    final db = await DatabaseHelper().database;
    return await db.insert('historia_videos', video.toMap());
  }

  Future<List<HistoriaVideo>> getVideosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'historia_videos',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
    return maps.map((map) => HistoriaVideo.fromMap(map)).toList();
  }

  Future<void> deleteVideo(int id) async {
    final db = await DatabaseHelper().database;
    
    // Obter caminho do vídeo antes de deletar
    final maps = await db.query(
      'historia_videos',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final video = HistoriaVideo.fromMap(maps.first);
      // Deletar arquivo
      await VideoFileHelper.deleteVideo(video.videoPath);
      if (video.thumbnailPath != null) {
        await VideoFileHelper.deleteVideo(video.thumbnailPath!);
      }
    }
    
    // Deletar do banco
    await db.delete(
      'historia_videos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### 6. Atualizar Telas

#### edit_historia_screen.dart

```dart
// Ao salvar vídeo
for (int i = 0; i < videos.length; i++) {
  if (videoIds[i] == 0) {
    // Salvar arquivo no disco
    final videoPath = await VideoFileHelper.saveVideo(
      videos[i]['video'],
      widget.historia.id ?? 0,
    );
    
    // Salvar referência no banco
    await HistoriaVideoHelper().insertVideo(
      HistoriaVideo(
        historiaId: widget.historia.id ?? 0,
        videoPath: videoPath,
        thumbnailPath: null,
        duracao: videos[i]['duration'],
      ),
    );
  }
}
```

#### Widgets de visualização

```dart
// CompactVideoIcon e VideoPlayerWidget
// Ao invés de receber List<int> videoData
// Receber String videoPath e carregar quando necessário

class CompactVideoIcon extends StatelessWidget {
  final String videoPath;  // Mudança aqui
  final int? duration;
  
  void _showVideoDialog(BuildContext context) async {
    // Carregar vídeo do disco apenas quando clicar
    final videoData = await VideoFileHelper.readVideo(videoPath);
    if (videoData != null) {
      // Mostrar player
    }
  }
}
```

## Benefícios

### Performance
- ✅ Sem limite de CursorWindow
- ✅ Queries SQL instantâneas
- ✅ Carregamento sob demanda
- ✅ Menos uso de memória

### Escalabilidade
- ✅ Suporta vídeos de qualquer tamanho
- ✅ Múltiplos vídeos por história
- ✅ Fácil backup (apenas copiar pasta)
- ✅ Limpeza de órfãos

### Manutenção
- ✅ Código mais simples
- ✅ Debug mais fácil
- ✅ Compatível com todas as plataformas

## Limitações Antigas vs Novas

| Aspecto | BLOB (Antigo) | Arquivo (Novo) |
|---------|---------------|----------------|
| Tamanho máximo | ~2MB | Ilimitado |
| Performance query | Lenta | Rápida |
| Uso de memória | Alta | Baixa |
| Backup | Difícil | Fácil |
| Debug | Difícil | Fácil |

## Próximos Passos

1. ✅ Criar VideoFileHelper
2. ✅ Criar HistoriaVideo v2
3. ⏳ Atualizar DatabaseHelper (versão 7)
4. ⏳ Atualizar HistoriaVideoHelper
5. ⏳ Atualizar edit_historia_screen
6. ⏳ Atualizar create_historia_screen
7. ⏳ Atualizar widgets de visualização
8. ⏳ Testar migração
9. ⏳ Testar no Android

## Status

🔧 **Em desenvolvimento**
📝 **Próximo**: Implementar migração no DatabaseHelper
