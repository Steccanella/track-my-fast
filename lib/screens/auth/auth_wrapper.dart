import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../main_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasTriedAnonymousSignIn = false;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            // Show loading indicator while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // If user is logged in (either anonymous or with account), show main navigation
            if (snapshot.hasData && snapshot.data != null) {
              return const MainNavigation();
            }

            // If no user, try to sign in anonymously
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_hasTriedAnonymousSignIn) {
                _hasTriedAnonymousSignIn = true;
                _signInAnonymously(authService);
              }
            });

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

            // If anonymous sign-in failed, show login screen as fallback
            return const LoginScreen();
          },
        );
      },
    );
  }

  Future<void> _signInAnonymously(AuthService authService) async {
    try {
      await authService.signInAnonymously();
    } catch (e) {
      // If anonymous sign-in fails, user will see login screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start app: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
