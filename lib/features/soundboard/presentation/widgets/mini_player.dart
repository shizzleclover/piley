import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../data/models/sound_model.dart';
import '../providers/soundboard_providers.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);

    return StreamBuilder<Sound?>(
      stream: audioService.currentSoundStream,
      builder: (context, snapshot) {
        final sound = snapshot.data;
        if (sound == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF282828), // Dark grey
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Album Art Placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(PhosphorIcons.musicNote(), color: Colors.white70),
              ),
              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sound.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Piley Sound',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              StreamBuilder<PlayerState>(
                stream: audioService.playerStateStream,
                builder: (context, stateSnapshot) {
                  final playing = stateSnapshot.data?.playing ?? false;
                  return IconButton(
                    icon: Icon(
                      playing
                          ? PhosphorIcons.pause(PhosphorIconsStyle.fill)
                          : PhosphorIcons.play(PhosphorIconsStyle.fill),
                    ),
                    color: Colors.white,
                    onPressed: () => audioService.togglePlayPause(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
