import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../routing/app_router.dart';
import '../auth/auth_view_model.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({required this.label, required this.icon, required this.route});
}

const _navGroup1 = [
  _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: AppRoutes.dashboard),
  _NavItem(label: 'Customers', icon: Icons.person_outline, route: AppRoutes.customers),
];

const _navGroup2 = [
  _NavItem(label: 'Items', icon: Icons.inventory_2_outlined, route: AppRoutes.items),
  _NavItem(label: 'Estimates', icon: Icons.description_outlined, route: AppRoutes.estimates),
  _NavItem(label: 'Invoices', icon: Icons.receipt_long_outlined, route: AppRoutes.invoices),
  _NavItem(label: 'Payments', icon: Icons.credit_card_outlined, route: AppRoutes.payments),
  _NavItem(label: 'Expenses', icon: Icons.calculate_outlined, route: AppRoutes.expenses),
];

const _navGroup3 = [
  _NavItem(label: 'Settings', icon: Icons.settings_outlined, route: AppRoutes.settings),
];

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}

class CraterDrawer extends StatelessWidget {
  const CraterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final authVm = context.read<AuthViewModel>();

    return Drawer(
      child: Column(
        children: [
          // Header gradient
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Crater',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildGroup(context, _navGroup1, currentLocation),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(),
                ),
                _buildGroup(context, _navGroup2, currentLocation),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(),
                ),
                _buildGroup(context, _navGroup3, currentLocation),
              ],
            ),
          ),

          // Footer user info + logout
          const Divider(height: 1),
          Consumer<AuthViewModel>(
            builder: (context, vm, _) {
              final user = vm.user;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary100,
                  child: Text(
                    (user?.name ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary600,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                title: Text(
                  user?.name ?? 'User',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  user?.email ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.slate400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.slate400, size: 20),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await authVm.logout();
                  },
                  tooltip: 'Logout',
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, List<_NavItem> items, String currentLocation) {
    return Column(
      children: items.map((item) => _NavTile(item: item, currentLocation: currentLocation)).toList(),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final String currentLocation;

  const _NavTile({required this.item, required this.currentLocation});

  bool get isActive => currentLocation.startsWith(item.route);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? const Border(
                left: BorderSide(color: AppColors.primary500, width: 3),
              )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          size: 20,
          color: isActive ? AppColors.primary500 : AppColors.slate500,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.primary500 : AppColors.slate700,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          context.go(item.route);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minLeadingWidth: 20,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
      ),
    );
  }
}
