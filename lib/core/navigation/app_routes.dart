import 'package:amp/core/screens/main_screen.dart';
import 'package:amp/features/journal/screens/group_entry_detail_screen.dart';
import 'package:amp/features/journal/screens/journal_screen.dart';
import 'package:amp/features/journal/screens/product_entry_detail_screen.dart';
import 'package:amp/features/products/screens/add_product_screen.dart';
import 'package:amp/features/products/screens/edit_product_screen.dart';
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
              return GroupEntryDetailScreen(entryId: entryId);
            },
          ),
          GoRoute(
            path: '/product/:entryId',
            builder: (context, state) {
              final entryId = state.pathParameters['entryId']!;
              return ProductEntryDetailScreen(entryId: entryId);
            },
          ),
          // GoRoute(
          //   path: '/recipe/:entryId',
          //   builder: (context, state) {
          //     final entryId = state.pathParameters['entryId']!;
          //     return RecipeEntryDetailScreen(entryId: entryId);
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
            builder: (context, state) {
              // Extract UPC from query parameters if present
              final upc = state.uri.queryParameters['upc'];
              return AddProductScreen(prefilledUpc: upc);
            },
          ),
          GoRoute(
            path: '/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return ProductDetailScreen(productId: productId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return EditProductScreen(productId: productId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
