import 'package:flutter/material.dart';
import 'package:widgets_easier/theme.dart';

import 'admin/admin_shell.dart';
import 'app/routes.dart';
import 'theme_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Installs [WeTheme] on top of [base] with [brand] as the primary colour.
  ///
  /// This is the whole integration story for Widgets Easier: one extension on
  /// the `ThemeData` you already have.
  ThemeData _withWeTheme(ThemeData base, WeTheme we, Color brand) {
    return base.copyWith(
      extensions: [we.copyWith(colors: we.colors.copyWith(primary: brand))],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, mode, _) => ValueListenableBuilder(
        valueListenable: brandColor,
        builder: (context, brand, _) => MaterialApp(
          title: '云集商城 · 商家运营后台',
          themeMode: mode,
          routes: routes,
          theme: _withWeTheme(
            ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: brand),
              useMaterial3: true,
            ),
            const WeTheme.light(),
            brand,
          ),
          darkTheme: _withWeTheme(
            ThemeData.dark(useMaterial3: true),
            const WeTheme.dark(),
            brand,
          ),
          home: const AdminShell(),
        ),
      ),
    );
  }
}
