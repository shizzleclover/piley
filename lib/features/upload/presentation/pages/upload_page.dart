import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'package:uuid/uuid.dart';
import '../../../soundboard/presentation/providers/soundboard_providers.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final _titleController = TextEditingController();
  final _audioRecorder = AudioRecorder();

  String? _filePath;
  bool _isRecording = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
    } else {
      // Start recording
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/${const Uuid().v4()}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _filePath = null; // Clear previous file
        });
      }
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _filePath == null) return;

    setState(() => _isUploading = true);

    try {
      final repository = ref.read(soundRepositoryProvider);

      // Upload using repository (handles Storage + DB)
      await repository.uploadSound(_titleController.text, File(_filePath!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sound uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Sound')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Sound Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pick File'),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : null,
                    foregroundColor: _isRecording ? Colors.white : null,
                  ),
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Recording' : 'Record Mic'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_filePath != null)
              Text(
                'Selected: ${_filePath!.split('/').last}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _isUploading ||
                        _filePath == null ||
                        _titleController.text.isEmpty
                    ? null
                    : _upload,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Sound'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
