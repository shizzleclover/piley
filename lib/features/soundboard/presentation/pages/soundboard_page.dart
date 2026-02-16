import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/soundboard_providers.dart';
import '../widgets/sound_tile.dart';

class SoundboardPage extends ConsumerWidget {
  const SoundboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsAsync = ref.watch(soundsStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Piley',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.magnifyingGlass()),
            onPressed: () {},
          ),
          IconButton(icon: Icon(PhosphorIcons.gear()), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1DB954), // Spotify Green - faint at top
              Color(0xFF121212), // Dark
              Color(0xFF121212),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: soundsAsync.when(
          data: (sounds) {
            if (sounds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.smileySad(),
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No sounds yet',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.only(
                top: 100,
                bottom: 100,
              ), // Space for AppBar and MiniPlayer
              children: [
                // "Recently Played" or similar header could go here
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Fresh Sounds',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Grid
                GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: sounds.length,
                  itemBuilder: (context, index) =>
                      SoundTile(sound: sounds[index]),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
