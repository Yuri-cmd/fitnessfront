import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/services/health_service.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class HealthSettingsScreen extends StatelessWidget {
  const HealthSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APPLE HEALTH')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B5C).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B5C).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Color(0xFFFF3B5C), size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Integración con Apple Health',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 4),
                      Text(
                        'Power Stack sincroniza tus datos de entrenamiento y salud con la app Apple Health.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionLabel('DATOS QUE POWER STACK ESCRIBE EN APPLE HEALTH'),
          const SizedBox(height: 10),
          const _HealthDataTile(
            icon: Icons.fitness_center_rounded,
            color: Color(0xFF34C759),
            label: 'Entrenamientos',
            detail:
                'Cada sesión completada se registra como entrenamiento de fuerza.',
            access: 'Escritura',
          ),
          const _HealthDataTile(
            icon: Icons.monitor_weight_rounded,
            color: Color(0xFF007AFF),
            label: 'Peso corporal',
            detail: 'Al registrar tu peso en Power Stack, se guarda en Salud.',
            access: 'Lectura / Escritura',
          ),

          const SizedBox(height: 20),
          const _SectionLabel('DATOS QUE POWER STACK LEE DE APPLE HEALTH'),
          const SizedBox(height: 10),
          const _HealthDataTile(
            icon: Icons.directions_walk_rounded,
            color: Color(0xFF34C759),
            label: 'Pasos diarios',
            detail:
                'Se muestran tus pasos del día en el panel de inicio.',
            access: 'Solo lectura',
          ),
          const _HealthDataTile(
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFFF9500),
            label: 'Calorías activas',
            detail: 'Calorías quemadas durante actividad física.',
            access: 'Solo lectura',
          ),
          const _HealthDataTile(
            icon: Icons.favorite_rounded,
            color: Color(0xFFFF3B5C),
            label: 'Frecuencia cardíaca',
            detail: 'Para mostrar métricas de rendimiento.',
            access: 'Solo lectura',
          ),
          const _HealthDataTile(
            icon: Icons.height_rounded,
            color: Color(0xFF5856D6),
            label: 'Altura',
            detail: 'Para cálculos de métricas corporales.',
            access: 'Solo lectura',
          ),

          const SizedBox(height: 28),
          if (Platform.isIOS)
            ElevatedButton.icon(
              onPressed: () async {
                await HealthService().requestPermissions();
              },
              icon: const Icon(Icons.health_and_safety_outlined),
              label: const Text('ADMINISTRAR PERMISOS DE SALUD'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          const SizedBox(height: 16),
          const Text(
            'Puedes revocar estos permisos en cualquier momento desde Ajustes › Salud › Apps › Power Stack.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1,
      ),
    );
  }
}

class _HealthDataTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String detail;
  final String access;

  const _HealthDataTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.detail,
    required this.access,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        access,
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(detail,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
