# Implementação de Registros Multimídia (Áudio e Vídeo) nas Histórias

## 📋 O que foi implementado

### 1. **Modelos de Dados**
   - ✅ `lib/models/historia_audio.dart` - Modelo para armazenar áudios
   - ✅ `lib/models/historia_video.dart` - Modelo para armazenar vídeos

### 2. **Helpers de Banco de Dados**
   - ✅ `lib/db/historia_audio_helper.dart` - CRUD para áudios
   - ✅ `lib/db/historia_video_helper.dart` - CRUD para vídeos
   - ✅ Atualizado `database_helper.dart` para versão 6 do banco
     - Nova tabela: `historia_audios` (id, historia_id, audio BLOB, legenda, duracao)
     - Nova tabela: `historia_videos` (id, historia_id, video BLOB, legenda, duracao, thumbnail BLOB)

### 3. **Widgets de Interface**
   - ✅ `lib/widgets/audio_recorder_widget.dart` - Seletor de áudio
     - **Windows/Desktop**: Abre diálogo para selecionar arquivo de áudio (.mp3, .m4a, .wav, etc)
     - **Mobile**: (Futura implementação com gravação nativa)
   - ✅ `lib/widgets/audio_player_widget.dart` - Player de áudio
     - Controles: Play/Pause, Seek, Tempo atual/total
     - Interface compacta com slider de progresso
   - ✅ `lib/widgets/video_player_widget.dart` - Player de vídeo
     - Controles: Play/Pause, Seek, Tempo atual/total
     - Thumbnail quando pausado
     - Controles sobrepõem o vídeo

### 4. **Tela de Criação de História**
   - ✅ Atualizado `create_historia_screen.dart`
     - Botão "Gravar Áudio" - Abre dialog para selecionar arquivo de áudio
     - Botão "Adicionar Vídeo" - Permite selecionar vídeos da galeria
     - Visualização de áudios adicionados com player funcional
     - Visualização de vídeos adicionados com player funcional
     - Salvamento de áudios e vídeos no banco de dados SQLite como BLOB
     - Botões para remover áudios e vídeos antes de salvar

### 5. **Pacotes Adicionados**
   - ✅ `audioplayers: ^6.1.0` - Reprodução de áudio
   - ✅ `video_player: ^2.9.2` - Reprodução de vídeo
   - ✅ `file_picker: ^8.1.6` - Seleção de arquivos de áudio e vídeo
   
   **Notas**: 
   - O pacote `record` foi removido devido a incompatibilidade com Windows
   - O pacote `video_thumbnail` foi removido por não funcionar no Windows
   - Usamos `file_picker` para selecionar arquivos existentes
   - Thumbnails de vídeo serão implementados futuramente com solução alternativa

## 🔧 Próximos Passos (Para Completar a Implementação)

### 1. **Tela de Visualização de História**
   É necessário atualizar as seguintes telas para exibir áudios e vídeos:
   
   - `lib/screens/home_content.dart`
   - `lib/screens/archived_stories_screen.dart`
   - `lib/screens/group_stories_screen.dart`

   **O que fazer:**
   ```dart
   // Adicionar após a seção de fotos em cada card de história
   
   // 1. Buscar áudios da história
   Future<List<HistoriaAudio>> _getAudios(int historiaId) async {
     return await HistoriaAudioHelper().getAudiosByHistoria(historiaId);
   }
   
   // 2. Buscar vídeos da história
   Future<List<HistoriaVideo>> _getVideos(int historiaId) async {
     return await HistoriaVideoHelper().getVideosByHistoria(historiaId);
   }
   
   // 3. Na interface, adicionar:
   FutureBuilder<List<HistoriaAudio>>(
     future: _getAudios(historia.id ?? 0),
     builder: (context, snapshot) {
       if (snapshot.hasData && snapshot.data!.isNotEmpty) {
         return Column(
           children: snapshot.data!.map((audio) {
             return AudioPlayerWidget(
               audioData: audio.audio,
               duration: audio.duracao,
             );
           }).toList(),
         );
       }
       return const SizedBox.shrink();
     },
   ),
   
   // Similar para vídeos com VideoPlayerWidget
   ```

