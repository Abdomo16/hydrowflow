import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/ads/ad_service.dart';
import 'package:hydrowflow/core/app/logic/app_cubit.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/auth/data/repositories/auth_repository.dart';
import 'package:hydrowflow/features/auth/presentation/screens/auth_screen.dart';
import 'package:hydrowflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';
import 'package:hydrowflow/features/settings/logic/settings_cubit.dart';
import 'package:hydrowflow/features/settings/logic/settings_state.dart';
import 'package:hydrowflow/features/settings/presentation/widgets/cup_size_bottom_sheet.dart';
import 'package:hydrowflow/features/subscription/logic/pro_gate.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_state.dart';
import 'package:hydrowflow/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _SettingsView();
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                  dropdownColor: colors.surface,
                  underline: const SizedBox.shrink(),
                  icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                  items: AppUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(
                        unit.name.toUpperCase(),
                        style: TextStyle(color: colors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) settingsCubit.setUnit(value);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.local_drink_outlined,
                title: 'Cup Size',
                subtitle: 'Amount added each time you tap "Add Drink"',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${settingsState.settings.cupSizeMl} ml',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colors.textMuted),
                  ],
                ),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => CupSizeBottomSheet(
                    currentMl: settingsState.settings.cupSizeMl,
                    onSave: settingsCubit.setCupSize,
                  ),
                ),
              ),
              _SettingsTile(
                icon: settingsState.settings.darkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                title: 'Dark Mode',
                subtitle: settingsState.settings.darkMode
                    ? 'Dark theme is on'
                    : 'Light theme is on',
                trailing: Switch(
                  value: settingsState.settings.darkMode,
                  onChanged: settingsCubit.toggleDarkMode,
                ),
              ),
              _ThemePicker(selected: settingsState.settings.palette),
              const SizedBox(height: 24),
              _SectionTitle('Account'),
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Height, weight and activity (updates your goal)',
                onTap: () => _openProfile(context),
              ),
              const _AuthSection(),
              const SizedBox(height: 24),
              _SectionTitle('Support'),
              _SettingsTile(
                icon: Icons.star_outline,
                title: 'Rate Us',
                onTap: () => _openUrl(
                  context,
                  'https://play.google.com/store/apps/details?id=com.example.hydrowflow',
                ),
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Contact Support',
                onTap: () => _openUrl(context, 'mailto:support@hydrowflow.app'),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Legal'),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _openUrl(context, 'https://hydrowflow.app/privacy'),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _openUrl(context, 'https://hydrowflow.app/terms'),
              ),
              _SettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Licenses',
                onTap: () => _showLicenses(context),
              ),
              const _AdPrivacyTile(),
              const SizedBox(height: 24),
              _SectionTitle('Subscription'),
              const _SubscriptionSection(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openProfile(BuildContext context) async {
    final appCubit = context.read<AppCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final newGoal = await Navigator.of(context).push<double>(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (newGoal == null) return;

    appCubit.updateGoal(newGoal);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Profile saved. New daily goal: ${newGoal.toStringAsFixed(1)} L',
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
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

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      initialData: authRepository.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return _SettingsTile(
            icon: Icons.login,
            title: 'Sign In / Sign Up',
            subtitle: 'Sync your data and recover purchases',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            ),
          );
        }

        return _signedInTile(context, user, authRepository);
      },
    );
  }

  Widget _signedInTile(
    BuildContext context,
    User user,
    AuthRepository authRepository,
  ) {
    return _SettingsTile(
      icon: Icons.account_circle_outlined,
      title: user.email ?? 'Signed in',
      subtitle: 'Tap to sign out',
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign Out?'),
            content: const Text('Your local data stays on this device.'),
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

        if (confirmed == true) {
          await authRepository.signOut();
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

        final String title;
        final String subtitle;
        if (subState.isPro) {
          title = 'You are a Premium member';
          subtitle = 'All features unlocked, no ads';
        } else if (subState.trialActive) {
          title = 'Premium trial active';
          subtitle =
              'Until ${DateFormat.MMMd().add_jm().format(subState.trialUntil!)}'
              ' · Tap to keep it forever';
        } else {
          title = 'Upgrade to Premium';
          subtitle = 'No ads, smart reminders, full stats, themes';
        }

        return Column(
          children: [
            _SettingsTile(
              icon: Icons.workspace_premium,
              title: title,
              subtitle: subtitle,
              trailing: subState.isPremium ? const ProBadge() : null,
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

class _ThemePicker extends StatelessWidget {
  final AppPalette selected;

  const _ThemePicker({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final premium = context.select<SubscriptionCubit, bool>(
      (c) => c.state.isPremium,
    );
    final active = premium ? selected : AppPalette.ocean;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Color Theme',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                active.label,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final palette in AppPalette.values)
                _PaletteSwatch(
                  palette: palette,
                  selected: palette == active,
                  locked: !premium && !palette.isFree,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final bool locked;

  const _PaletteSwatch({
    required this.palette,
    required this.selected,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: '${palette.label} theme${locked ? ', Premium' : ''}',
      child: GestureDetector(
        onTap: () async {
          final settings = context.read<SettingsCubit>();
          if (locked && !await ProGate.showPaywallIfLocked(context)) return;
          settings.setPalette(palette);
        },
        child: Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? palette.lightPrimary : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.primaryLight, palette.lightPrimary],
              ),
            ),
            child: Center(
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : locked
                  ? Icon(
                      Icons.lock,
                      color: colors.onPrimary.withValues(alpha: 0.9),
                      size: 16,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdPrivacyTile extends StatelessWidget {
  const _AdPrivacyTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdService.isSupported
          ? AdService.privacyOptionsRequired
          : Future.value(false),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return _SettingsTile(
          icon: Icons.ads_click,
          title: 'Ad Privacy Choices',
          subtitle: 'Change how ads use your data',
          onTap: AdService.showPrivacyOptions,
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
        style: TextStyle(
          color: context.colors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
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
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              )
            : null,
        trailing: trailing ?? Icon(Icons.chevron_right, color: colors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
