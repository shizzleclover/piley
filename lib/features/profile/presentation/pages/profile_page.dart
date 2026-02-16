import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/models/sound_model.dart';
import '../../../soundboard/presentation/widgets/sound_tile.dart';
import '../../../../core/services/favorites_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesService = ref.watch(favoritesServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites'), centerTitle: false),
      body: ValueListenableBuilder<Box>(
        valueListenable: favoritesService.listenable,
        builder: (context, box, _) {
          final sounds = favoritesService.getFavorites();

          if (sounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.duotone),
                    size: 64,
                    color: Colors.grey.shade800,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the heart on a sound to save it here!',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              return SoundTile(sound: sounds[index]);
            },
          );
        },
      ),
    );
  }
}
