import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/repositories_impl/auth_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';
import 'package:workout_tracker_repo/presentation/pages/auth/register.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/primary_button.dart';
import 'package:workout_tracker_repo/presentation/widgets/images/logo_hero.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/password_field.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authRepo = AuthRepositoryImpl(AuthService());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final bool _passwordVisible = false;

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await authRepo.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      print(userCredential);
      if (userCredential != null && userCredential.email.isNotEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = 'Login failed. Please try again';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A system error occurred. Please try again later.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  HeroLogo(),
                  const SizedBox(height: 40),
                  InputField(
                    controller: _emailController,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Button(
                    label: 'LOGIN',
                    isLoading: _isLoading,
                    onPressed: _signInWithEmailAndPassword,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(color: Color(0xFF868686)),
                        ),
                      ),
                      Text("Or", style: TextStyle(color: Color(0xFF868686))),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(color: Color(0xFF868686)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      const Text("Don't have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return RegisterPage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Register Here",
                          style: TextStyle(color: Color(0xFF48A6A7)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
