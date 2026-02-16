import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart'; // For ProcessingState
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../data/models/sound_model.dart';
import '../../../../data/repositories/sound_repository.dart';
import '../providers/soundboard_providers.dart';
import '../../../../core/services/offline_service.dart';
import '../../../../core/services/favorites_service.dart';
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181818), // Flat dark surface
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Art Placeholder - FLAT COLOR instead of gradient
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFF282828,
                        ), // Lighter grey for placeholder
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sound.title.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),

                    // Loading Indicator (When buffering this specific sound)
                    StreamBuilder<Sound?>(
                      stream: audioService.currentSoundStream,
                      builder: (context, currentSoundSnapshot) {
                        final currentSound = currentSoundSnapshot.data;
                        if (currentSound?.id != sound.id)
                          return const SizedBox.shrink();

                        return StreamBuilder<ProcessingState>(
                          stream: audioService.processingStateStream,
                          builder: (context, stateSnapshot) {
                            final state = stateSnapshot.data;
                            final isLoading =
                                state == ProcessingState.buffering ||
                                state == ProcessingState.loading;

                            if (!isLoading) return const SizedBox.shrink();

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Favorites Button (Heart)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ValueListenableBuilder<Box>(
                        valueListenable: ref
                            .read(favoritesServiceProvider)
                            .listenable,
                        builder: (context, box, _) {
                          final isFavorite = ref
                              .read(favoritesServiceProvider)
                              .isFavorite(sound.id);
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              icon: Icon(
                                isFavorite
                                    ? PhosphorIcons.heart(
                                        PhosphorIconsStyle.fill,
                                      )
                                    : PhosphorIcons.heart(),
                                color: isFavorite ? Colors.green : Colors.white,
                              ),
                              onPressed: () {
                                ref
                                    .read(favoritesServiceProvider)
                                    .toggleFavorite(sound);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Download Button (Mobile Only) - Bottom Right
                    if (!kIsWeb)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: ValueListenableBuilder<Box>(
                          valueListenable: offlineService.downloadListenable,
                          builder: (context, box, _) {
                            final isDownloaded = box.containsKey(sound.id);
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  isDownloaded
                                      ? PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        )
                                      : PhosphorIcons.downloadSimple(),
                                  color: isDownloaded
                                      ? Colors.green
                                      : Colors.white,
                                ),
                                onPressed: () async {
                                  if (isDownloaded) {
                                    await offlineService.removeSound(sound.id);
                                  } else {
                                    await offlineService.downloadSound(sound);
                                  }
                                },
                              ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.user(),
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sound.uploaderName ?? 'Anonymous',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
