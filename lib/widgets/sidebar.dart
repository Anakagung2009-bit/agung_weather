import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../utils/localization.dart'; // Tambahkan import localization

class CustomNavigationDrawer extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationDrawer({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomNavigationDrawerState createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> {
  bool _isExpanded = true;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final colorScheme = Theme.of(context).colorScheme;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: _isExpanded ? 320 : 80,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: NavigationDrawer(
            selectedIndex: widget.currentIndex,
            onDestinationSelected: widget.onTap,
            children: <Widget>[
              // Header Drawer
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isExpanded
                    ? Column(
                  key: ValueKey('expanded'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Text(
                        AppConstants.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        context.translate('app_tagline'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                )
                    : Center(
                  key: ValueKey('collapsed'),
                  child: Image.asset(
                    'assets/logoweather.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),

              // Navigation Items dengan hover effect
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildNavigationItem(
                      context,
                      index: 0,
                      icon: Icons.dashboard_rounded,
                      label: context.translate('dashboard'),
                    ),
                    _buildNavigationItem(
                      context,
                      index: 1,
                      icon: Icons.location_on_rounded,
                      label: context.translate('locations'),
                    ),
                    _buildNavigationItem(
                      context,
                      index: 2,
                      icon: Icons.settings_rounded,
                      label: context.translate('settings'),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              const Divider(height: 1),

              // Bottom Section dengan desain modern
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isExpanded
                    ? Padding(
                  key: ValueKey('expanded_bottom'),
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Icon(
                            Icons.person_rounded,
                            color: colorScheme.onPrimaryContainer,
                          )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? context.translate('user'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.email ?? context.translate('not_logged_in'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: colorScheme.primary,
                          ),
                          onPressed: () =>
                              setState(() => _isExpanded = false),
                        ),
                      ],
                    ),
                  ),
                )
                    : Padding(
                  key: ValueKey('collapsed_bottom'),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.primary,
                    ),
                    onPressed: () =>
                        setState(() => _isExpanded = true),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // Custom widget untuk navigation item dengan efek hover
  Widget _buildNavigationItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required String label,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = widget.currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          icon,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.7),
        ),
        title: _isExpanded
            ? Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        )
            : null,
        onTap: () => widget.onTap(index),
      ),
    );
  }
}