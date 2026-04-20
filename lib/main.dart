import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quickcharge_ev_app/pages/auth.dart';
import 'package:quickcharge_ev_app/pages/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => SplashView(
          onContinue: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const HomeShell(),
              ),
            );
          },
          onLogin: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => AuthView(
                  onAuthSuccess: (user, token) {
                    debugPrint('Authenticated as: ${user['email']}');
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const HomeShell(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}