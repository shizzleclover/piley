import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/soundboard_providers.dart';
import '../widgets/sound_tile.dart';
import '../../../../features/upload/presentation/pages/upload_page.dart';

class SoundboardPage extends ConsumerStatefulWidget {
  const SoundboardPage({super.key});

  @override
  ConsumerState<SoundboardPage> createState() => _SoundboardPageState();
}

class _SoundboardPageState extends ConsumerState<SoundboardPage> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
    if (!_isSearching) {
      _searchController.clear();
      ref.read(searchQueryProvider.notifier).update('');
    }
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).update(query);
  }

  void _navigateToAddSound(String query) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UploadPage(initialTitle: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soundsAsync = ref.watch(filteredSoundsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search sounds...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'Piley',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching
                  ? PhosphorIcons.x()
                  : PhosphorIcons.magnifyingGlass(),
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF121212),
        child: Stack(
          children: [
            // Content
            soundsAsync.when(
              data: (sounds) {
                if (sounds.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.magnifyingGlass(
                              PhosphorIconsStyle.duotone,
                            ),
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No sounds yet'
                                : 'No results for "$searchQuery"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                          if (searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => _navigateToAddSound(searchQuery),
                              icon: Icon(PhosphorIcons.plus()),
                              label: const Text('Add This Sound'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1DB954),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(
                                  200,
                                  48,
                                ), // Pill shape often looks better slightly larger
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Can't find it? Upload it yourself!",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(top: 100, bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        searchQuery.isEmpty ? 'New Sounds' : 'Search Results',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
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
          ],
        ),
      ),
    );
  }
}
