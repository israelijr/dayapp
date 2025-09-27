import 'package:flutter/material.dart';

class RichTextEditorScreen extends StatefulWidget {
  final String? initialText;

  const RichTextEditorScreen({super.key, this.initialText});

  @override
  State<RichTextEditorScreen> createState() => _RichTextEditorScreenState();
}

class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Descrição'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ),
    );
  }
}
