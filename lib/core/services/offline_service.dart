import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../data/models/sound_model.dart';

class OfflineService {
  static const String boxName = 'offline_sounds';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  // Stream of downloaded sound IDs
  ValueListenable<Box> get downloadListenable => Hive.box(boxName).listenable();

  // Get all offline sounds
  List<Sound> getOfflineSounds() {
    final box = Hive.box(boxName);
    return box.values.map((e) {
      final map = Map<String, dynamic>.from(e);
      return Sound.fromMap(map);
    }).toList();
  }

  // Check if a sound is downloaded
  bool isSoundOffline(String soundId) {
    final box = Hive.box(boxName);
    return box.containsKey(soundId);
  }

  // Download a sound
  Future<void> downloadSound(Sound sound) async {
    try {
      final box = Hive.box(boxName);

      // 1. Download file
      final response = await http.get(Uri.parse(sound.filePath));
      if (response.statusCode != 200) throw Exception('Failed to download');

      final dir = await getApplicationDocumentsDirectory();
      final fileExt = sound.filePath
          .split('.')
          .last
          .split('?')
          .first; // Handle query params if any
      final localFile = File('${dir.path}/${sound.id}.$fileExt');
      await localFile.writeAsBytes(response.bodyBytes);

      // 2. Save metadata + local path
      final soundMap = sound.toMap();
      soundMap['localPath'] = localFile.path;

      await box.put(sound.id, soundMap);
    } catch (e) {
      print('Download error: $e');
      rethrow;
    }
  }

  // Remove download
  Future<void> removeSound(String soundId) async {
    final box = Hive.box(boxName);
    final map = box.get(soundId);
    if (map != null) {
      final localPath = map['localPath'];
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await box.delete(soundId);
    }
  }
}

final offlineServiceProvider = Provider<OfflineService>(
  (ref) => OfflineService(),
);
