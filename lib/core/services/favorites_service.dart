import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/sound_model.dart';

class FavoritesService {
  static const String boxName = 'favorite_sounds';

  Future<void> init() async {
    // Hive should already be initialized in main or OfflineService,
    // but opening the box is idempotent safe usually.
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  // Stream of favorite sounds
  ValueListenable<Box> get listenable => Hive.box(boxName).listenable();

  // Get all favorites
  List<Sound> getFavorites() {
    final box = Hive.box(boxName);
    return box.values.map((e) {
      final map = Map<String, dynamic>.from(e);
      return Sound.fromMap(map);
    }).toList();
  }

  // Check if favorite
  bool isFavorite(String soundId) {
    if (!Hive.isBoxOpen(boxName)) return false;
    final box = Hive.box(boxName);
    return box.containsKey(soundId);
  }

  // Toggle favorite
  Future<void> toggleFavorite(Sound sound) async {
    final box = Hive.box(boxName);
    if (box.containsKey(sound.id)) {
      await box.delete(sound.id);
    } else {
      await box.put(sound.id, sound.toMap());
    }
  }
}

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});
