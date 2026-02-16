import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/models/sound_model.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // BehaviorSubject to hold the current playing sound metadata
  final _currentSoundSubject = BehaviorSubject<Sound?>();
  Stream<Sound?> get currentSoundStream => _currentSoundSubject.stream;

  // Stream for player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  // Play audio from a URL and track current sound
  Future<void> playSound(Sound sound) async {
    try {
      _currentSoundSubject.add(sound); // Update UI immediately

      if (_player.playing) {
        await _player.stop();
      }

      // On Web, always use URL. On mobile, check local file.
      if (!kIsWeb &&
          sound.localPath != null &&
          File(sound.localPath!).existsSync()) {
        await _player.setFilePath(sound.localPath!);
      } else {
        await _player.setUrl(sound.filePath);
      }
      await _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  // Toggle Play/Pause
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // Stop current playback
  Future<void> stop() async {
    await _player.stop();
    _currentSoundSubject.add(null);
  }

  // Dispose player resources
  void dispose() {
    _player.dispose();
    _currentSoundSubject.close();
  }
}
