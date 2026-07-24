import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_radii.dart';
import 'package:fit_tracker_app/core/widgets/app_card.dart';
import 'package:fit_tracker_app/features/workout/presentation/screens/goals_screen.dart';
import 'package:fit_tracker_app/features/wiki/presentation/screens/wiki_screen.dart';
import 'package:fit_tracker_app/features/metrics/presentation/screens/body_measurements_screen.dart';
import 'package:fit_tracker_app/features/stats/presentation/screens/achievements_screen.dart';
import 'package:fit_tracker_app/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:fit_tracker_app/features/home/presentation/screens/health_settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MÁS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _NavCard(
            title: 'METAS',
            subtitle: 'Gestiona tus objetivos de fitness',
            icon: Icons.emoji_events_rounded,
            color: Colors.orange,
            screen: GoalsScreen(),
          ),
          SizedBox(height: 16),
          _NavCard(
            title: 'WIKI FITNESS',
            subtitle: 'Guías y contenido educativo',
            icon: Icons.menu_book_rounded,
            color: Colors.teal,
            screen: WikiScreen(),
          ),
          SizedBox(height: 16),
          _NavCard(
            title: 'MEDIDAS CORPORALES',
            subtitle: 'Registra tus medidas y progreso',
            icon: Icons.straighten_rounded,
            color: Colors.deepOrange,
            screen: BodyMeasurementsScreen(),
          ),
          SizedBox(height: 16),
          _NavCard(
            title: 'MIS LOGROS',
            subtitle: 'Medallas y reconocimientos obtenidos',
            icon: Icons.emoji_events_rounded,
            color: Colors.amber,
            screen: AchievementsScreen(),
          ),
          SizedBox(height: 16),
          _NavCard(
            title: 'NOTIFICACIONES',
            subtitle: 'Configura recordatorios de entreno y agua',
            icon: Icons.notifications_rounded,
            color: Colors.indigo,
            screen: NotificationSettingsScreen(),
          ),
          SizedBox(height: 16),
          _NavCard(
            title: 'APPLE HEALTH',
            subtitle: 'Datos que Power Stack sincroniza con Salud',
            icon: Icons.favorite_rounded,
            color: Color(0xFFFF3B5C),
            screen: HealthSettingsScreen(),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(20),
      onTap: () => Get.to(() => screen),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color, size: 24),
        ],
      ),
    );
  }
}
