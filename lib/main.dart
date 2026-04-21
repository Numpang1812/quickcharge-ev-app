import 'package:flutter/material.dart';
import 'package:quickcharge_ev_app/pages/home.dart';
import 'package:quickcharge_ev_app/pages/auth.dart';
import 'package:quickcharge_ev_app/pages/tabbed_home.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite for desktop platforms (Windows, macOS, Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const QuickChargeApp());
}

class QuickChargeApp extends StatelessWidget {
  const QuickChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickCharge EV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
      home: const _HomeNavigationWrapper(),
    );
  }
}

class _HomeNavigationWrapper extends StatefulWidget {
  const _HomeNavigationWrapper();

  @override
  State<_HomeNavigationWrapper> createState() => _HomeNavigationWrapperState();
}

class _HomeNavigationWrapperState extends State<_HomeNavigationWrapper> {
  bool _isAuthenticated = false;
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return SplashView(
        onContinue: () {
          setState(() {
            _isAuthenticated = true;
          });
        },
        onLogin: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => AuthView(
                onAuthSuccess: (user, token) {
                  debugPrint("Authenticated as: ${user['email']}");
                  setState(() {
                    _isAuthenticated = true;
                  });
                },
              ),
            ),
          );
        },
      );
    }

    return TabbedHomeScreen(
      currentIndex: _currentTabIndex,
      onTabTapped: (index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
    );
  }
}
