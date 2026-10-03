import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/features/auth/data/repositories/auth_repository.dart';
import 'package:hydrowflow/features/auth/logic/auth_cubit.dart';
import 'package:hydrowflow/features/auth/presentation/screens/auth_screen.dart';
import 'package:hydrowflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';
import 'package:hydrowflow/features/settings/logic/settings_cubit.dart';
import 'package:hydrowflow/features/settings/logic/settings_state.dart';
import 'package:hydrowflow/features/subscription/data/repositories/subscription_repository.dart';
import 'package:hydrowflow/features/subscription/logic/pro_gate.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_state.dart';
import 'package:hydrowflow/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(locator<SettingsRepository>())),
        BlocProvider(
          create: (_) => SubscriptionCubit(locator<SubscriptionRepository>())
            ..refreshPro(),
        ),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1621),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          if (settingsState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settingsCubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _SectionTitle('Preferences'),
              _SettingsTile(
                icon: Icons.straighten,
                title: 'Units',
                subtitle: settingsState.settings.unit == AppUnit.metric
                    ? 'Metric (ml, cm, kg)'
                    : 'Imperial (fl oz, ft, lb)',
                trailing: DropdownButton<AppUnit>(
                  value: settingsState.settings.unit,
                  dropdownColor: const Color(0xFF1B2633),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  items: AppUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(
                        unit.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) settingsCubit.setUnit(value);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme throughout the app',
                trailing: Switch(
                  value: settingsState.settings.darkMode,
                  onChanged: settingsCubit.toggleDarkMode,
                  activeTrackColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Account'),
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Height, weight, activity, goal',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              const _AuthSection(),
              const SizedBox(height: 24),
              _SectionTitle('Support'),
              _SettingsTile(
                icon: Icons.star_outline,
                title: 'Rate Us',
                onTap: () => _openUrl('https://play.google.com/store/apps/details?id=com.example.hydrowflow'),
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Contact Support',
                onTap: () => _openUrl('mailto:support@hydrowflow.app'),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Legal'),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _openUrl('https://hydrowflow.app/privacy'),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _openUrl('https://hydrowflow.app/terms'),
              ),
              _SettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Licenses',
                onTap: () => _showLicenses(context),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Subscription'),
              const _SubscriptionSection(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'HydroFlow',
      applicationVersion: '1.0.0',
    );
  }
}

class _AuthSection extends StatelessWidget {
  const _AuthSection();

  @override
  Widget build(BuildContext context) {
    final authRepository = locator<AuthRepository>();

    if (authRepository.currentUser == null) {
      return _SettingsTile(
        icon: Icons.login,
        title: 'Sign In / Sign Up',
        subtitle: 'Sync your data and recover purchases',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        ),
      );
    }

    final user = authRepository.currentUser!;
    return _SettingsTile(
      icon: Icons.account_circle_outlined,
      title: user.email ?? 'Signed in',
      subtitle: 'Tap to sign out',
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1B2633),
            title: const Text(
              'Sign Out?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Your local data stays on this device.',
              style: TextStyle(color: Colors.white54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await AuthCubit(locator<AuthRepository>()).signOut();
        }
      },
    );
  }
}

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, subState) {
        final cubit = context.read<SubscriptionCubit>();

        return Column(
          children: [
            _SettingsTile(
              icon: Icons.workspace_premium,
              title: subState.isPro ? 'You are a Pro member' : 'Upgrade to Pro',
              subtitle: subState.isPro
                  ? 'All features unlocked'
                  : 'Cloud sync, advanced stats, widgets',
              trailing: subState.isPro ? const ProBadge() : null,
              onTap: subState.isPro
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PaywallScreen()),
                      ),
            ),
            if (!subState.isPro)
              _SettingsTile(
                icon: Icons.restore,
                title: 'Restore Purchases',
                onTap: cubit.restorePurchases,
              ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2633),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
