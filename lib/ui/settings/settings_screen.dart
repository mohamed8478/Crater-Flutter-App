import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../auth/auth_view_model.dart';
import '../widgets/crater_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.user;

    return CraterScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary100,
                  child: Text(
                    (user?.name ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 14, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Settings groups
          _SettingSection(
            title: 'Account',
            items: [
              _SettingItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          _SettingSection(
            title: 'Company',
            items: [
              _SettingItem(
                icon: Icons.business_outlined,
                label: 'Company Info',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.payment_outlined,
                label: 'Payment Methods',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.receipt_outlined,
                label: 'Tax Types',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.category_outlined,
                label: 'Expense Categories',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          _SettingSection(
            title: 'Preferences',
            items: [
              _SettingItem(
                icon: Icons.tune_outlined,
                label: 'Preferences',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.email_outlined,
                label: 'Mail Configuration',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: () async {
                final authVm = context.read<AuthViewModel>();
                await authVm.logout();
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<_SettingItem> items;

  const _SettingSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate400,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          color: AppColors.surface,
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slate500, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.slate700)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.slate300, size: 20),
      onTap: onTap,
      dense: true,
      minLeadingWidth: 20,
    );
  }
}
