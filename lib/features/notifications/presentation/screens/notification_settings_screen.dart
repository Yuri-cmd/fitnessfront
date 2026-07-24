import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/notifications/presentation/controllers/notification_settings_controller.dart';
import 'package:fit_tracker_app/features/notifications/presentation/widgets/notification_section_card.dart';
import 'package:fit_tracker_app/features/notifications/presentation/widgets/time_pill.dart';

Future<void> _pickTime(
  BuildContext ctx,
  TimeOfDay initial,
  void Function(TimeOfDay) onPicked,
) async {
  final picked = await showTimePicker(
    context: ctx,
    initialTime: initial,
    builder: (ctx2, child) => MediaQuery(
      data: MediaQuery.of(ctx2).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (picked != null) onPicked(picked);
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationSettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICACIONES'),
        actions: [
          Obx(() => c.isSaving.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              : TextButton(
                  onPressed: () async {
                    final ok = await c.save();
                    Get.snackbar(
                      ok ? 'Configuración guardada' : 'Error al guardar',
                      '',
                      backgroundColor:
                          ok ? AppColors.primary : Colors.red.shade400,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                  child: const Text('GUARDAR',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                )),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final workoutEnabled = c.workoutEnabled.value;
        final workoutTime = c.workoutTime.value;
        final waterEnabled = c.waterEnabled.value;
        final waterTimes = c.waterTimes.toList();
        final waterGoal = c.waterGoal.value;
        final morningEnabled = c.morningEnabled.value;
        final morningTime = c.morningTime.value;
        final eveningEnabled = c.eveningEnabled.value;
        final eveningTime = c.eveningTime.value;
        final birthdayEnabled = c.birthdayEnabled.value;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _WorkoutSection(
              enabled: workoutEnabled,
              time: workoutTime,
              onEnabledChanged: c.setWorkoutEnabled,
              onTimePicked: c.setWorkoutTime,
            ),
            const SizedBox(height: 20),
            _WaterSection(
              enabled: waterEnabled,
              times: waterTimes,
              goal: waterGoal,
              onEnabledChanged: c.setWaterEnabled,
              onTimeChanged: c.setWaterTime,
              onTimeAdded: c.addWaterTime,
              onTimeRemoved: c.removeWaterTime,
              onGoalChanged: c.setWaterGoal,
            ),
            const SizedBox(height: 20),
            _MotivationSection(
              icon: Icons.wb_sunny_rounded,
              color: AppColors.warning,
              title: 'Motivación mañanera',
              subtitle: 'Una frase para arrancar el día con energía',
              switchLabel: 'Activar motivación matutina',
              enabled: morningEnabled,
              time: morningTime,
              onEnabledChanged: c.setMorningEnabled,
              onTimePicked: c.setMorningTime,
            ),
            const SizedBox(height: 20),
            _MotivationSection(
              icon: Icons.nightlight_round,
              color: AppColors.supersetAccent,
              title: 'Motivación nocturna',
              subtitle: 'Te felicitamos si entrenaste, te animamos si no',
              switchLabel: 'Activar motivación nocturna',
              enabled: eveningEnabled,
              time: eveningTime,
              onEnabledChanged: c.setEveningEnabled,
              onTimePicked: c.setEveningTime,
            ),
            const SizedBox(height: 20),
            _BirthdaySection(
              enabled: birthdayEnabled,
              onChanged: c.setBirthdayEnabled,
            ),
            const SizedBox(height: 32),
            Text(
              'Las horas se basan en la zona horaria del servidor.\nAsegúrate de que coincidan con tu hora local.',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}

// ── Sections ──────────────────────────────────────────────────────────────────

class _WorkoutSection extends StatelessWidget {
  final bool enabled;
  final TimeOfDay time;
  final void Function(bool) onEnabledChanged;
  final void Function(TimeOfDay) onTimePicked;

  const _WorkoutSection({
    required this.enabled,
    required this.time,
    required this.onEnabledChanged,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationSectionCard(
      icon: Icons.fitness_center_rounded,
      color: AppColors.primary,
      title: 'Recordatorio de entrenamiento',
      subtitle: 'Te notificamos si no has entrenado a la hora elegida',
      child: Column(children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Activar recordatorio'),
          value: enabled,
          activeThumbColor: AppColors.primary,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hora del recordatorio'),
            trailing: TimePill(
                label: NotificationSettingsController.formatTime(time),
                color: AppColors.primary),
            onTap: () => _pickTime(context, time, onTimePicked),
          ),
        ],
      ]),
    );
  }
}

class _WaterSection extends StatelessWidget {
  final bool enabled;
  final List<TimeOfDay> times;
  final int goal;
  final void Function(bool) onEnabledChanged;
  final void Function(int, TimeOfDay) onTimeChanged;
  final void Function(TimeOfDay) onTimeAdded;
  final void Function(int) onTimeRemoved;
  final void Function(int) onGoalChanged;

  const _WaterSection({
    required this.enabled,
    required this.times,
    required this.goal,
    required this.onEnabledChanged,
    required this.onTimeChanged,
    required this.onTimeAdded,
    required this.onTimeRemoved,
    required this.onGoalChanged,
  });

  String _waterLabel(int hour) {
    if (hour < 12) return 'Mañana';
    if (hour < 18) return 'Tarde';
    return 'Noche';
  }

  @override
  Widget build(BuildContext context) {
    return NotificationSectionCard(
      icon: Icons.water_drop_rounded,
      color: AppColors.secondary,
      title: 'Recordatorios de agua',
      subtitle: 'Te avisamos a las horas que configures',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Activar recordatorios'),
            value: enabled,
            activeThumbColor: AppColors.secondary,
            onChanged: onEnabledChanged,
          ),
          if (enabled) ...[
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('META DIARIA',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2)),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onGoalChanged(goal - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('$goal vasos',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    IconButton(
                      onPressed: () => onGoalChanged(goal + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('HORARIOS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            ...List.generate(times.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => _pickTime(context, times[i],
                          (t) => onTimeChanged(i, t)),
                      child: TimePill(
                          label: NotificationSettingsController.formatTime(
                              times[i]),
                          color: AppColors.secondary),
                    ),
                    const SizedBox(width: 10),
                    Text(_waterLabel(times[i].hour),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    const Spacer(),
                    if (times.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: Colors.red.shade300,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onTimeRemoved(i),
                      ),
                  ]),
                )),
            if (times.length < 6)
              TextButton.icon(
                onPressed: () =>
                    _pickTime(context, TimeOfDay.now(), onTimeAdded),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar horario'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary),
              ),
          ],
        ],
      ),
    );
  }
}

class _MotivationSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String switchLabel;
  final bool enabled;
  final TimeOfDay time;
  final void Function(bool) onEnabledChanged;
  final void Function(TimeOfDay) onTimePicked;

  const _MotivationSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.switchLabel,
    required this.enabled,
    required this.time,
    required this.onEnabledChanged,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationSectionCard(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      child: Column(children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(switchLabel),
          value: enabled,
          activeThumbColor: color,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hora de envío'),
            trailing: TimePill(
                label: NotificationSettingsController.formatTime(time),
                color: color),
            onTap: () => _pickTime(context, time, onTimePicked),
          ),
        ],
      ]),
    );
  }
}

class _BirthdaySection extends StatelessWidget {
  final bool enabled;
  final void Function(bool) onChanged;

  const _BirthdaySection(
      {required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return NotificationSectionCard(
      icon: Icons.cake_rounded,
      color: Colors.pink,
      title: 'Felicitación de cumpleaños',
      subtitle: 'Te mandamos un saludo especial en tu día',
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Activar felicitación'),
        value: enabled,
        activeThumbColor: Colors.pink,
        onChanged: onChanged,
      ),
    );
  }
}
