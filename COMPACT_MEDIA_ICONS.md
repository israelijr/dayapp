# Melhoria: Ícones Compactos para Áudio e Vídeo

## Objetivo
Substituir os players grandes de áudio e vídeo por ícones compactos que abrem os players em janelas de diálogo ao serem clicados.

## Arquivos Criados

### 1. `lib/widgets/compact_audio_icon.dart`
Widget compacto que exibe:
- Ícone do áudio (`assets/image/audio.png`)
- Duração do áudio
- Botão de exclusão (opcional, para edição)
- Ao clicar: abre Dialog com o AudioPlayerWidget completo

### 2. `lib/widgets/compact_video_icon.dart`
Widget compacto que exibe:
- Ícone do vídeo (`assets/image/video.png`)
- Duração do vídeo
- Botão de exclusão (opcional, para edição)
- Ao clicar: abre Dialog com o VideoPlayerWidget completo em janela própria

## Arquivos Modificados

### 1. `lib/screens/home_content.dart`
**Antes:**
- Players de áudio e vídeo exibidos em tamanho grande
- Layout vertical (Column) ocupando muito espaço

**Depois:**
- Ícones compactos com imagens dos assets
- Layout horizontal (Wrap) com espaçamento de 8px
- Clique abre player em dialog

### 2. `lib/screens/edit_historia_screen.dart`
**Antes:**
- Players grandes com botão X sobreposto
- Layout vertical ocupando muito espaço

**Depois:**
- Ícones compactos com botão X integrado
- Layout horizontal (Wrap) economizando espaço
- Clique abre player em dialog

### 3. `lib/screens/create_historia_screen.dart`
**Antes:**
- Players grandes com Stack para botão X
- Layout vertical

**Depois:**
- Ícones compactos com onDelete callback
- Layout horizontal (Wrap)
- Clique abre player em dialog

### 4. `lib/screens/group_stories_screen.dart`
**Antes:**
- Players de áudio e vídeo em tamanho grande

**Depois:**
- Ícones compactos clicáveis
- Layout horizontal (Wrap)

## Funcionalidades

### CompactAudioIcon
```dart
CompactAudioIcon(
  audioData: List<int>,      // Dados do áudio em bytes
  duration: int?,             // Duração em segundos (opcional)
  onDelete: VoidCallback?,    // Callback para exclusão (opcional)
)
```

**Características:**
- Mostra ícone `assets/image/audio.png` (fallback: Icons.audiotrack)
- Exibe duração formatada (MM:SS)
- Ao clicar: abre Dialog com player completo
- Botão de exclusão vermelho no canto superior direito (se onDelete fornecido)

### CompactVideoIcon
```dart
CompactVideoIcon(
  videoData: List<int>,       // Dados do vídeo em bytes
  thumbnail: List<int>?,      // Thumbnail (opcional)
  duration: int?,             // Duração em segundos (opcional)
  onDelete: VoidCallback?,    // Callback para exclusão (opcional)
)
```

**Características:**
- Mostra ícone `assets/image/video.png` (fallback: Icons.videocam)
- Exibe duração formatada (MM:SS)
- Ao clicar: abre Dialog maior (800x600) com player completo
- Botão de exclusão vermelho no canto superior direito (se onDelete fornecido)
- Dialog própria para melhor visualização

## Layout

### Antes (Column - Vertical)
```
┌─────────────────────────┐
│   [Player Áudio 1]      │
│   (200px altura)        │
├─────────────────────────┤
│   [Player Áudio 2]      │
│   (200px altura)        │
├─────────────────────────┤
│   [Player Vídeo 1]      │
│   (200px altura)        │
└─────────────────────────┘
Total: ~600px de altura
```

### Depois (Wrap - Horizontal)
```
┌────────┬────────┬────────┐
│ [Áudio]│ [Áudio]│ [Vídeo]│
│  56px  │  56px  │  56px  │
└────────┴────────┴────────┘
Total: ~56px de altura
```

## Benefícios

1. **Economia de Espaço**: Redução de ~90% na altura ocupada
2. **Melhor Visualização**: Layout horizontal mostra mais mídia simultaneamente
3. **UX Melhorada**: Players abrem em context apropriado (dialog)
4. **Consistência Visual**: Uso dos assets padronizados do app
5. **Responsivo**: Wrap adapta-se à largura disponível
6. **Flexibilidade**: Widgets podem ser usados com ou sem botão de exclusão

## Assets Utilizados
- `assets/image/audio.png` - Ícone para áudio
- `assets/image/video.png` - Ícone para vídeo

## Telas Afetadas
✅ Home (visualização de histórias)
✅ Edição de História
✅ Criação de História
✅ Histórias de Grupo

## Compatibilidade
- ✅ Windows (com fallback visual para vídeo)
- ✅ Android
- ✅ iOS
- ✅ Web

## Testes Necessários
- [ ] Clicar em ícone de áudio abre player
- [ ] Clicar em ícone de vídeo abre player em janela maior
- [ ] Botão X funciona na edição/criação
- [ ] Layout Wrap adapta-se a diferentes tamanhos de tela
- [ ] Assets carregam corretamente
- [ ] Fallback icons funcionam se assets faltarem
