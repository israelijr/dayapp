import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../models/historia.dart';
import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia_foto.dart';

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

  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
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
    _loadFotos();
  }

  Future<void> _loadFotos() async {
    final fotosDb = await HistoriaFotoHelper().getFotosByHistoria(
      widget.historia.id ?? 0,
    );
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
        'descricao': _capitalizeText(descriptionController.text.trim()),
        'tag': tagsController.text.trim(),
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
    Navigator.pop(context, true);
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
                                  color: Colors.black54,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
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
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                keyboardType: TextInputType.text,
                enableSuggestions: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separadas por vírgula)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
