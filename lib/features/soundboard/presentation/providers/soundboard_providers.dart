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

// Search Query State
// Search Query State
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

// Filtered Sounds Stream
final filteredSoundsProvider = Provider<AsyncValue<List<Sound>>>((ref) {
  final soundsAsync = ref.watch(soundsStreamProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  // Ensure proper AsyncValue handling:
  // whenData transforms the data if available, otherwise it propagates
  // the loading or error state of soundsAsync.
  return soundsAsync.whenData((sounds) {
    if (query.isEmpty) return sounds;
    return sounds.where((s) {
      return s.title.toLowerCase().contains(query) ||
          (s.uploaderName?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
});
