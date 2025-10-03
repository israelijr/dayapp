# Guia de Uso: Ícones de Mídia Compactos

## Para o Usuário Final

### Visualizando Áudios e Vídeos nas Histórias

#### Na Home
1. Abra uma história que contenha áudios ou vídeos
2. Você verá pequenos ícones com os símbolos de áudio 🎵 e vídeo 🎥
3. Cada ícone mostra a duração do arquivo
4. **Clique no ícone** para reproduzir

#### Reproduzindo Áudio
- Ao clicar no ícone de áudio, uma janela se abre
- Use os controles de play/pause
- Arraste a barra de progresso para pular partes
- Feche a janela para voltar

#### Reproduzindo Vídeo
- Ao clicar no ícone de vídeo, uma janela maior se abre
- **No Windows**: Você verá informações do vídeo (tamanho, duração)
  - Nota: Reprodução de vídeo não disponível no Windows
- **No Android/iOS**: O vídeo será reproduzido normalmente
- Feche a janela para voltar

### Criando/Editando Histórias

#### Adicionando Mídia
1. Clique em "Adicionar Áudio" ou "Adicionar Vídeo"
2. Selecione o arquivo desejado
3. O ícone aparecerá na lista de mídias

#### Visualizando Mídia Adicionada
- Clique no ícone para reproduzir/visualizar
- A janela abrirá com o player

#### Removendo Mídia
- Cada ícone tem um botão **X vermelho** no canto superior direito
- Clique no X para remover o arquivo
- Não é necessário abrir o player para remover

## Para Desenvolvedores

### Usando CompactAudioIcon

```dart
import '../widgets/compact_audio_icon.dart';

// Apenas visualização (sem exclusão)
CompactAudioIcon(
  audioData: audioBytes,
  duration: durationInSeconds,
)

// Com opção de exclusão
CompactAudioIcon(
  audioData: audioBytes,
  duration: durationInSeconds,
  onDelete: () {
    // Lógica de exclusão
    setState(() {
      audios.removeAt(index);
    });
  },
)
```

### Usando CompactVideoIcon

```dart
import '../widgets/compact_video_icon.dart';

// Apenas visualização
CompactVideoIcon(
  videoData: videoBytes,
  thumbnail: thumbnailBytes, // opcional
  duration: durationInSeconds,
)

// Com opção de exclusão
CompactVideoIcon(
  videoData: videoBytes,
  duration: durationInSeconds,
  onDelete: () {
    // Lógica de exclusão
    setState(() {
      videos.removeAt(index);
    });
  },
)
```

### Layout Horizontal com Wrap

```dart
// Múltiplos ícones em linha
Wrap(
  spacing: 8,      // Espaço horizontal entre ícones
  runSpacing: 8,   // Espaço vertical se quebrar linha
  children: [
    CompactAudioIcon(audioData: audio1, duration: 120),
    CompactAudioIcon(audioData: audio2, duration: 180),
    CompactVideoIcon(videoData: video1, duration: 300),
  ],
)

// Com dados dinâmicos
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: audios.map((audio) {
    return CompactAudioIcon(
      audioData: audio.data,
      duration: audio.duration,
    );
  }).toList(),
)
```

### Personalizando o Dialog

Os widgets já vêm com dialogs padrão, mas você pode customizar:

```dart
// Dialog personalizado para áudio
void _showCustomAudioDialog(BuildContext context, List<int> audioData) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Meu Player Customizado'),
      content: AudioPlayerWidget(audioData: audioData),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Fechar'),
        ),
      ],
    ),
  );
}
```

## Troubleshooting

### Ícone não aparece
- Verifique se os assets estão no pubspec.yaml:
  ```yaml
  flutter:
    assets:
      - assets/image/audio.png
      - assets/image/video.png
  ```
- Execute `flutter pub get`

### Erro ao clicar
- Verifique se os dados (audioData/videoData) são válidos
- Certifique-se de que são List<int> ou Uint8List

### Layout quebrado
- Use Wrap ao invés de Row para permitir quebra de linha
- Ajuste spacing e runSpacing conforme necessário

### Vídeo não reproduz no Windows
- Comportamento esperado - o video_player não suporta Windows
- O widget mostra placeholder com informações do arquivo
- Considere usar package alternativo (media_kit) se necessário

## Exemplos de Código Completo

### Tela de Visualização
```dart
FutureBuilder<List<HistoriaAudio>>(
  future: HistoriaAudioHelper().getAudiosByHistoria(historiaId),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: snapshot.data!.map((audio) {
          return CompactAudioIcon(
            audioData: audio.audio,
            duration: audio.duracao,
          );
        }).toList(),
      ),
    );
  },
)
```

### Tela de Edição
```dart
if (audios.isNotEmpty) ...[
  Text('Áudios', style: TextStyle(fontWeight: FontWeight.bold)),
  SizedBox(height: 8),
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
]
```
