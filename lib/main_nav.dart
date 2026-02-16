import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../features/soundboard/presentation/pages/soundboard_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/soundboard/presentation/widgets/mini_player.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _pages = const [SoundboardPage(), UploadPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          // Positioned MiniPlayer above the bottom nav
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.plusCircle()),
            selectedIcon: Icon(
              PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
            ),
            label: 'Contribute',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.books()),
            selectedIcon: Icon(PhosphorIcons.books(PhosphorIconsStyle.fill)),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
