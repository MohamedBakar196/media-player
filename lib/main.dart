import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/media_library_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaLibraryService.instance.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _LaunchFlow(),
    );
  }
}

class _LaunchFlow extends StatefulWidget {
  const _LaunchFlow();

  @override
  State<_LaunchFlow> createState() => _LaunchFlowState();
}

class _LaunchFlowState extends State<_LaunchFlow> {
  bool _showSplash = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const Scaffold(body: SplashScreen());
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        onDone: () => setState(() => _showOnboarding = false),
      );
    }

    return const AppShell();
  }
}