### 2. **Tela de Edição de História**
   Atualizar `lib/screens/edit_historia_screen.dart`
   
   **O que fazer:**
   - Carregar áudios e vídeos existentes ao abrir a tela
   - Permitir adicionar novos áudios e vídeos
   - Permitir excluir áudios e vídeos
   - Salvar alterações no banco de dados

   **Exemplo:**
   ```dart
   // Adicionar listas de áudios e vídeos
   List<Map<String, dynamic>> audios = [];
   List<Map<String, dynamic>> videos = [];
   List<int> audioIds = []; // IDs dos áudios existentes
   List<int> videoIds = []; // IDs dos vídeos existentes
   
   // Carregar no initState
   Future<void> _loadMedia() async {
     final audiosDb = await HistoriaAudioHelper().getAudiosByHistoria(widget.historia.id ?? 0);
     final videosDb = await HistoriaVideoHelper().getVideosByHistoria(widget.historia.id ?? 0);
     
     setState(() {
       audios = audiosDb.map((a) => {
         'audio': Uint8List.fromList(a.audio),
         'duration': a.duracao,
       }).toList();
       audioIds = audiosDb.map((a) => a.id ?? 0).toList();
       
       videos = videosDb.map((v) => {
         'video': Uint8List.fromList(v.video),
         'thumbnail': v.thumbnail != null ? Uint8List.fromList(v.thumbnail!) : null,
         'duration': v.duracao,
       }).toList();
       videoIds = videosDb.map((v) => v.id ?? 0).toList();
     });
   }
   
   // Excluir áudio
   void _removeAudio(int index) async {
     if (audioIds[index] != 0) {
       await HistoriaAudioHelper().deleteAudio(audioIds[index]);
     }
     setState(() {
       audios.removeAt(index);
       audioIds.removeAt(index);
     });
   }
   
   // Similar para vídeos
   ```

### 3. **Permissões de Plataforma**

   **Android** - Adicionar em `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   ```

   **iOS** - Adicionar em `ios/Runner/Info.plist`:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>Este app precisa acessar o microfone para gravar áudios</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Este app precisa acessar a galeria para selecionar vídeos</string>
   ```

   **Windows** - Adicionar capacidades em `windows/runner/Runner.exe.manifest`:
   ```xml
   <Capability Name="videosLibrary"/>
   <Capability Name="musicLibrary"/>
   ```

### 4. **Otimizações Recomendadas**

   - [ ] **Compressão de Vídeos**: Adicionar pacote `video_compress` para reduzir tamanho
   - [ ] **Limite de Tamanho**: Implementar limite de tamanho para arquivos (ex: 50MB para vídeos)
   - [ ] **Indicador de Upload**: Mostrar progresso ao salvar arquivos grandes
   - [ ] **Cache de Thumbnails**: Guardar thumbnails de vídeos em cache para performance
   - [ ] **Streaming**: Para vídeos grandes, considerar salvar em arquivo e fazer streaming

### 5. **Melhorias Futuras**

   - [ ] **Filtros de Áudio**: Adicionar efeitos sonoros
   - [ ] **Edição de Vídeo**: Permitir cortar vídeos antes de salvar
   - [ ] **Galeria de Mídia**: Visualização em fullscreen de fotos/vídeos
   - [ ] **Compartilhamento**: Permitir compartilhar áudios e vídeos separadamente
   - [ ] **Backup em Nuvem**: Sincronizar com Firebase Storage para backup

## 🧪 Como Testar

1. **Testar Gravação de Áudio**
   - Abrir tela de criação de história
   - Clicar em "Gravar Áudio"
   - Gravar uma mensagem
   - Verificar se o player aparece
   - Reproduzir o áudio
   - Salvar a história
   - Verificar se o áudio foi salvo

2. **Testar Adição de Vídeo**
   - Abrir tela de criação de história
   - Clicar em "Adicionar Vídeo"
   - Selecionar um vídeo da galeria
   - Verificar se o player aparece
   - Reproduzir o vídeo
   - Salvar a história
   - Verificar se o vídeo foi salvo

3. **Verificar Banco de Dados**
   ```dart
   // No terminal do app, verificar:
   final audios = await HistoriaAudioHelper().getAudiosByHistoria(1);
   print('Áudios: ${audios.length}');
   
   final videos = await HistoriaVideoHelper().getVideosByHistoria(1);
   print('Vídeos: ${videos.length}');
   ```

## 📝 Notas Importantes

- Os arquivos de mídia são armazenados como BLOBs no SQLite
- Para vídeos muito grandes, considere salvar em arquivo e guardar apenas o caminho
- A gravação de áudio requer permissões em tempo de execução
- Em Windows, notificações agendadas não são suportadas (já implementado)
- Os players de áudio e vídeo criam arquivos temporários para reprodução

## 🐛 Problemas Conhecidos

- [ ] O plugin `video_thumbnail` pode não funcionar em todas as plataformas
- [ ] A gravação de áudio pode não funcionar no emulador Windows
- [ ] Vídeos muito grandes podem causar lentidão ao salvar

## 📚 Referências

- [record package](https://pub.dev/packages/record)
- [audioplayers package](https://pub.dev/packages/audioplayers)
- [video_player package](https://pub.dev/packages/video_player)
- [file_picker package](https://pub.dev/packages/file_picker)
