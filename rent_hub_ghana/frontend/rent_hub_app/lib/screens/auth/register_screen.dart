import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import '../landlord/landlord_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});
  final String role;
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final first = TextEditingController(),
      last = TextEditingController(),
      username = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirmPassword = TextEditingController(),
      phone = TextEditingController(),
      organization = TextEditingController(),
      recoveryQuestion = TextEditingController(),
      recoveryAnswer = TextEditingController();
  bool loading = false;
  bool showPassword = false;
  String? error;

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    phone.dispose();
    organization.dispose();
    recoveryQuestion.dispose();
    recoveryAnswer.dispose();
    super.dispose();
  }

  Future<String?> _showSignupConfirmationGate() async {
    final codeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm it is you'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 16),
            const Text(
              'We sent a 6-digit confirmation code to your email. Please enter it below and open Gmail if you want to check the message too.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirmation code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(codeController.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    codeController.dispose();
    return result;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ApiService().requestSignupConfirmation(email.text.trim());
      final confirmationCode = await _showSignupConfirmationGate();
      if (confirmationCode == null || confirmationCode.length != 6) {
        if (mounted) {
          setState(
            () => error = 'Please enter the 6-digit confirmation code to continue.',
          );
        }
        return;
      }

      await ApiService().verifySignupConfirmation(
        email: email.text.trim(),
        code: confirmationCode,
      );

      final user = await authService.register(
        username: username.text.trim(),
        email: email.text.trim(),
        password: password.text,
        firstName: first.text.trim(),
        lastName: last.text.trim(),
        role: widget.role,
        phone: phone.text.trim(),
        organizationName: organization.text.trim(),
        confirmationCode: confirmationCode,
        recoveryQuestion: recoveryQuestion.text.trim(),
        recoveryAnswer: recoveryAnswer.text.trim(),
      );

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
        final destination = user.role == 'renter'
            ? Shell(token: authService.token)
            : LandlordDashboard(role: user.role, token: authService.token);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destination),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => this.error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String? requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Form(
      key: formKey,
      child: ListView(
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
                  ? 'Renter account'
                  : widget.role == 'agent'
                  ? 'Agent account'
                  : 'Landlord account',
              style: const TextStyle(
                color: Color(0xFFBDA8FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Create your account',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            widget.role == 'renter'
                ? 'Save homes, contact agents and keep your search in one place.'
                : widget.role == 'agent'
                ? 'Manage your listings and respond to renters from one workspace.'
                : 'Publish your spaces and manage renter interest with confidence.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: first,
                  validator: requiredValue,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: last,
                  validator: requiredValue,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            validator: requiredValue,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+233 24 000 0000',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: username,
            validator: requiredValue,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: email,
            validator: (v) =>
                v != null && v.contains('@') ? null : 'Enter a valid email',
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: password,
            obscureText: !showPassword,
            validator: (v) =>
                v != null && v.length >= 6 ? null : 'Use at least 6 characters',
            decoration: InputDecoration(
              labelText: 'Password',
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
          const SizedBox(height: 14),
          TextFormField(
            controller: confirmPassword,
            obscureText: !showPassword,
            validator: (v) =>
                v != password.text ? 'Passwords do not match' : null,
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: recoveryQuestion,
            validator: requiredValue,
            decoration: const InputDecoration(
              labelText: 'Recovery question',
              hintText: 'What is your favorite childhood pet?',
              prefixIcon: Icon(Icons.help_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: recoveryAnswer,
            validator: requiredValue,
            decoration: const InputDecoration(
              labelText: 'Recovery answer',
              hintText: 'Type the answer exactly as you will remember it',
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
          ),
          if (widget.role != 'renter') ...[
            const SizedBox(height: 14),
            TextFormField(
              validator: requiredValue,
              decoration: InputDecoration(
                labelText: widget.role == 'agent'
                    ? 'Agency name'
                    : 'Property or business name',
                prefixIcon: const Icon(Icons.business_outlined),
              ),
              controller: organization,
            ),
          ],
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Choose a different role'),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : submit,
              child: Text(loading ? 'Creating account...' : 'Create account'),
            ),
          ),
        ],
      ),
    ),
  );
}
