import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/groceries/screens/groceries_screen.dart';
import '../../features/routine/screens/routine_screen.dart';
import '../../features/upcoming/screens/upcoming_screen.dart';
import '../../shared/widgets/shell_scaffold.dart';

const _navRoutes = ['/', '/groceries', '/routines', '/upcoming'];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            ShellScaffold(state: state, child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/groceries',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GroceriesScreen()),
          ),
          GoRoute(
            path: '/routines',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RoutineScreen()),
          ),
          GoRoute(
            path: '/upcoming',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UpcomingScreen()),
          ),
        ],
      ),
    ],
  );
});

int locationToIndex(String location) {
  final idx = _navRoutes.indexWhere(
    (r) => r == '/' ? location == '/' : location.startsWith(r),
  );
  return idx < 0 ? 0 : idx;
}

String indexToLocation(int index) =>
    index < _navRoutes.length ? _navRoutes[index] : _navRoutes[0];
