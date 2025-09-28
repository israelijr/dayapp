import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RichTextEditorScreen extends StatefulWidget {
  final String? initialText;

  const RichTextEditorScreen({super.key, this.initialText});

  @override
  State<RichTextEditorScreen> createState() => _RichTextEditorScreenState();
}

class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
  late TextEditingController _controller;
  double _dragOffset = 0.0;
  // Configurable threshold and return animation duration
  double _threshold = 120.0;
  Duration _returnDuration = const Duration(milliseconds: 250);
  bool _isAutoSaving = false;
  bool _showAutoSaveCheck = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the whole scaffold so we can translate it while dragging down
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Only consider downward drag
        if (details.delta.dy > 0) {
          setState(() {
            _dragOffset += details.delta.dy;
            // cap to screen height
            _dragOffset = _dragOffset.clamp(
              0.0,
              MediaQuery.of(context).size.height,
            );
          });
        }
      },
      onVerticalDragEnd: (details) async {
        // If dragged sufficiently far, auto-save (return text) and show check feedback
        if (_dragOffset > _threshold && !_isAutoSaving) {
          setState(() {
            _isAutoSaving = true;
            _showAutoSaveCheck = true;
          });

          // show check animation briefly before popping
          await Future.delayed(const Duration(milliseconds: 450));
          if (!mounted) return;
          Navigator.of(context).pop(_controller.text);
          return;
        }

        // otherwise animate back
        setState(() {
          _dragOffset = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: _returnDuration,
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: Builder(
          builder: (context) {
            final height = MediaQuery.of(context).size.height;
            final dragFraction = (height > 0)
                ? (_dragOffset / height).clamp(0.0, 1.0)
                : 0.0;
            final scale = 1.0 - (dragFraction * 0.05); // up to 5% shrink
            final overlayOpacity = _isAutoSaving
                ? 0.6
                : (_dragOffset / _threshold).clamp(0.0, 1.0) * 0.5;

            return Stack(
              children: [
                Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: Scaffold(
                    // Animated AppBar: fades and slides slightly based on drag
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: AnimatedOpacity(
                        opacity: 1.0 - (dragFraction * 0.95),
                        duration: const Duration(milliseconds: 120),
                        child: Transform.translate(
                          offset: Offset(0, -dragFraction * 20),
                          child: AppBar(
                            title: const Text('Editar Descrição'),
                            elevation: dragFraction > 0.02 ? 2 : 4,
                            actions: [
                              IconButton(
                                icon: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.asset(
                                    'assets/image/salvar.png',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.save, size: 20),
                                  ),
                                ),
                                onPressed: () async {
                                  // unified save: show check feedback then pop
                                  if (_isAutoSaving) return;
                                  setState(() {
                                    _isAutoSaving = true;
                                    _showAutoSaveCheck = true;
                                  });
                                  HapticFeedback.mediumImpact();
                                  await Future.delayed(
                                    const Duration(milliseconds: 350),
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pop(_controller.text);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Dark overlay that grows with drag, or is fixed during auto-save
                if (overlayOpacity > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        color: Colors.black.withOpacity(overlayOpacity),
                      ),
                    ),
                  ),
                // Animated check icon when auto-saving
                if (_showAutoSaveCheck)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isAutoSaving ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedScale(
                          scale: _isAutoSaving ? 1.0 : 0.6,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.check_circle,
                            size: 96,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// (duplicate dispose removed)
