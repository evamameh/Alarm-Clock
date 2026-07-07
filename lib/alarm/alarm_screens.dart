import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../theme.dart';
import '../time_formatters.dart';
import 'alarm_model.dart';
import 'alarm_providers.dart';
import 'alarm_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.currentEmail, this.onLogout});

  final String? currentEmail;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final enabledAlarms = ref
        .watch(alarmControllerProvider)
        .alarms
        .where((alarm) => alarm.enabled);
    final nextAlarm = enabledAlarms.isEmpty ? null : enabledAlarms.first;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BrandHeader(currentEmail: currentEmail, onLogout: onLogout),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 70, 28, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Column(
                  children: [
                    FittedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatClock(now),
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              periodFor(now),
                              style: const TextStyle(
                                color: AppColors.rose,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      formatDate(now),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: softPanel(radius: 30),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.blush,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm,
                        color: AppColors.rose,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 26),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NEXT ALARM',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nextAlarm == null
                                ? '--:--'
                                : formatTimeOfDay(nextAlarm.time),
                            style: const TextStyle(
                              color: AppColors.rose,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: nextAlarm != null,
                      activeTrackColor: AppColors.rose,
                      activeThumbColor: Colors.white,
                      onChanged: nextAlarm == null
                          ? null
                          : (enabled) {
                              ref
                                  .read(alarmControllerProvider.notifier)
                                  .toggleAlarm(nextAlarm.id, enabled);
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlarmEditorScreen()),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 32),
                label: const Text(
                  'Set Alarm',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key, this.currentEmail, this.onLogout});

  final String? currentEmail;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(
      alarmControllerProvider.select((state) => state.alarms),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BrandHeader(currentEmail: currentEmail, onLogout: onLogout),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Your Alarms',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sleep tight, wake up bright',
                style: TextStyle(color: AppColors.roseDark, fontSize: 20),
              ),
              const SizedBox(height: 32),
              if (alarms.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 42,
                  ),
                  decoration: softPanel(radius: 30),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.alarm_add_outlined,
                        color: AppColors.rose,
                        size: 46,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'No alarms yet',
                        style: TextStyle(
                          color: AppColors.rose,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap + to set your first alarm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                for (final alarm in alarms) AlarmCard(alarm: alarm),
            ]),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user, this.onLogout});

  final User? user;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    final primaryProvider = user?.providerData.isNotEmpty == true
        ? user!.providerData.first
        : null;
    final displayName =
        user?.displayName ?? primaryProvider?.displayName ?? 'No name provided';
    final email = user?.email ?? primaryProvider?.email ?? 'No email provided';
    final authMethod = _authMethodLabel(primaryProvider?.providerId);
    final providerId = primaryProvider?.providerId ?? 'password';
    final photoUrl = user?.photoURL ?? primaryProvider?.photoURL;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BrandHeader(currentEmail: user?.email, onLogout: onLogout),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Details from your sign-in provider',
                style: TextStyle(color: AppColors.roseDark, fontSize: 20),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(26),
                decoration: softPanel(radius: 30),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.blush,
                      backgroundImage: photoUrl == null
                          ? null
                          : NetworkImage(photoUrl),
                      child: photoUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.rose,
                              size: 48,
                            )
                          : null,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.roseDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ProfileDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'User Name',
                      value: displayName,
                    ),
                    _ProfileDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                    _ProfileDetailRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Authentication Method',
                      value: authMethod,
                    ),
                    _ProfileDetailRow(
                      icon: Icons.account_tree_outlined,
                      label: 'Provider ID',
                      value: providerId,
                    ),
                    _ProfileDetailRow(
                      icon: Icons.fingerprint,
                      label: 'Firebase UID',
                      value: user?.uid ?? 'No UID available',
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  String _authMethodLabel(String? providerId) {
    switch (providerId) {
      case 'google.com':
        return 'Google Login';
      case 'password':
        return 'Email Login';
      case null:
        return 'Email Login';
      default:
        return providerId;
    }
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.blush,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.rose, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.roseDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmEditorScreen extends HookConsumerWidget {
  const AlarmEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTime = useState(TimeOfDay.now());
    final repeatDays = useState<Set<int>>({1, 2, 3, 4, 5});
    final vibrate = useState(true);
    final snoozeMinutes = useState(5);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: BrandHeader(centerTitle: true)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 42, 28, 54),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: 260,
                  decoration: softPanel(radius: 32),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2026,
                      1,
                      1,
                      selectedTime.value.hour,
                      selectedTime.value.minute,
                    ),
                    use24hFormat: false,
                    onDateTimeChanged: (value) {
                      selectedTime.value = TimeOfDay(
                        hour: value.hour,
                        minute: value.minute,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 34),
                _RepeatPanel(
                  selected: repeatDays.value,
                  onChanged: (days) => repeatDays.value = days,
                ),
                const SizedBox(height: 26),
                const _SoundPanel(),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _SettingPanel(
                        icon: Icons.vibration,
                        label: 'Vibrate',
                        child: Switch(
                          value: vibrate.value,
                          activeTrackColor: AppColors.blushStrong,
                          activeThumbColor: Colors.white,
                          onChanged: (value) => vibrate.value = value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: _SettingPanel(
                        icon: Icons.snooze,
                        label: 'Snooze',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: snoozeMinutes.value,
                            alignment: Alignment.center,
                            items: const [
                              DropdownMenuItem(value: 5, child: Text('5 min')),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10 min'),
                              ),
                              DropdownMenuItem(
                                value: 15,
                                child: Text('15 min'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) snoozeMinutes.value = value;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 46),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.rose,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(78),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(42),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(alarmControllerProvider.notifier)
                        .saveAlarm(
                          time: selectedTime.value,
                          repeatDays: repeatDays.value,
                          vibrate: vibrate.value,
                          snoozeMinutes: snoozeMinutes.value,
                        );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.favorite, size: 30),
                  label: const Text(
                    'Save Alarm',
                    style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class RingingScreen extends ConsumerWidget {
  const RingingScreen({super.key, required this.alarm});

  final AlarmModel alarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final controller = ref.read(alarmControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.roseDark,
                  iconSize: 28,
                  onPressed: controller.stopAlarm,
                ),
              ),
              const SizedBox(height: 18),
              const Icon(
                Icons.local_florist_outlined,
                color: AppColors.rose,
                size: 74,
              ),
              const SizedBox(height: 18),
              const Text(
                'RK',
                style: TextStyle(
                  color: AppColors.rose,
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 54),
              const Text(
                'Wake up, Princess!',
                style: TextStyle(
                  color: AppColors.roseDark,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'YOUR MORNING MAGIC BEGINS NOW',
                style: TextStyle(
                  color: AppColors.rose,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.8,
                ),
              ),
              const Spacer(),
              Container(
                width: 330,
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 42,
                ),
                decoration: softPanel(radius: 34),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatClock(now),
                        style: const TextStyle(
                          color: AppColors.rose,
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      formatDate(now),
                      style: const TextStyle(
                        color: AppColors.roseDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(74),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                ),
                onPressed: controller.stopAlarm,
                icon: const Icon(Icons.wb_sunny_outlined, size: 30),
                label: const Text(
                  'Stop',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.rose,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.72),
                  side: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.7),
                  ),
                  minimumSize: const Size.fromHeight(74),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                ),
                onPressed: () => controller.snooze(alarm),
                icon: const Icon(Icons.snooze, size: 30),
                label: const Text(
                  'Snooze',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Next alarm in ${alarm.snoozeMinutes} minutes if snoozed',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepeatPanel extends StatelessWidget {
  const _RepeatPanel({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: softPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPEAT',
            style: TextStyle(
              color: AppColors.rose,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < labels.length; i++)
                _DayButton(
                  label: labels[i],
                  selected: selected.contains(i + 1),
                  onTap: () {
                    final next = {...selected};
                    if (!next.remove(i + 1)) next.add(i + 1);
                    onChanged(next);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.rose : AppColors.border,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.roseDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SoundPanel extends StatelessWidget {
  const _SoundPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
      decoration: softPanel(),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALARM SOUND',
                  style: TextStyle(
                    color: AppColors.rose,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pink Sparkle',
                  style: TextStyle(color: AppColors.ink, fontSize: 22),
                ),
              ],
            ),
          ),
          Icon(Icons.music_note, color: AppColors.rose, size: 30),
          SizedBox(width: 18),
          Icon(Icons.chevron_right, color: AppColors.rose, size: 30),
        ],
      ),
    );
  }
}

class _SettingPanel extends StatelessWidget {
  const _SettingPanel({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 172,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: softPanel(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.rose, size: 30),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(height: 48, child: Center(child: child)),
        ],
      ),
    );
  }
}
