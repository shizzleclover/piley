import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb, Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart'; // Note: record package might need specific web setup or fallback
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../soundboard/presentation/providers/soundboard_providers.dart';

class UploadPage extends ConsumerStatefulWidget {
  final String? initialTitle;
  const UploadPage({super.key, this.initialTitle});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  late final TextEditingController _titleController;
  final _nameController = TextEditingController(); // Uploader name
  final _audioRecorder = AudioRecorder();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  // For Web/Mobile compatibility
  String? _filePath; // Mobile only
  Uint8List? _fileBytes; // Web & Mobile
  String? _fileName; // For extension

  bool _isRecording = false;
  bool _isUploading = false;
  bool _isHovering = false; // For a bit of fluidity (if we used MouseRegion)

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // Important for Web
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        _filePath = file.path;
        _fileBytes = file.bytes;
        _fileName = file.name;

        // On mobile, file.bytes might be null if we don't force it,
        // but file.path is there. On web, path is useless, bytes are key.
        if (!kIsWeb && _filePath != null && _fileBytes == null) {
          // Read bytes from file path for consistency in repository
          _fileBytes = File(_filePath!).readAsBytesSync();
        }
      });
    }
  }

  Future<void> _toggleRecording() async {
    // Recording on Web requires different handling and permission flows.
    // For this iteration, let's focus on File Upload fix for Web,
    // and keep Recording for Mobile/Desktop if possible.
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Direct recording not supported on Web yet. Please pick a file.',
          ),
        ),
      );
      return;
    }

    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        setState(() {
          _isRecording = false;
          _filePath = path;
          _fileBytes = bytes;
          _fileName = 'recording.m4a';
        });
      } else {
        setState(() => _isRecording = false);
      }
    } else {
      // Start recording
      bool hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/${const Uuid().v4()}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _filePath = null;
          _fileBytes = null;
        });
      }
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _fileBytes == null) return;

    setState(() => _isUploading = true);

    try {
      final repository = ref.read(soundRepositoryProvider);

      final ext = _fileName?.split('.').last ?? 'm4a';

      await repository.uploadSound(
        title: _titleController.text,
        fileBytes: _fileBytes!,
        fileExtension: ext,
        uploaderName: _nameController.text.isNotEmpty
            ? _nameController.text
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sound uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cleaner UI style
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1DB954), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contribute Sound',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Share a sound with the world.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration.copyWith(
                  labelText: 'Sound Title',
                  prefixIcon: Icon(PhosphorIcons.tag(), color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration.copyWith(
                  labelText: 'Your Name (Optional)',
                  prefixIcon: Icon(PhosphorIcons.user(), color: Colors.grey),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _SelectionCard(
                      icon: PhosphorIcons.uploadSimple(),
                      label: 'Pick File',
                      onTap: _isRecording ? null : _pickFile,
                      isSelected:
                          !_isRecording &&
                          _fileBytes != null &&
                          _fileName != 'recording.m4a',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SelectionCard(
                      icon: _isRecording
                          ? PhosphorIcons.stop()
                          : PhosphorIcons.microphone(),
                      label: _isRecording ? 'Stop' : 'Record',
                      onTap: _toggleRecording,
                      isSelected:
                          _isRecording ||
                          (_fileBytes != null && _fileName == 'recording.m4a'),
                      isActive: _isRecording,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_fileName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.fileAudio(),
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fileName!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 48),

              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed:
                      _isUploading ||
                          _fileBytes == null ||
                          _titleController.text.isEmpty
                      ? null
                      : _upload,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // Pill shape
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Upload Sound',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isActive;

  const _SelectionCard({
    required this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Colors.red
        : (isSelected ? const Color(0xFF1DB954) : Colors.white);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.red.withOpacity(0.1)
              : (isSelected
                    ? const Color(0xFF1DB954).withOpacity(0.1)
                    : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.red
                : (isSelected ? const Color(0xFF1DB954) : Colors.transparent),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
