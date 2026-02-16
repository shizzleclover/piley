import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/soundboard/presentation/pages/soundboard_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/soundboard/presentation/widgets/mini_player.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const AppShell();
        } else {
          return const OnboardingPage();
        }
      },
    );
  }
}

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
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.user()),
            selectedIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
