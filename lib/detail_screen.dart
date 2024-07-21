import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.item['audio']));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format createdAt date
    DateTime createdAt = DateTime.parse(widget.item['createdAt']);
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.item['titulo']),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item['titulo'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (widget.item['foto'] != null && widget.item['foto'].isNotEmpty)
                Image.file(File(widget.item['foto']), height: 200),
              const SizedBox(height: 20),
              Text(
                widget.item['descripcion'],
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Creado el: $formattedDate',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Conditionally render the audio controls or a text message
              if (widget.item['audio'] != null && widget.item['audio'].isNotEmpty)
                ElevatedButton(
                  onPressed: _playPauseAudio,
                  child: Text(_isPlaying ? 'Pausar' : 'Reproducir Audio'),
                )
              else
                Text('No se ha seleccionado un audio', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
