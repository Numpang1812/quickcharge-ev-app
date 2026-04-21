import 'package:flutter/material.dart';
import 'package:quickcharge_ev_app/pages/home.dart';
import 'package:quickcharge_ev_app/pages/auth.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickcharge_ev_app/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
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
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => const HomeShell()),
            );
          },
          onLogin: () {
            // Navigate to AuthView
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => AuthView(
                  onAuthSuccess: (user, token) {
                    debugPrint("Authenticated as: ${user['email']}");
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
