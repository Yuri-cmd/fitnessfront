import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/measurement_controller.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeasurementController>().load();
    });
  }

  static const _fields = [
    ('waist_cm',     'Cintura',       Icons.straighten),
    ('chest_cm',     'Pecho',         Icons.favorite_border),
    ('hips_cm',      'Cadera',        Icons.accessibility_new),
    ('left_arm_cm',  'Brazo Izq.',    Icons.fitness_center),
    ('right_arm_cm', 'Brazo Der.',    Icons.fitness_center),
    ('left_leg_cm',  'Pierna Izq.',   Icons.directions_walk),
    ('right_leg_cm', 'Pierna Der.',   Icons.directions_walk),
  ];

  void _showAddDialog() {
    final controllers = {for (var f in _fields) f.$1: TextEditingController()};
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva medición'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fecha
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setDialogState(() => selectedDate = d);
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                ..._fields.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: controllers[f.$1],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = <String, dynamic>{
                  'measured_at': DateFormat('yyyy-MM-dd').format(selectedDate),
                };
                for (final f in _fields) {
                  final v = double.tryParse(
                      controllers[f.$1]!.text.replaceAll(',', '.'));
                  if (v != null) data[f.$1] = v;
                }
                if (data.length <= 1) return; // solo la fecha
                Navigator.pop(ctx);
                final ok = await context.read<MeasurementController>().add(data);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Medición guardada'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black),
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MeasurementController>();

    return Scaffold(
      appBar: AppBar(title: const Text('MEDIDAS CORPORALES')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.measurements.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () => context.read<MeasurementController>().load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: ctrl.measurements.length,
                    itemBuilder: (_, i) =>
                        _buildCard(ctrl.measurements[i], i == 0 && ctrl.measurements.length > 1
                            ? ctrl.measurements[1]
                            : null),
                  ),
                ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.straighten,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            const Text('Sin medidas registradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Toca + para agregar tu primera medición',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );

  Widget _buildCard(dynamic m, dynamic prev) {
    final date = DateFormat('dd MMM yyyy', 'es_ES')
        .format(DateTime.parse(m['measured_at']));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red.shade300,
                  onPressed: () => _confirmDelete(m['id']),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _fields
                  .where((f) => m[f.$1] != null)
                  .map((f) => _measureChip(
                        f.$2,
                        (m[f.$1] as num).toDouble(),
                        prev != null && prev[f.$1] != null
                            ? (m[f.$1] as num).toDouble() -
                                (prev[f.$1] as num).toDouble()
                            : null,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measureChip(String label, double value, double? diff) {
    Color? diffColor;
    String? diffText;
    if (diff != null && diff.abs() >= 0.1) {
      diffColor = diff < 0 ? AppColors.primary : AppColors.alert;
      diffText = '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Text(' cm',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              if (diffText != null) ...[
                const SizedBox(width: 4),
                Text(diffText,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: diffColor)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar medición'),
        content: const Text('¿Estás seguro de que deseas eliminar este registro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MeasurementController>().remove(id);
            },
            child: const Text('ELIMINAR',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
