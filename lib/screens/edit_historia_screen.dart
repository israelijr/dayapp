import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../models/historia.dart';
import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia_foto.dart';
import 'package:flutter/services.dart';
import 'rich_text_editor_screen.dart';
// ...existing code...

class SentenceCapitalizationTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String _capitalizeText(String text) {
      if (text.isEmpty) return text;
      // Capitalize first letter
      String result =
          text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
      // Capitalize after sentence endings
      result = result.replaceAllMapped(RegExp(r'([.!?]\s*)([a-z])'), (match) {
        return match.group(1)! + match.group(2)!.toUpperCase();
      });
      return result;
    }

    final capitalized = _capitalizeText(newValue.text);
    return newValue.copyWith(text: capitalized, selection: newValue.selection);
  }
}

class EditHistoriaScreen extends StatefulWidget {
  final Historia historia;
  const EditHistoriaScreen({super.key, required this.historia});

  @override
  State<EditHistoriaScreen> createState() => _EditHistoriaScreenState();
}

class _EditHistoriaScreenState extends State<EditHistoriaScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController tagsController;
  late DateTime selectedDate;
  List<Uint8List> fotos = [];
  List<int> fotoIds = [];
  String? selectedEmoticon;

  final List<String> emoticons = [
    'Feliz',
    'Tranquilo',
    'Aliviado',
    'Pensativo',
    'Sono',
    'Preocupado',
    'Assustado',
    'Bravo',
    'Triste',
    'Muito Triste',
  ];

  String _getEmoticonImage(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '1_feliz.png';
      case 'Tranquilo':
        return '2_tranquilo.png';
      case 'Aliviado':
        return '3_aliviado.png';
      case 'Pensativo':
        return '4_pensativo.png';
      case 'Sono':
        return '5_sono.png';
      case 'Preocupado':
        return '6_preocupado.png';
      case 'Assustado':
        return '7_assustado.png';
      case 'Bravo':
        return '8_bravo.png';
      case 'Triste':
        return '9_triste.png';
      case 'Muito Triste':
        return '10_muito_triste.png';
      default:
        return '1_feliz.png';
    }
  }

  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    // Capitalize first letter
    String result =
        text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
    // Capitalize after sentence endings
    result = result.replaceAllMapped(RegExp(r'([.!?]\s*)([a-z])'), (match) {
      return match.group(1)! + match.group(2)!.toUpperCase();
    });
    return result;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.historia.titulo);
    descriptionController = TextEditingController(
      text: widget.historia.descricao ?? '',
    );
    tagsController = TextEditingController(text: widget.historia.tag ?? '');
    selectedDate = widget.historia.data;
    selectedEmoticon = widget.historia.emoticon;
    _loadFotos();
  }

  Future<void> _loadFotos() async {
    final fotosDb = await HistoriaFotoHelper().getFotosByHistoria(
      widget.historia.id ?? 0,
    );
    if (!mounted) return;
    setState(() {
      fotos = fotosDb.map((f) => Uint8List.fromList(f.foto)).toList();
      fotoIds = fotosDb.map((f) => f.id ?? 0).toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        fotos.add(bytes);
        fotoIds.add(0); // 0 indica nova foto
      });
    }
  }

  void _removeFoto(int index) async {
    if (fotoIds[index] != 0) {
      final db = await DatabaseHelper().database;
      await db.delete(
        'historia_fotos',
        where: 'id = ?',
        whereArgs: [fotoIds[index]],
      );
    }
    if (!mounted) return;
    setState(() {
      fotos.removeAt(index);
      fotoIds.removeAt(index);
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'titulo': _capitalizeText(titleController.text.trim()),
        'descricao': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        'tag': tagsController.text.trim().isEmpty
            ? null
            : tagsController.text.trim(),
        'emoticon': selectedEmoticon,
        'data': selectedDate.toIso8601String(),
        'data_update': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [widget.historia.id],
    );
    // Salva novas fotos
    for (int i = 0; i < fotos.length; i++) {
      if (fotoIds[i] == 0) {
        await HistoriaFotoHelper().insertFoto(
          HistoriaFoto(historiaId: widget.historia.id ?? 0, foto: fotos[i]),
        );
      }
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _expandDescriptionEditor() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) =>
            RichTextEditorScreen(initialText: descriptionController.text),
      ),
    );
    if (result != null) {
      if (!mounted) return;
      setState(() {
        descriptionController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar História'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i < fotos.length) {
                      final double w = 100 - (i % 2) * 30;
                      final double h = 100 - ((i + 1) % 2) * 20;
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              fotos[i],
                              width: w,
                              height: h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeFoto(i),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]
                                      : Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.deepPurple,
                            size: 32,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateFormat.format(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.deepPurple,
                    ),
                    onPressed: _pickDateTime,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [SentenceCapitalizationTextInputFormatter()],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: _expandDescriptionEditor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        // Simple multiline text field for description
                        Expanded(
                          child: TextField(
                            controller: descriptionController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(8),
                              border: InputBorder.none,
                            ),
                            inputFormatters: [
                              SentenceCapitalizationTextInputFormatter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separadas por vírgula)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecione um Emoticon:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: emoticons
                    .map(
                      (emoticon) => GestureDetector(
                        onTap: () =>
                            setState(() => selectedEmoticon = emoticon),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedEmoticon == emoticon
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/image/${_getEmoticonImage(emoticon)}',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
