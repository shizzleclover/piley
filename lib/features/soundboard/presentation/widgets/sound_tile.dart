import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../data/models/sound_model.dart';
import '../../../../data/repositories/sound_repository.dart';
import '../providers/soundboard_providers.dart';
import '../../../../core/services/offline_service.dart';
import '../../../../core/services/audio_service.dart';

class SoundTile extends ConsumerWidget {
  final Sound sound;

  const SoundTile({super.key, required this.sound});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);
    final offlineService = ref.watch(offlineServiceProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          audioService.playSound(sound);
          ref.read(soundRepositoryProvider).incrementPlayCount(sound.id);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Art Placeholder
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade800,
                            Colors.deepPurple.shade900,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sound.title.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    // Download Button
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: ValueListenableBuilder<Box>(
                        valueListenable: offlineService.downloadListenable,
                        builder: (context, box, _) {
                          final isDownloaded = box.containsKey(sound.id);
                          return IconButton(
                            icon: Icon(
                              isDownloaded
                                  ? PhosphorIcons.checkCircle(
                                      PhosphorIconsStyle.fill,
                                    )
                                  : PhosphorIcons.downloadSimple(),
                              color: isDownloaded
                                  ? Colors.green
                                  : Colors.white70,
                            ),
                            onPressed: () async {
                              if (isDownloaded) {
                                await offlineService.removeSound(sound.id);
                              } else {
                                await offlineService.downloadSound(sound);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Metadata
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sound.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Piley Sound',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
