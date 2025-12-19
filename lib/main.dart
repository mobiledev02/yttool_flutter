import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yttool_flutter/core/theme/app_theme.dart';
import 'package:yttool_flutter/features/home/home_screen.dart';

import 'package:provider/provider.dart';
import 'package:yttool_flutter/core/services/theme_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const YToolApp(),
    ),
  );
}

class YToolApp extends StatelessWidget {
  const YToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return GetMaterialApp(
          title: 'YT Tool',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
