import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/features/metrics/data/models/measurement_model.dart';
import 'package:fit_tracker_app/features/metrics/presentation/controllers/measurement_controller.dart';
import 'package:fit_tracker_app/features/metrics/presentation/widgets/measure_chip.dart';

class BodyMeasurementsScreen extends StatelessWidget {
  const BodyMeasurementsScreen({super.key});

  static const _fields = [
    ('waist_cm', 'Cintura', Icons.straighten),
    ('chest_cm', 'Pecho', Icons.favorite_border),
    ('hips_cm', 'Cadera', Icons.accessibility_new),
    ('left_arm_cm', 'Brazo Izq.', Icons.fitness_center),
    ('right_arm_cm', 'Brazo Der.', Icons.fitness_center),
    ('left_leg_cm', 'Pierna Izq.', Icons.directions_walk),
    ('right_leg_cm', 'Pierna Der.', Icons.directions_walk),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MeasurementController>();
    return Scaffold(
      appBar: AppBar(title: const Text('MEDIDAS CORPORALES')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_measurements',
        onPressed: () => _showAddDialog(c),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.measurements.isEmpty) return const _EmptyState();
        return RefreshIndicator(
          onRefresh: c.load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: c.measurements.length,
            itemBuilder: (_, i) => _MeasurementCard(
              measurement: c.measurements[i],
              prev: i == 0 && c.measurements.length > 1
                  ? c.measurements[1]
                  : null,
              fields: _fields,
              onDelete: (id) => _confirmDelete(c, id),
            ),
          ),
        );
      }),
    );
  }

  void _showAddDialog(MeasurementController c) {
    Get.dialog(_AddMeasurementDialog(controller: c, fields: _fields));
  }

  void _confirmDelete(MeasurementController c, int id) {
    Get.dialog(AlertDialog(
      title: const Text('Eliminar medición'),
      content: const Text(
          '¿Estás seguro de que deseas eliminar este registro?'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        TextButton(
          onPressed: () {
            Get.back();
            c.remove(id);
          },
          child:
              const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}

// ── Add dialog ─────────────────────────────────────────────────────────────

class _AddMeasurementDialog extends StatefulWidget {
  final MeasurementController controller;
  final List<(String, String, IconData)> fields;

  const _AddMeasurementDialog(
      {required this.controller, required this.fields});

  @override
  State<_AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<_AddMeasurementDialog> {
  late final Map<String, TextEditingController> _ctrls;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ctrls = {for (var f in widget.fields) f.$1: TextEditingController()};
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final data = <String, dynamic>{
      'measured_at': DateFormat('yyyy-MM-dd').format(_date),
    };
    for (final f in widget.fields) {
      final v = double.tryParse(_ctrls[f.$1]!.text.replaceAll(',', '.'));
      if (v != null) data[f.$1] = v;
    }
    if (data.length <= 1) return;
    Get.back();
    final ok = await widget.controller.add(data);
    if (ok) {
      Get.snackbar('Medición guardada', '',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva medición'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.calendar_today, color: AppColors.primary),
              title: Text(DateFormat('dd/MM/yyyy').format(_date),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...widget.fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _ctrls[f.$1],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: f.$2,
                      prefixIcon: Icon(f.$3, size: 18),
                      suffixText: 'cm',
                    ),
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black),
          child: const Text('GUARDAR'),
        ),
      ],
    );
  }
}

// ── Measurement card ───────────────────────────────────────────────────────

class _MeasurementCard extends StatelessWidget {
  final Measurement measurement;
  final Measurement? prev;
  final List<(String, String, IconData)> fields;
  final void Function(int) onDelete;

  const _MeasurementCard({
    required this.measurement,
    required this.prev,
    required this.fields,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy', 'es_ES')
        .format(measurement.measuredAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(date,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red.shade300,
                  onPressed: () => onDelete(measurement.id),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fields
                  .where((f) => measurement.field(f.$1) != null)
                  .map((f) => MeasureChip(
                        label: f.$2,
                        value: measurement.field(f.$1)!,
                        diff: prev != null && prev!.field(f.$1) != null
                            ? measurement.field(f.$1)! - prev!.field(f.$1)!
                            : null,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.straighten,
                size: 72,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            const Text('Sin medidas registradas',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Toca + para agregar tu primera medición',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant)),
          ],
        ),
      );
}
