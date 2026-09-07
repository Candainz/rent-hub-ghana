import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../../main.dart';
import '../landlord/landlord_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role, this.onSignedIn});
  final String role;
  final VoidCallback? onSignedIn;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  final resetUsername = TextEditingController();
  final resetAnswer = TextEditingController();
  final resetNewPassword = TextEditingController();
  final resetConfirmPassword = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool showResetPassword = false;
  bool resetLoading = false;
  bool questionLoaded = false;
  bool recoveryVerified = false;
  String? recoveryQuestion;
  String? error;
  String? resetError;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    resetUsername.dispose();
    resetAnswer.dispose();
    resetNewPassword.dispose();
    resetConfirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (username.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Enter your username and password.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final user = await authService.login(username.text.trim(), password.text);

      final supportsBiometric = await authService.canUseBiometric();
      if (supportsBiometric) {
        final biometricVerified = await authService.authenticateBiometric();
        if (!biometricVerified) {
          if (mounted) {
            setState(
              () => error = 'Biometric verification failed. Use the correct biometric to continue.',
            );
          }
          return;
        }
      }

      if (mounted) {
        widget.onSignedIn?.call();
        final destination = user.role == 'renter'
            ? Shell(token: authService.token)
            : LandlordDashboard(role: user.role, token: authService.token);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destination),
          (route) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not sign in. Check your details and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadRecoveryQuestion() async {
    final username = resetUsername.text.trim();

    if (username.isEmpty) {
      setState(() => resetError = 'Enter your username before loading the recovery question.');
      return;
    }

    setState(() {
      resetLoading = true;
      resetError = null;
      questionLoaded = false;
      recoveryVerified = false;
      recoveryQuestion = null;
      resetAnswer.clear();
      resetNewPassword.clear();
      resetConfirmPassword.clear();
    });

    try {
      final question = await ApiService().fetchRecoveryQuestion(
        username: username,
      );
      if (mounted) {
        setState(() {
          recoveryQuestion = question;
          questionLoaded = true;
          resetError = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          questionLoaded = false;
          recoveryQuestion = null;
          resetError = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => resetLoading = false);
    }
  }

  Future<void> verifyRecoveryAnswer() async {
    final username = resetUsername.text.trim();
    final answer = resetAnswer.text.trim();
    if (username.isEmpty) {
      setState(() => resetError = 'Enter your username.');
      return;
    }
    if (recoveryQuestion == null || recoveryQuestion!.isEmpty) {
      setState(() => resetError = 'Load the recovery question first.');
      return;
    }
    if (answer.isEmpty) {
      setState(() => resetError = 'Enter the answer to your recovery question.');
      return;
    }

    setState(() {
      resetLoading = true;
      resetError = null;
    });

    try {
      await ApiService().verifyRecoveryAnswer(
        username: username,
        question: recoveryQuestion!,
        answer: answer,
      );
      if (mounted) {
        setState(() {
          recoveryVerified = true;
          questionLoaded = true;
        });
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Recovery answer verified. Set your new password.')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => resetError = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => resetLoading = false);
    }
  }

  Future<void> resetPassword() async {
    final username = resetUsername.text.trim();
    final newPassword = resetNewPassword.text.trim();
    final confirmPassword = resetConfirmPassword.text.trim();

    if (!recoveryVerified) {
      setState(() => resetError = 'Verify your recovery answer before resetting the password.');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => resetError = 'Password must be at least 6 characters long.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => resetError = 'Passwords do not match.');
      return;
    }

    setState(() {
      resetLoading = true;
      resetError = null;
    });

    try {
      await ApiService().confirmPasswordReset(
        username: username,
        password: newPassword,
        verifiedRecovery: true,
      );
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Your password was updated successfully.')),
        );
        setState(() {
          showResetPassword = false;
          questionLoaded = false;
          recoveryVerified = false;
          recoveryQuestion = null;
          resetUsername.clear();
          resetAnswer.clear();
          resetNewPassword.clear();
          resetConfirmPassword.clear();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => resetError = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => resetLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2143),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.role == 'renter'
                ? 'Renter sign in'
                : widget.role == 'agent'
                ? 'Agent sign in'
                : 'Landlord sign in',
            style: const TextStyle(
              color: Color(0xFFBDA8FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome back',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to continue where you left off.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: username,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: password,
          obscureText: !showPassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => showPassword = !showPassword),
              icon: Icon(
                showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: loading ? null : submit,
            child: Text(loading ? 'Signing in...' : 'Sign in'),
          ),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () => setState(() => showResetPassword = !showResetPassword),
          child: const Text('Forgot password?'),
        ),
        if (showResetPassword) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reset your password',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: resetUsername,
                  textCapitalization: TextCapitalization.none,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: resetLoading ? null : loadRecoveryQuestion,
                    child: Text(resetLoading ? 'Checking...' : 'Get recovery question'),
                  ),
                ),
                if (questionLoaded && recoveryQuestion != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recoveryQuestion!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: resetAnswer,
                    decoration: const InputDecoration(
                      labelText: 'Your answer',
                      prefixIcon: Icon(Icons.question_answer_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: resetLoading ? null : verifyRecoveryAnswer,
                      child: const Text('Verify answer'),
                    ),
                  ),
                ],
                if (recoveryVerified) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetNewPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: resetConfirmPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: resetLoading ? null : resetPassword,
                      child: const Text('Update password'),
                    ),
                  ),
                ],
                if (resetError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      resetError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterScreen(role: widget.role),
            ),
          ),
          child: const Text('Create a new account'),
        ),
      ],
    ),
  );
}
