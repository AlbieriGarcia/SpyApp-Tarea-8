import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spy_20220004/sql_helper.dart';
import 'detail_screen.dart';
import 'about_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  String? _audioPath;

  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  final TextEditingController _audioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text, _fotoController.text, _audioController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text, _fotoController.text, _audioController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Se ha borrado correctamente'),
    ));
    _refreshJournals();
  }

  void _deleteAllItems() async {
    await SQLHelper.deleteAllItems();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Se han borrado todos los elementos'),
    ));
    _refreshJournals();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _fotoController.text = _imagePath!;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
        _audioController.text = _audioPath!;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_imagePath == null || _imagePath!.isEmpty) {
      return Image.asset(
        'assets/images/not_image.png', // Ruta de la imagen por defecto en tus activos
        height: 200,
      );
    } else {
      return Image.file(File(_imagePath!), height: 200);
    }
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['titulo'];
      _descriptionController.text = existingJournal['descripcion'];
      _fotoController.text = existingJournal['foto'];
      _audioController.text = existingJournal['audio'];
      _imagePath = existingJournal['foto'];
      _audioPath = existingJournal['audio'];
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _fotoController.clear();
      _audioController.clear();
      _imagePath = null;
      _audioPath = null;
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Titulo'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: 'Descripción'),
                ),
                const SizedBox(height: 10),
                _buildImagePreview(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _imagePath = image.path;
                        _fotoController.text = _imagePath!;
                      });
                    }
                  },
                  child: const Text('Seleccionar Imagen'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _pickAudio();
                  },
                  child: const Text('Seleccionar Audio'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await _addItem();
                    } else {
                      await _updateItem(id);
                    }
                    _titleController.text = '';
                    _descriptionController.text = '';
                    _fotoController.text = '';
                    _audioController.text = '';
                    _imagePath = null;
                    _audioPath = null;

                    Navigator.of(context).pop();
                  },
                  child: Text(id == null ? 'Crear' : 'Actualizar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDetails(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(item: item),
      ),
    );
  }

  void _showAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Spy'),
        actions: [
          Text('Acerca de'),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.blueGrey[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_journals[index]['titulo']),
                  subtitle: Text(_journals[index]['descripcion']),
                  trailing: Wrap(
                    spacing: 4, // Spacing between icons
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () => _showDetails(_journals[index]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(_journals[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(_journals[index]['id']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _deleteAllItems,
              child: const Text('Borrar Todos los Elementos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Botón de color rojo
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
