import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sound_model.dart';
import '../../core/services/offline_service.dart';

class SoundRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final OfflineService _offlineService = OfflineService();

  // Stream all sounds + merge local info
  Stream<List<Sound>> getSoundsStream() {
    return _client
        .from('sounds')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          final onlineSounds = data.map((json) {
            final sound = Sound.fromMap(json);

            // Check if available offline
            if (_offlineService.isSoundOffline(sound.id)) {
              final offlineSoundMap = Hive.box(
                OfflineService.boxName,
              ).get(sound.id);
              if (offlineSoundMap != null &&
                  offlineSoundMap['localPath'] != null) {
                // Return new instance with localPath
                return Sound(
                  id: sound.id,
                  title: sound.title,
                  filePath: sound.filePath,
                  localPath: offlineSoundMap['localPath'],
                  uploaderId: sound.uploaderId,
                  playCount: sound.playCount,
                  createdAt: sound.createdAt,
                );
              }
            }
            return sound;
          }).toList();
          return onlineSounds;
        });
  }

  // Upload sound file and metadata
  Future<void> uploadSound(String title, File file) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated. Please restart the app.');
    }

    // 1. Upload to Supabase Storage
    final fileExt = file.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$fileExt';
    final fileBytes = await file.readAsBytes();

    await _client.storage
        .from('sounds')
        .uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const FileOptions(upsert: false),
        );

    // 2. Get Public URL
    final publicUrl = _client.storage.from('sounds').getPublicUrl(fileName);

    // 3. Insert metadata
    await _client.from('sounds').insert({
      'title': title,
      'file_path': publicUrl,
      'uploader_id': user.id,
    });
  }

  // Increment play count
  Future<void> incrementPlayCount(String soundId) async {
    // Best effort
  }
}
