import 'package:amp/core/models/entry.dart';
import 'package:amp/core/screens/main_screen.dart';
import 'package:amp/features/journal/screens/group_entry_detail_screen.dart';
import 'package:amp/features/journal/screens/journal_screen.dart';
import 'package:amp/features/journal/screens/product_entry_detail_screen.dart';
import 'package:amp/features/products/screens/add_product_screen.dart';
import 'package:amp/features/products/screens/product_detail_screen.dart';
import 'package:amp/features/products/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> appRoutes = [
  ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return MainScreen(child: child);
    },
    routes: [
      GoRoute(
        path: '/journal',
        builder: (context, state) => const JournalScreen(),
        routes: [
          GoRoute(
            path: '/group/:entryId',
            builder: (context, state) {
              final entryId = state.pathParameters['entryId']!;
              final entry = state.extra as GroupEntry?;
              return GroupEntryDetailScreen(entryId: entryId, entry: entry);
            },
          ),
          GoRoute(
            path: '/product/:entryId',
            builder: (context, state) {
              final entryId = state.pathParameters['entryId']!;
              final entry = state.extra as ProductEntry?;
              return ProductEntryDetailScreen(entryId: entryId, entry: entry);
            },
          ),
          // GoRoute(
          //   path: '/recipe/:entryId',
          //   builder: (context, state) {
          //     final entryId = state.pathParameters['entryId']!;
          //     final entry = state.extra as RecipeEntry?;
          //     return RecipeEntryDetailScreen(entryId: entryId, entry: entry);
          //   },
          // ),
        ],
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
        routes: [
          GoRoute(
            path: '/add',
            builder: (context, state) => const AddProductScreen(),
          ),
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
