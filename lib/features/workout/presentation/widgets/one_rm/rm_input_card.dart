import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/widgets/section_label.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/one_rm_controller.dart';

class RmInputCard extends StatelessWidget {
  const RmInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OneRmController>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'PESO LEVANTADO',
                    child: TextField(
                      controller: c.weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          hintText: '100', suffixText: 'kg'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LabeledField(
                    label: 'REPETICIONES',
                    child: TextField(
                      controller: c.repsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => c.calculate(),
                      decoration: const InputDecoration(
                          hintText: '5', suffixText: 'reps'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('CALCULAR',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
