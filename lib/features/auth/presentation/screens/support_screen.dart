import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _email = 'soporte@powerstack.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOPORTE')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿En qué podemos ayudarte?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Estamos aquí para resolver cualquier duda o problema.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),

          // FAQ
          const _SectionHeader(title: 'PREGUNTAS FRECUENTES'),
          const SizedBox(height: 12),
          const _FaqTile(
            question: '¿Cómo creo una rutina?',
            answer:
                'Ve a RUTINAS desde el menú principal, toca el botón + y elige los ejercicios que deseas incluir junto con sus series y repeticiones.',
          ),
          const _FaqTile(
            question: '¿Cómo registro mi peso corporal?',
            answer:
                'Desde el dashboard toca el módulo PESO y luego el botón para agregar un nuevo registro. Se guardará con la fecha actual.',
          ),
          const _FaqTile(
            question: '¿Cómo funciona el registro de agua?',
            answer:
                'En la pantalla principal verás la sección HIDRATACIÓN HOY. Toca los botones +200ml, +350ml o +500ml para registrar tu consumo. La meta diaria es 2,000 ml.',
          ),
          const _FaqTile(
            question: '¿Qué son los logros?',
            answer:
                'Los logros se otorgan automáticamente al cumplir metas como completar tu primera rutina, mantener una racha de días consecutivos, o alcanzar tu meta diaria de agua.',
          ),
          const _FaqTile(
            question: '¿Puedo usar la app sin conexión?',
            answer:
                'Power Stack requiere conexión a internet para sincronizar tus datos con el servidor. Sin conexión no podrás guardar entrenamientos.',
          ),
          const _FaqTile(
            question: '¿Cómo elimino mi cuenta?',
            answer:
                'Escríbenos al correo de soporte indicando tu solicitud y eliminaremos tus datos en un plazo de 5 días hábiles.',
          ),
          const SizedBox(height: 32),

          // Contacto
          const _SectionHeader(title: 'CONTACTO DIRECTO'),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: _email,
            onTap: () {
              Clipboard.setData(const ClipboardData(text: _email));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Correo copiado al portapapeles'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.schedule_outlined,
            label: 'Tiempo de respuesta',
            value: 'Menos de 24 horas hábiles',
            onTap: null,
          ),
          const SizedBox(height: 32),

          // Versión
          Center(
            child: Text(
              'Power Stack v1.0.0',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.copy, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
