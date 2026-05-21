import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/widgets/section_label.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/one_rm_controller.dart';

class RmResultsSection extends StatelessWidget {
  const RmResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OneRmController>();
    return Obx(() {
      final results = c.results.value;
      if (results == null) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _AverageCard(avgRm: c.avgRm),
          const SizedBox(height: 12),
          const SectionLabel('DESGLOSE POR FÓRMULA'),
          const SizedBox(height: 8),
          _FormulaCard(results: results),
          const SizedBox(height: 12),
          const SectionLabel('TABLA DE CARGA'),
          const SizedBox(height: 8),
          _LoadTable(avgRm: c.avgRm),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}

// ── Promedio ──────────────────────────────────────────────────────────────────

class _AverageCard extends StatelessWidget {
  final double avgRm;
  const _AverageCard({required this.avgRm});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PROMEDIO ESTIMADO',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text('${avgRm.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fórmulas ──────────────────────────────────────────────────────────────────

class _FormulaCard extends StatelessWidget {
  final Map<String, double> results;
  const _FormulaCard({required this.results});

  @override
  Widget build(BuildContext context) {
    final entries = results.entries.toList();
    return Card(
      child: Column(
        children: entries.asMap().entries.map((e) {
          final isLast = e.key == entries.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(e.value.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600))),
                    Text('${e.value.value.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 15)),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Tabla de carga ────────────────────────────────────────────────────────────

class _LoadTable extends StatelessWidget {
  final double avgRm;
  const _LoadTable({required this.avgRm});

  static const _pcts = [100, 95, 90, 85, 80, 75, 70, 65, 60];
  static const _reps = {
    100: 1, 95: 2, 90: 3, 85: 4,
    80: 5, 75: 6, 70: 8, 65: 10, 60: 12,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _TableHeader(),
          ..._pcts.asMap().entries.map((e) => _TableRow(
                pct: e.value,
                weight: avgRm * e.value / 100,
                reps: _reps[e.value]!,
                isEven: e.key.isEven,
              )),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(child: Text('%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(child: Text('Peso', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(child: Text('Reps aprox.', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final int pct;
  final double weight;
  final int reps;
  final bool isEven;
  const _TableRow({required this.pct, required this.weight, required this.reps, required this.isEven});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven
          ? Colors.transparent
          : Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text('$pct%', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
              child: Text('${weight.toStringAsFixed(1)} kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          Expanded(
              child: Text('~$reps reps',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12))),
        ],
      ),
    );
  }
}

