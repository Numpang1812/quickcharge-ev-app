import 'package:flutter/material.dart';
import 'package:quickcharge_ev_app/pages/home.dart';
import 'package:quickcharge_ev_app/pages/auth.dart';

void main() {
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
      home: Builder(
        builder: (context) => SplashView(
          onContinue: () {
            // TODO: Navigate to Map Screen
            debugPrint("Continue as Guest pressed");
          },
          onLogin: () {
            // Navigate to AuthView
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AuthView(
                  onAuthSuccess: (user, token) {
                    debugPrint("Authenticated as: ${user['email']}");
                    // Navigate to home/map after successful login
                    Navigator.of(context).pop();
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
