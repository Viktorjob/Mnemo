import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mnemo/auth/authentication/bloc/auth_bloc.dart';
import 'package:mnemo/auth/authentication/bloc/auth_state.dart';
import 'package:mnemo/auth/screens/login_screen.dart';
import 'package:mnemo/auth/screens/registration_screen.dart';
import 'package:mnemo/auth/screens/reset_password_screen.dart';
import 'package:mnemo/auth/screens/verify_email_screen.dart';
import 'package:mnemo/firebase_options.dart';
import 'package:mnemo/ui/screens_messenger/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const LoginScreen(),
              loading: (_) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
              authenticated: (s) => HomeScreen(user: s.user),
              unauthenticated: (_) => const LoginScreen(),
              error: (s) => LoginScreen(errorMessage: s.message),
              passwordResetSent: (_) => const ResetPasswordScreen(),
              emailVerificationSent: (_) {
                final user = FirebaseAuth.instance.currentUser!;
                return VerifyEmailScreen(user: user);
              },
            );
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/reset': (context) => const ResetPasswordScreen(),
        },
      ),
    );
  }
}
