import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/notification_settings_controller.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsController>().load();
    });
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NotificationSettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICACIONES'),
        actions: [
          if (ctrl.isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                final ctrl = context.read<NotificationSettingsController>();
                final ok = await ctrl.save();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Configuración guardada' : 'Error al guardar',
                    ),
                    backgroundColor:
                        ok ? AppColors.primary : Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Recordatorio de entrenamiento ──────────────────────────
                _buildSection(
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.primary,
                  title: 'Recordatorio de entrenamiento',
                  subtitle:
                      'Te notificamos si no has entrenado a la hora elegida',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activar recordatorio'),
                        value: ctrl.workoutEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: ctrl.setWorkoutEnabled,
                      ),
                      if (ctrl.workoutEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Hora del recordatorio'),
                          trailing: _timePill(
                            _formatTime(ctrl.workoutTime),
                            AppColors.primary,
                          ),
                          onTap: () => _pickTime(
                            context,
                            ctrl.workoutTime,
                            ctrl.setWorkoutTime,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Recordatorios de agua ──────────────────────────────────
                _buildSection(
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
                        value: ctrl.waterEnabled,
                        activeThumbColor: AppColors.secondary,
                        onChanged: ctrl.setWaterEnabled,
                      ),
                      if (ctrl.waterEnabled) ...[
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'META DIARIA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            _goalStepper(ctrl),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'HORARIOS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(ctrl.waterTimes.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _pickTime(
                                    context,
                                    ctrl.waterTimes[i],
                                    (t) => ctrl.setWaterTime(i, t),
                                  ),
                                  child: _timePill(
                                    _formatTime(ctrl.waterTimes[i]),
                                    AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _waterLabel(ctrl.waterTimes[i].hour),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                if (ctrl.waterTimes.length > 1)
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 20),
                                    color: Colors.red.shade300,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => ctrl.removeWaterTime(i),
                                  ),
                              ],
                            ),
                          );
                        }),
                        if (ctrl.waterTimes.length < 6)
                          TextButton.icon(
                            onPressed: () => _pickTime(
                              context,
                              TimeOfDay.now(),
                              ctrl.addWaterTime,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar horario'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Motivación mañanera ────────────────────────────────────
                _buildSection(
                  icon: Icons.wb_sunny_rounded,
                  color: Colors.orange,
                  title: 'Motivación mañanera',
                  subtitle: 'Una frase para arrancar el día con energía',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activar motivación matutina'),
                        value: ctrl.morningEnabled,
                        activeThumbColor: Colors.orange,
                        onChanged: ctrl.setMorningEnabled,
                      ),
                      if (ctrl.morningEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Hora de envío'),
                          trailing: _timePill(
                            _formatTime(ctrl.morningTime),
                            Colors.orange,
                          ),
                          onTap: () => _pickTime(
                            context,
                            ctrl.morningTime,
                            ctrl.setMorningTime,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Motivación nocturna ────────────────────────────────────
                _buildSection(
                  icon: Icons.nightlight_round,
                  color: Colors.deepPurple,
                  title: 'Motivación nocturna',
                  subtitle:
                      'Te felicitamos si entrenaste, te animamos si no',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activar motivación nocturna'),
                        value: ctrl.eveningEnabled,
                        activeThumbColor: Colors.deepPurple,
                        onChanged: ctrl.setEveningEnabled,
                      ),
                      if (ctrl.eveningEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Hora de envío'),
                          trailing: _timePill(
                            _formatTime(ctrl.eveningTime),
                            Colors.deepPurple,
                          ),
                          onTap: () => _pickTime(
                            context,
                            ctrl.eveningTime,
                            ctrl.setEveningTime,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Felicitación de cumpleaños ─────────────────────────────
                _buildSection(
                  icon: Icons.cake_rounded,
                  color: Colors.pink,
                  title: 'Felicitación de cumpleaños',
                  subtitle:
                      'Te mandamos un saludo especial en tu día',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activar felicitación'),
                    value: ctrl.birthdayEnabled,
                    activeThumbColor: Colors.pink,
                    onChanged: ctrl.setBirthdayEnabled,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Las horas se basan en la zona horaria del servidor.\nAsegúrate de que coincidan con tu hora local.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _timePill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _goalStepper(NotificationSettingsController ctrl) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => ctrl.setWaterGoal(ctrl.waterGoal - 1),
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.secondary,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '${ctrl.waterGoal} vasos',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        IconButton(
          onPressed: () => ctrl.setWaterGoal(ctrl.waterGoal + 1),
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.secondary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  String _waterLabel(int hour) {
    if (hour < 12) return 'Mañana';
    if (hour < 18) return 'Tarde';
    return 'Noche';
  }
}
