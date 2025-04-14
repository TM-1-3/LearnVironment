import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:learnvironment/firebase_options.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth fireauth;
  App({super.key, FirebaseFirestore? firestore, FirebaseAuth? fireauth})
    : firestore = firestore ?? FirebaseFirestore.instance,
    fireauth = fireauth ?? FirebaseAuth.instance;

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
      home: AuthGate(firestore: firestore, fireauth: fireauth),
      routes: {
        '/auth_gate': (context) => AuthGate(firestore: firestore, fireauth: fireauth),
        '/fix_account': (context) => FixAccountPage(firestore: firestore, fireauth: fireauth),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
