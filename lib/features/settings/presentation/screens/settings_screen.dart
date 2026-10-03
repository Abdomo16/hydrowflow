import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';
import 'package:hydrowflow/features/settings/logic/settings_cubit.dart';
import 'package:hydrowflow/features/settings/logic/settings_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(locator<SettingsRepository>()),
      child: Scaffold(
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
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final cubit = context.read<SettingsCubit>();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _SectionTitle('Preferences'),
                _SettingsTile(
                  icon: Icons.straighten,
                  title: 'Units',
                  subtitle: state.settings.unit == AppUnit.metric
                      ? 'Metric (ml, cm, kg)'
                      : 'Imperial (fl oz, ft, lb)',
                  trailing: DropdownButton<AppUnit>(
                    value: state.settings.unit,
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
                      if (value != null) cubit.setUnit(value);
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme throughout the app',
                  trailing: Switch(
                    value: state.settings.darkMode,
                    onChanged: cubit.toggleDarkMode,
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
                _SettingsTile(
                  icon: Icons.workspace_premium,
                  title: 'Upgrade to Pro',
                  subtitle: 'Cloud sync, advanced stats, widgets',
                  onTap: () {
                    // TODO: navigate to paywall
                  },
                ),
                _SettingsTile(
                  icon: Icons.restore,
                  title: 'Restore Purchases',
                  onTap: () {
                    // TODO: restore purchases
                  },
                ),
              ],
            );
          },
        ),
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
