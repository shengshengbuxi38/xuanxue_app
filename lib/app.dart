import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'shared/providers/auth_provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/bazi/bazi_screen.dart';
import 'features/dayun/dayun_screen.dart';
import 'features/knowledge/knowledge_screen.dart';
import 'features/advanced/advanced_screen.dart';
import 'features/archive/archive_screen.dart';
import 'features/history/history_screen.dart';
import 'features/feedback/feedback_screen.dart';
import 'features/about/about_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/bazi',
    redirect: (context, state) {
      final loggedIn = auth.valueOrNull != null;
      final isAuth = state.matchedLocation == '/auth';
      if (!loggedIn && !isAuth) return '/auth';
      if (loggedIn && isAuth) return '/bazi';
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (_, _) => const AuthScreen()),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(path: '/bazi', builder: (_, _) => const BaziScreen()),
          GoRoute(path: '/dayun', builder: (_, _) => const DayunScreen()),
          GoRoute(path: '/advanced', builder: (_, _) => const AdvancedScreen()),
          GoRoute(path: '/archive', builder: (_, _) => const ArchiveScreen()),
          GoRoute(path: '/knowledge', builder: (_, _) => const KnowledgeScreen()),
          GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
          GoRoute(path: '/feedback', builder: (_, _) => const FeedbackScreen()),
          GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
        ],
      ),
    ],
  );
});

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '排盘'),
          NavigationDestination(icon: Icon(Icons.timeline), label: '大运'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: '高级'),
          NavigationDestination(icon: Icon(Icons.folder), label: '档案'),
          NavigationDestination(icon: Icon(Icons.person), label: '我的'),
        ],
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (i) => _onTap(context, i),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/bazi')) return 0;
    if (loc.startsWith('/dayun')) return 1;
    if (loc.startsWith('/advanced')) return 2;
    if (loc.startsWith('/archive') || loc.startsWith('/knowledge') || loc.startsWith('/history')) return 3;
    return 4;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/bazi');
      case 1: context.go('/dayun');
      case 2: context.go('/advanced');
      case 3: context.go('/archive');
      case 4: _showMyMenu(context);
    }
  }

  void _showMyMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.history), title: const Text('历史记录'), onTap: () { Navigator.pop(ctx); context.go('/history'); }),
            ListTile(leading: const Icon(Icons.menu_book), title: const Text('知识库'), onTap: () { Navigator.pop(ctx); context.go('/knowledge'); }),
            ListTile(leading: const Icon(Icons.feedback), title: const Text('用户反馈'), onTap: () { Navigator.pop(ctx); context.go('/feedback'); }),
            ListTile(leading: const Icon(Icons.info), title: const Text('缘起'), onTap: () { Navigator.pop(ctx); context.go('/about'); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('退出登录', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); context.go('/auth'); }),
          ],
        ),
      ),
    );
  }
}
