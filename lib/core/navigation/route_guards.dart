import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Route guard interface
abstract class RouteGuard {
  Future<bool> canActivate(BuildContext context, GoRouterState state);
  String get redirectPath;
}

// Authentication guard (placeholder for future implementation)
class AuthGuard implements RouteGuard {
  @override
  Future<bool> canActivate(BuildContext context, GoRouterState state) async {
    // TODO: Implement actual authentication check
    // For now, always return true (no auth required)
    return true;
  }

  @override
  String get redirectPath => '/login'; // Future login route
}

// Admin guard (placeholder for future implementation)
class AdminGuard implements RouteGuard {
  @override
  Future<bool> canActivate(BuildContext context, GoRouterState state) async {
    // TODO: Implement admin role check
    return true;
  }

  @override
  String get redirectPath => '/unauthorized';
}

// Route guard utilities
class RouteGuardUtils {
  static Future<String?> checkGuards(
    BuildContext context,
    GoRouterState state,
    List<RouteGuard> guards,
  ) async {
    for (final guard in guards) {
      final canActivate = await guard.canActivate(context, state);
      if (!canActivate) {
        return guard.redirectPath;
      }
    }
    return null;
  }
}
