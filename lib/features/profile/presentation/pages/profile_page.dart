import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/models/sound_model.dart';
import '../../../soundboard/presentation/widgets/sound_tile.dart';

// Provider for user's own sounds
final userSoundsProvider = StreamProvider<List<Sound>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return Stream.value([]);

  return Supabase.instance.client
      .from('sounds')
      .stream(primaryKey: ['id'])
      .eq('uploader_id', userId)
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => Sound.fromMap(json)).toList());
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final soundsAsync = ref.watch(userSoundsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(
              (user?.email != null && user!.email!.isNotEmpty)
                  ? user.email!.substring(0, 1).toUpperCase()
                  : 'U',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'User ID: ${user?.id.substring(0, 6)}...', // Displaying part of ID
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 48),
          Expanded(
            child: soundsAsync.when(
              data: (sounds) {
                if (sounds.isEmpty) {
                  return const Center(
                    child: Text('You haven\'t uploaded any sounds yet.'),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sounds.length,
                  itemBuilder: (context, index) {
                    return SoundTile(sound: sounds[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
