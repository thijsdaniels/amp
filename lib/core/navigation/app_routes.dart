import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amp/core/screens/main_screen.dart';
import 'package:amp/features/journal/screens/journal_screen.dart';
import 'package:amp/features/products/screens/products_screen.dart';
import 'package:amp/features/products/screens/add_product_screen.dart';
import 'package:amp/features/products/screens/product_detail_screen.dart';

final List<RouteBase> appRoutes = [
  ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return MainScreen(child: child);
    },
    routes: [
      // Journal route
      GoRoute(
        path: '/journal',
        builder: (context, state) => const JournalScreen(),
      ),

      // Products routes
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
        routes: [
          // Add product route
          GoRoute(
            path: '/add',
            builder: (context, state) => const AddProductScreen(),
          ),
          // Product detail route
          GoRoute(
            path: '/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return ProductDetailScreen(productId: productId);
            },
          ),
        ],
      ),
    ],
  ),
];
