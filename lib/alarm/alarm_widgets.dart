import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../theme.dart';
import '../time_formatters.dart';
import 'alarm_model.dart';
import 'alarm_providers.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.centerTitle = false,
    this.currentEmail,
    this.onLogout,
  });

  final bool centerTitle;
  final String? currentEmail;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 24, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.local_florist_outlined,
              color: AppColors.rose,
              size: 32,
            ),
            if (!centerTitle) const SizedBox(width: 8),
            Expanded(
              child: Text(
                centerTitle ? 'Rise & Shine' : 'RK Rise & Shine',
                textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                style: const TextStyle(
                  color: AppColors.rose,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (currentEmail != null && !centerTitle) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  currentEmail!,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (onLogout != null && !centerTitle) ...[
              const SizedBox(width: 6),
              IconButton.filledTonal(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                color: AppColors.roseDark,
                onPressed: onLogout,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AlarmCard extends ConsumerWidget {
  const AlarmCard({super.key, required this.alarm});

  final AlarmModel alarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = alarm.enabled ? AppColors.rose : AppColors.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(28, 24, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.rose.withValues(
              alpha: alarm.enabled ? 0.09 : 0.04,
            ),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatTimeOfDay(alarm.time),
                        style: TextStyle(
                          color: color,
                          fontSize: 74,
                          fontWeight: FontWeight.w800,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          periodForTimeOfDay(alarm.time),
                          style: TextStyle(
                            color: color.withValues(alpha: 0.65),
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Switch(
                value: alarm.enabled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.rose,
                inactiveThumbColor: AppColors.border,
                inactiveTrackColor: AppColors.border.withValues(alpha: 0.8),
                onChanged: (enabled) {
                  ref
                      .read(alarmControllerProvider.notifier)
                      .toggleAlarm(alarm.id, enabled);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Pill(
                text: _repeatLabel(alarm.repeatDays),
                active: alarm.enabled,
              ),
              _Pill(text: alarm.label, active: alarm.enabled),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 20,
                color: color.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                alarm.soundName,
                style: TextStyle(
                  color: color.withValues(alpha: 0.78),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _repeatLabel(Set<int> days) {
    if (days.length == 7) return 'Daily';
    if (days.containsAll({1, 2, 3, 4, 5}) && days.length == 5) return 'Mon-Fri';
    if (days.containsAll({6, 7}) && days.length == 2) return 'Sat, Sun';
    if (days.isEmpty) return 'Once';
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days.map((day) => labels[day - 1]).join(' ');
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? AppColors.blushStrong.withValues(alpha: 0.62)
            : AppColors.border.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? AppColors.roseDark : AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

BoxDecoration softPanel({double radius = 28}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.rose.withValues(alpha: 0.08),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
    ],
  );
}
