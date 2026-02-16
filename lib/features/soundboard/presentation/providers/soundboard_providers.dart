import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../data/repositories/sound_repository.dart';
import '../../../../data/models/sound_model.dart';

// Repository Provider
final soundRepositoryProvider = Provider<SoundRepository>((ref) {
  return SoundRepository();
});

// Audio Service Provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// Stream of sounds (Realtime!)
final soundsStreamProvider = StreamProvider<List<Sound>>((ref) {
  final repository = ref.watch(soundRepositoryProvider);
  return repository.getSoundsStream();
});

// Currently Playing State (Optional, for now just fire and forget or simple tracking)
// For MVP, we play directly via AudioService.
