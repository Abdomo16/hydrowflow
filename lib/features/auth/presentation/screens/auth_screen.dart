import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUp = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(locator<AuthRepository>()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1621),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: Color(0xFF2F8BEF),
                          size: 56,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isSignUp ? 'Create Account' : 'Welcome Back',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Track your hydration anywhere, on any device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 36),

                        _SocialButton(
                          icon: Icons.g_mobiledata,
                          label: 'Continue with Google',
                          onTap: state.loading
                              ? null
                              : () => cubit.signInWithGoogle(),
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(height: 12),
                          _SocialButton(
                            icon: Icons.apple,
                            label: 'Continue with Apple',
                            onTap: state.loading
                                ? null
                                : () => cubit.signInWithApple(),
                          ),
                        ],

                        const SizedBox(height: 28),
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(color: Colors.white12),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.white12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Email'),
                          validator: (v) {
                            if (v == null || !v.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Password'),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: state.loading ? null : _submitEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F8BEF),
                              disabledBackgroundColor: const Color(0xFF2F8BEF)
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isSignUp ? 'Sign Up' : 'Sign In',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              setState(() => isSignUp = !isSignUp),
                          child: Text(
                            isSignUp
                                ? 'Already have an account? Sign In'
                                : "Don't have an account? Sign Up",
                            style: const TextStyle(color: Color(0xFF2F8BEF)),
                          ),
                        ),
                        if (!isSignUp)
                          TextButton(
                            onPressed: () {
                              if (emailController.text.contains('@')) {
                                cubit.sendPasswordReset(
                                  emailController.text,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Enter your email above first',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),

                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Continue without an account',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitEmail() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    if (isSignUp) {
      cubit.signUpWithEmail(emailController.text, passwordController.text);
    } else {
      cubit.signInWithEmail(emailController.text, passwordController.text);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1B2633),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 28),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1B2633),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
