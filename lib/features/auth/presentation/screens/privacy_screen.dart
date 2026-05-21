import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POLÍTICA DE PRIVACIDAD')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHero(),
          const SizedBox(height: 24),
          _buildIntro(),
          _buildSection(
            '1. Información que recopilamos',
            null,
            bullets: [
              'Datos de cuenta: nombre, correo electrónico y contraseña (cifrada).',
              'Datos de salud y fitness: peso, altura, entrenamientos, series, repeticiones y pesos utilizados.',
              'Metas y progreso: objetivos de peso, frecuencia semanal y logros.',
              'Hidratación: registros de consumo de agua diario.',
              'Datos técnicos: tipo de dispositivo y versión del SO, sin identificación adicional.',
            ],
          ),
          _buildSection(
            '2. Cómo usamos tu información',
            'Utilizamos tus datos exclusivamente para:',
            bullets: [
              'Mostrarte tu progreso, estadísticas y récords personales.',
              'Calcular tu IMC y estado físico.',
              'Sincronizar tus entrenamientos entre dispositivos.',
              'Otorgarte logros y mantener tu racha de entrenamiento.',
              'Mejorar el rendimiento y experiencia de la aplicación.',
            ],
            footer: 'No vendemos ni compartimos tu información con terceros para fines comerciales.',
          ),
          _buildSection(
            '3. Almacenamiento y seguridad',
            null,
            bullets: [
              'Tus datos se almacenan en servidores seguros con acceso restringido.',
              'Las contraseñas se almacenan con hash bcrypt, nunca en texto plano.',
              'La comunicación entre la app y el servidor usa HTTPS (TLS).',
              'Los tokens de autenticación se invalidan al cerrar sesión.',
            ],
          ),
          _buildSection(
            '4. Retención de datos',
            'Conservamos tus datos mientras tu cuenta esté activa. Puedes solicitar la eliminación de tu cuenta y todos sus datos escribiéndonos al correo de contacto. Los datos serán eliminados en un plazo máximo de 30 días.',
          ),
          _buildSection(
            '5. Tus derechos',
            'Tienes derecho a:',
            bullets: [
              'Acceder a todos los datos que tenemos sobre ti.',
              'Rectificar información incorrecta desde el perfil de la app.',
              'Eliminar tu cuenta y toda tu información personal.',
              'Exportar tus datos desde la plataforma web.',
              'Oponerte al procesamiento de tus datos en cualquier momento.',
            ],
          ),
          _buildSection(
            '6. Permisos de la aplicación',
            'La aplicación puede solicitar:',
            bullets: [
              'Internet: para sincronizar tus datos con el servidor.',
              'Notificaciones: para recordatorios de entrenamiento e hidratación (opcional).',
            ],
            footer: 'No accedemos a tu cámara, micrófono, contactos ni ubicación.',
          ),
          _buildSection(
            '7. Menores de edad',
            'Power Stack está dirigida a personas mayores de 13 años. No recopilamos intencionalmente información de menores de 13 años. Si eres padre o tutor y crees que tu hijo ha proporcionado datos, contáctanos para eliminarlos de inmediato.',
          ),
          _buildSection(
            '8. Cambios a esta política',
            'Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios significativos a través de la app o por correo electrónico.',
          ),
          const SizedBox(height: 8),
          _buildContactBox(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'POWER STACK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Política de\nPrivacidad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tu privacidad es nuestra prioridad.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: const Text(
        'En Power Stack nos comprometemos a proteger tu privacidad. Esta política explica qué información recopilamos, cómo la usamos y cuáles son tus derechos al usar nuestra aplicación de seguimiento de fitness.',
        style: TextStyle(color: Colors.black54, height: 1.6),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String? body, {
    List<String>? bullets,
    String? footer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textTitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (body != null) ...[
                  Text(body,
                      style: const TextStyle(color: Colors.black54, height: 1.6)),
                  if (bullets != null) const SizedBox(height: 10),
                ],
                if (bullets != null)
                  ...bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                  color: Colors.black54, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (footer != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    footer,
                    style: const TextStyle(
                      color: AppColors.textTitle,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: const [
          Icon(Icons.mail_outline, color: AppColors.primary, size: 28),
          SizedBox(height: 10),
          Text(
            '¿Tienes preguntas?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'privacidad@magusemail.com',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Power Stack — Fitness Tracker',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
