import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../utils/localization.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final AuthService _authService = AuthService();

  CustomNavigationDrawer({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      // Header Drawer
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                        ),
                        accountName: Text(
                          user?.displayName ?? context.translate('user'),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        accountEmail: Text(
                          user?.email ?? context.translate('not_logged_in'),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: colorScheme.surface,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Icon(
                            Icons.person_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 40,
                          )
                              : null,
                        ),
                      ),

                      // Navigation Items
                      _buildNavItem(
                        context,
                        index: 0,
                        icon: Icons.dashboard_rounded,
                        label: context.translate('dashboard'),
                      ),
                      _buildNavItem(
                        context,
                        index: 1,
                        icon: Icons.location_on_rounded,
                        label: context.translate('locations'),
                      ),
                      _buildNavItem(
                        context,
                        index: 3,
                        icon: Icons.warning_rounded,
                        label: context.translate('disaster_alerts'),
                      ),
                      _buildNavItem(
                        context,
                        index: 2,
                        icon: Icons.settings_rounded,
                        label: context.translate('settings'),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Logout
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    context.translate('logout'),
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () => _authService.signOut(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required String label,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = currentIndex == index;

    return ListTile(
      selected: isSelected,
      selectedColor: colorScheme.primary,
      leading: Icon(
        icon,
        color: isSelected
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onTap(index),
    );
  }
}