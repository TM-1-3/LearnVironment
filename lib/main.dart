import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication/firebase_options.dart';
import 'authentication/auth_gate.dart';
import 'authentication/auth_service.dart'; // Import the AuthService
import 'authentication/fix_account.dart';
import '../authentication/login_screen.dart'; // Import the Login Screen
import '../authentication/signup_screen.dart'; // Import the Sign-Up Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnVironment',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.green,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(0, 255, 0, 1.0)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const AuthGate(), // The AuthGate widget as the starting point
      routes: {
        '/auth_gate': (context) => const AuthGate(), // Define the AuthGate route
        '/fix_account': (context) => const FixAccountPage(), // Define FixAccountPage route
        '/login': (context) => const LoginScreen(), // Define LoginScreen route
        '/signup': (context) => const SignUpScreen(), // Define SignUpScreen route
      },
    );
  }
}
