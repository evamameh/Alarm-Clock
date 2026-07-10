import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/auth_providers.dart';
import '../theme.dart';
import 'alarm_providers.dart';
import 'alarm_screens.dart';

class AlarmAppShell extends ConsumerWidget {
  const AlarmAppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmControllerProvider);
    ref.listen(alarmEventsProvider, (_, next) {
      next.whenData(ref.read(alarmControllerProvider.notifier).handleEvent);
    });

    if (state.ringingAlarm != null) {
      return RingingScreen(alarm: state.ringingAlarm!);
    }

    final user = ref.watch(authStateProvider).value;
    Future<void> logout() {
      return ref.read(authControllerProvider).logout();
    }

    final screens = [
      HomeScreen(currentEmail: user?.email, onLogout: logout),
      AlarmsScreen(currentEmail: user?.email, onLogout: logout),
      ProfileScreen(user: user, onLogout: logout),
    ];

    return Scaffold(
      body: screens[state.selectedTab],
      floatingActionButton: state.selectedTab == 1
          ? FloatingActionButton(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlarmEditorScreen()),
              ),
              child: const Icon(Icons.add, size: 34),
            )
          : null,
      bottomNavigationBar: _BottomNav(
        selectedIndex: state.selectedTab,
        onSelected: ref.read(alarmControllerProvider.notifier).setTab,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _NavItem(
              icon: Icons.alarm,
              label: 'Alarms',
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.blushStrong : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.roseDark),
            Text(label, style: const TextStyle(color: AppColors.roseDark)),
          ],
        ),
      ),
    );
  }
}
