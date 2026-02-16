import 'dart:io';
import 'package:flutter/foundation.dart'; // For Uint8List and kIsWeb
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
                  uploaderName: sound.uploaderName,
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
  // Accepting bytes allows this to work on Web where File path is not available/usable
  Future<void> uploadSound({
    required String title,
    required Uint8List fileBytes,
    required String fileExtension,
    String? uploaderName,
  }) async {
    // 1. Upload to Supabase Storage
    final fileName = '${const Uuid().v4()}.$fileExtension';

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
    // Use null for uploader_id if not logged in (requires uploader_id to be nullable in DB)
    final userId = _client.auth.currentUser?.id;

    await _client.from('sounds').insert({
      'title': title,
      'file_path': publicUrl,
      'uploader_id': userId,
      'uploader_name': uploaderName,
    });
  }

  // Increment play count
  Future<void> incrementPlayCount(String soundId) async {
    // Best effort - might fail without RLS policy for Update
    try {
      await _client.rpc('increment_play_count', params: {'sound_id': soundId});
    } catch (e) {
      // Ignore errors for now, play count is vanity
    }
  }
}
