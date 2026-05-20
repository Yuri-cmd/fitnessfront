import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../workout/presentation/screens/goals_screen.dart';
import '../../../wiki/presentation/screens/wiki_screen.dart';
import '../../../metrics/presentation/screens/body_measurements_screen.dart';
import '../../../stats/presentation/screens/achievements_screen.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MÁS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard(
            context,
            title: 'METAS',
            subtitle: 'Gestiona tus objetivos de fitness',
            icon: Icons.emoji_events_rounded,
            color: Colors.orange,
            screen: const GoalsScreen(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'WIKI FITNESS',
            subtitle: 'Guías y contenido educativo',
            icon: Icons.menu_book_rounded,
            color: Colors.teal,
            screen: const WikiScreen(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'MEDIDAS CORPORALES',
            subtitle: 'Registra tus medidas y progreso',
            icon: Icons.straighten_rounded,
            color: Colors.deepOrange,
            screen: const BodyMeasurementsScreen(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'MIS LOGROS',
            subtitle: 'Medallas y reconocimientos obtenidos',
            icon: Icons.emoji_events_rounded,
            color: Colors.amber,
            screen: const AchievementsScreen(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'NOTIFICACIONES',
            subtitle: 'Configura recordatorios de entreno y agua',
            icon: Icons.notifications_rounded,
            color: Colors.indigo,
            screen: const NotificationSettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
