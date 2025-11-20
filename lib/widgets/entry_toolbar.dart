import 'package:flutter/material.dart';

class EntryToolbar extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onRecordAudio;
  final VoidCallback onSelectEmoji;

  const EntryToolbar({
    super.key,
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onRecordAudio,
    required this.onSelectEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              onPressed: onPickPhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: 'Foto',
            ),
            IconButton.filledTonal(
              onPressed: onPickVideo,
              icon: const Icon(Icons.videocam_outlined),
              tooltip: 'Vídeo',
            ),
            IconButton.filledTonal(
              onPressed: onRecordAudio,
              icon: const Icon(Icons.mic_none_outlined),
              tooltip: 'Áudio',
            ),
            IconButton.filledTonal(
              onPressed: onSelectEmoji,
              icon: const Icon(Icons.add_reaction_outlined),
              tooltip: 'Emoji',
            ),
          ],
        ),
      ),
    );
  }
}
