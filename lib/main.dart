import 'package:flutter/material.dart';
import 'package:quickcharge_ev_app/pages/home.dart';

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
      home: SplashView(
        onContinue: () {
          // TODO: Navigate to Home/Map Screen
          debugPrint("Continue as Guest pressed");
        },
        onLogin: () {
          // TODO: Navigate to Login Screen
          debugPrint("Sign In / Sign Up pressed");
        },
      ),
    );
  }
}
