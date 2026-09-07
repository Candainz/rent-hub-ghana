import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  final AuthService authService;

  const SettingsScreen({
    required this.authService,
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool emailNotifications = true;
  bool smsNotifications = false;
  String selectedTheme = 'Light';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final mode = ThemeService.themeModeNotifier.value;
    selectedTheme = mode == ThemeMode.light
        ? 'Light'
        : mode == ThemeMode.dark
            ? 'Dark'
            : 'System';
    ThemeService.themeModeNotifier.addListener(() {
      final m = ThemeService.themeModeNotifier.value;
      setState(() {
        selectedTheme = m == ThemeMode.light
            ? 'Light'
            : m == ThemeMode.dark
                ? 'Dark'
                : 'System';
      });
    });
  }

  Color _cardColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.grey.shade800
      : const Color(0xFFF7F7F2);

  Color _cardBorderColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.grey.shade700
      : Colors.black12;

  Color _mutedTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.white70
      : Colors.black54;

  Future<void> _saveProfileUpdate({
    String? email,
    String? phone,
    String? password,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.authService.updateProfile(
        email: email,
        phone: phone,
        password: password,
      );
      if (!mounted) return;
      setState(() {});
      _showSnackbar('Account updated successfully');
    } catch (error) {
      if (!mounted) return;
      _showSnackbar(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showEditDialog({
    required String title,
    required String hint,
    required String initialValue,
    required String field,
    bool isPassword = false,
    bool obscureText = false,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword || obscureText,
            keyboardType: isPassword
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a value';
              }
              if (field == 'email' && !value.contains('@')) {
                return 'Enter a valid email address';
              }
              if (field == 'password' && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    if (field == 'email') {
      await _saveProfileUpdate(email: result);
    } else if (field == 'phone') {
      await _saveProfileUpdate(phone: result);
    } else if (field == 'password') {
      await _saveProfileUpdate(password: result);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Text(
          'Account & App Preferences',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 28),
        // Account Section
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _SettingsItem(
          icon: Icons.email_outlined,
          title: 'Email Address',
          subtitle: widget.authService.user?.email ?? 'Not set',
          onTap: () => _showEditDialog(
            title: 'Update Email',
            hint: 'name@example.com',
            initialValue: widget.authService.user?.email ?? '',
            field: 'email',
          ),
        ),
        const SizedBox(height: 12),
        _SettingsItem(
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          subtitle: widget.authService.user?.phone ?? 'Not set',
          onTap: () => _showEditDialog(
            title: 'Update Phone Number',
            hint: '+233 24 000 0000',
            initialValue: widget.authService.user?.phone ?? '',
            field: 'phone',
          ),
        ),
        const SizedBox(height: 12),
        _SettingsItem(
          icon: Icons.lock_outlined,
          title: 'Change Password',
          subtitle: 'Update your password regularly',
          onTap: () => _showEditDialog(
            title: 'Change Password',
            hint: 'Enter a new password',
            initialValue: '',
            field: 'password',
            isPassword: true,
          ),
        ),
        const SizedBox(height: 28),
        // Notifications Section
        Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorderColor(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Push Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'New listings and updates',
                    style: TextStyle(color: _mutedTextColor(context), fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() => notificationsEnabled = value);
                  _showSnackbar(
                    value
                        ? 'Push notifications enabled'
                        : 'Push notifications disabled',
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorderColor(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily summaries and alerts',
                    style: TextStyle(color: _mutedTextColor(context), fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: emailNotifications,
                onChanged: (value) {
                  setState(() => emailNotifications = value);
                  _showSnackbar(
                    value ? 'Email notifications enabled' : 'Email notifications disabled',
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorderColor(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SMS Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Urgent alerts only',
                    style: TextStyle(color: _mutedTextColor(context), fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: smsNotifications,
                onChanged: (value) {
                  setState(() => smsNotifications = value);
                  _showSnackbar(
                    value ? 'SMS notifications enabled' : 'SMS notifications disabled',
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Appearance Section
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(label: Text('Light'), value: 'Light'),
                  ButtonSegment(label: Text('Dark'), value: 'Dark'),
                  ButtonSegment(label: Text('System'), value: 'System'),
                ],
                selected: {selectedTheme},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    final isSelected = states.contains(WidgetState.selected);
                    final primary = Theme.of(context).colorScheme.primary;
                    if (isSelected) return primary;
                    return Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return Colors.white;
                    return Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87;
                  }),
                ),
                onSelectionChanged: (Set<String> newSelection) {
                  final value = newSelection.first;
                  setState(() => selectedTheme = value);
                  _showSnackbar('Theme changed to $value');
                  if (value == 'Light') {
                    ThemeService.setThemeMode(ThemeMode.light);
                  } else if (value == 'Dark') {
                    ThemeService.setThemeMode(ThemeMode.dark);
                  } else {
                    ThemeService.setThemeMode(ThemeMode.system);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // About Section
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _SettingsItem(
          icon: Icons.info_outline,
          title: 'App Version',
          subtitle: '1.0.0',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _SettingsItem(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'Read our terms',
          onTap: () => _showSnackbar('Terms page coming soon'),
        ),
        const SizedBox(height: 12),
        _SettingsItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Our privacy practices',
          onTap: () => _showSnackbar('Privacy policy coming soon'),
        ),
        const SizedBox(height: 30),
      ],
    ),
  );

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  Color _cardColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.grey.shade800
      : const Color(0xFFF7F7F2);

  Color _cardBorderColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.grey.shade700
      : Colors.black12;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _cardColor(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _cardBorderColor(context)),
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      ),
    ),
  );
}
