import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class VersionService {
  static bool _checked = false;

  static Future<void> checkAndPrompt(BuildContext context) async {
    if (_checked) return;
    _checked = true;

    try {
      final info = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS ? 'ios' : 'android';

      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));

      final res = await dio.get('/version', queryParameters: {'platform': platform});
      if (res.statusCode != 200) return;

      final data = res.data as Map<String, dynamic>;
      if (data['up_to_date'] == true) return;

      final current = info.version;
      final latest = data['latest_version'] as String;
      final minimum = data['minimum_version'] as String;
      final storeUrl = data['store_url'] as String;
      final notes = data['release_notes'] as String? ?? '';

      final isForce = _compare(current, minimum) < 0;
      final hasUpdate = _compare(current, latest) < 0;

      if (!hasUpdate) return;
      if (!context.mounted) return;

      _showDialog(
        context,
        latest: latest,
        notes: notes,
        storeUrl: storeUrl,
        force: isForce,
      );
    } catch (_) {
      // No bloquear la app por fallo de red en el check de versión
    }
  }

  // -1 si a < b, 0 si igual, 1 si a > b
  static int _compare(String a, String b) {
    final pa = a.split('.').map(int.tryParse).map((v) => v ?? 0).toList();
    final pb = b.split('.').map(int.tryParse).map((v) => v ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va.compareTo(vb);
    }
    return 0;
  }

  static void _showDialog(
    BuildContext context, {
    required String latest,
    required String notes,
    required String storeUrl,
    required bool force,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: !force,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.system_update_rounded,
                          color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'NUEVA VERSIÓN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Power Stack $latest',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (force)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Esta actualización es obligatoria para continuar usando la app.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!force)
                      const Text(
                        'Hay una nueva versión disponible con mejoras y novedades.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'NOVEDADES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          notes,
                          style: const TextStyle(
                              fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openStore(storeUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'ACTUALIZAR AHORA',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                    if (!force) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Ahora no',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
