import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/app/router.dart';
import 'package:ophthal_vivaedge/app/theme.dart';
import 'package:ophthal_vivaedge/viewmodels/settings_viewmodel.dart';

class OphthalVivaEdgeApp extends ConsumerWidget {
  const OphthalVivaEdgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsViewModelProvider);

    return MaterialApp.router(
      title: 'Ophthal VivaEdge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
